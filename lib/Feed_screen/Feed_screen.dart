import 'package:fama/Feed_screen/public_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../services and managers/feed_service.dart';
import '../services and managers/fama_like_api_service.dart';
import '../services and managers/post_share_service.dart';
import '../services and managers/post_views_api_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';
import '../widgets/comment_bottom_sheet.dart';
import '../widgets/report_bottom_sheet.dart';
import '../widgets/fama_bottom_nav.dart';
import 'post_now_popup.dart';

/// TikTok-style main newsfeed — fullscreen video posts ke upar
/// filters, engagement actions aur creator info overlay hota hai.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const Color _accentColor = Color(0xFFFFC839);
  static const int _perPage = 15;

  // 'All' | 'Location' | 'School'
  String _selectedFilter = 'All';

  final PageController _pageController = PageController();

  final List<FeedPost> _posts = [];
  int _currentIndex = 0;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // 3 possible states: loading -> either success (posts filled) or failed
  bool _isLoading = true;
  bool _initialLoadFailed = false;
  String _errorMessage = '';

  // Post ids jinka view is session mein already register ho chuka hai —
  // taake ek hi post ka view baar baar (rebuild/re-swipe par) count na ho.
  final Set<int> _viewedPostIds = {};

  // Post ids jinhein currently FAMA (star) diya hua hai — star icon ka
  // filled/amber state isi se decide hota hai. Har feed fetch (initial
  // + load more) ke baad backend ke `is_liked` field se sync hota hai,
  // is liye pehle se liya hua FAMA app restart/navigation ke baad bhi
  // sahi (server-backed) filled state mein dikhta hai.
  final Set<int> _famaGivenPostIds = {};

  // Post ids jinke liye FAMA give/remove request abhi in-flight hai —
  // taake ek hi post par tap ko baar baar spam na kiya ja sake.
  final Set<int> _famaPendingPostIds = {};

  // Har post ka displayed FAMA count — APIs updated count wapas nahi
  // dete, is liye tap hote hi yahan locally +1/-1 kar dete hain taake
  // count turant (optimistically) update dikhe.
  final Map<int, int> _famaPointsOverride = {};

  // Post ids jinke liye Share request abhi in-flight hai — taake ek hi
  // post ko baar baar spam tap na kiya ja sake.
  final Set<int> _sharePendingPostIds = {};

  // Har post ka displayed shares count — share API updated count wapas
  // deti hai, isko yahan override kar dete hain taake list dobara fetch
  // kiye bina bhi turant sahi count dikhe.
  final Map<int, int> _sharesCountOverride = {};

  // Har post ka displayed comments count — comment add/delete hote hi
  // yahan +1/-1 kar dete hain taake bottom sheet band kiye bina bhi feed
  // par count turant update dikhe (bina refresh kiye).
  final Map<int, int> _commentsCountOverride = {};

  // Jab public profile screen (ya koi aur screen) par navigate karte hain
  // to true — is se current video ka isActive false ho jata hai aur wo
  // pause ho jata hai. Wapas aane par false, taake video auto-resume ho.
  bool _feedPaused = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialFeed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Fetching ─────────────────────────────────────────────────────────

  Future<void> _fetchInitialFeed() async {
    setState(() {
      _isLoading = true;
      _initialLoadFailed = false;
    });

    final String? token = SessionManager.accessToken;

    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _initialLoadFailed = true;
        _errorMessage = 'Session expired. Please log in again.';
      });
      AppHelpers.showError(_errorMessage);
      return;
    }

    try {
      final List<FeedPost> posts = await FeedApiService.getFeed(
        token: token,
        locationId: 1,
        page: 1,
        perPage: _perPage,
      );

      debugPrint('FEED DEBUG -> posts fetched: ${posts.length}');

      if (!mounted) return;

      setState(() {
        _posts
          ..clear()
          ..addAll(posts);
        _page = 1;
        _hasMore = posts.length == _perPage;
        _isLoading = false;
        _initialLoadFailed = posts.isEmpty;
        _errorMessage = posts.isEmpty ? 'No posts found yet.' : '';
        _syncFamaStateFromServer(posts);
      });

      // Feed load hote hi jo pehla post screen par dikhta hai, uska view
      // bhi register karo (baaki posts ka _onPageChanged handle karta hai).
      if (posts.isNotEmpty) {
        _registerView(posts.first);
      }
    } catch (e) {
      debugPrint('FEED DEBUG -> error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _initialLoadFailed = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      AppHelpers.showError(_errorMessage);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) return;

    setState(() => _isLoadingMore = true);

    try {
      final List<FeedPost> posts = await FeedApiService.getFeed(
        token: token,
        locationId: 1,
        page: _page + 1,
        perPage: _perPage,
      );

      if (!mounted) return;
      setState(() {
        _posts.addAll(posts);
        _page += 1;
        _hasMore = posts.length == _perPage;
        _isLoadingMore = false;
        _syncFamaStateFromServer(posts);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Syncs [_famaGivenPostIds] with the `is_liked` flag from freshly
  /// fetched [posts]. Skips any post with a toggle currently in-flight,
  /// so a server response can't clobber a tap the user just made.
  ///
  /// Must be called from inside a `setState`.
  void _syncFamaStateFromServer(List<FeedPost> posts) {
    for (final FeedPost post in posts) {
      if (_famaPendingPostIds.contains(post.id)) continue;

      if (post.isLiked) {
        _famaGivenPostIds.add(post.id);
      } else {
        _famaGivenPostIds.remove(post.id);
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _registerView(_posts[index]);

    if (index >= _posts.length - 3) {
      _loadMore();
    }
  }

  /// Registers a view for [post] with the backend — once per post per
  /// session. Silent/best-effort: failures are logged, not shown to the
  /// user, and the post is allowed to retry on its next view if it fails.
  void _registerView(FeedPost post) {
    if (_viewedPostIds.contains(post.id)) return; // already counted

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) return;

    _viewedPostIds.add(post.id);

    PostViewApiService.incrementView(
      token: token,
      postId: post.id,
    ).catchError((Object e) {
      debugPrint('View increment failed for post ${post.id}: $e');
      _viewedPostIds.remove(post.id); // allow retry on next view
    });
  }

  /// The count currently shown for [post] — uses the locally-tracked
  /// override if the user has toggled FAMA this session, otherwise falls
  /// back to the count from the feed API.
  int _currentFamaCount(FeedPost post) {
    return _famaPointsOverride[post.id] ?? post.famaPoints;
  }

  /// Toggles the FAMA (star) on [post] — gives it if not already given,
  /// removes it otherwise. Updates the UI optimistically (instantly:
  /// icon + count), persists the new state locally (so it survives
  /// navigation/app restarts), then confirms with the backend in the
  /// background — reverting everything and showing an error if the
  /// request fails.
  Future<void> _toggleFama(FeedPost post) async {
    if (_famaPendingPostIds.contains(post.id)) return; // already in-flight

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    final bool wasGiven = _famaGivenPostIds.contains(post.id);
    final int countBeforeToggle = _currentFamaCount(post);

    setState(() {
      _famaPendingPostIds.add(post.id);
      if (wasGiven) {
        _famaGivenPostIds.remove(post.id);
        _famaPointsOverride[post.id] = countBeforeToggle - 1;
      } else {
        _famaGivenPostIds.add(post.id);
        _famaPointsOverride[post.id] = countBeforeToggle + 1;
      }
    });

    try {
      if (wasGiven) {
        await FamaApiService.removeFama(token: token, postId: post.id);
      } else {
        await FamaApiService.giveFama(token: token, postId: post.id);
      }
    } catch (e) {
      debugPrint('FAMA toggle failed for post ${post.id}: $e');
      if (!mounted) return;

      // Revert the optimistic update since the request failed.
      setState(() {
        if (wasGiven) {
          _famaGivenPostIds.add(post.id);
        } else {
          _famaGivenPostIds.remove(post.id);
        }
        _famaPointsOverride[post.id] = countBeforeToggle;
      });

      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _famaPendingPostIds.remove(post.id));
      }
    }
  }

  /// The shares count currently shown for [post] — server-confirmed
  /// override once a share has been recorded this session, otherwise the
  /// count from the feed API.
  int _currentSharesCount(FeedPost post) {
    return _sharesCountOverride[post.id] ?? post.sharesCount;
  }

  /// Records a share for [post] and updates its displayed count from the
  /// server's response. Native share sheet pehle khulta hai (WhatsApp,
  /// copy link, etc. — user apna platform khud choose karta hai), phir
  /// backend par share count register hoti hai.
  Future<void> _handleShare(FeedPost post) async {
    if (_sharePendingPostIds.contains(post.id)) return; // already in-flight

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    // Native share sheet — video ka direct URL share hota hai.
    try {
      await Share.share(
        'Check out this video on FAMA!\n${post.videoUrl}',
        subject: 'FAMA video from ${post.userName}',
      );
    } catch (e) {
      debugPrint('Native share sheet failed: $e');
    }

    setState(() => _sharePendingPostIds.add(post.id));

    try {
      final PostShareResult result = await PostShareApiService.sharePost(
        token: token,
        postId: post.id,
      );

      if (!mounted) return;
      setState(() => _sharesCountOverride[post.id] = result.sharesCount);
    } catch (e) {
      // Share sheet already opened successfully from the user's point of
      // view — count failing is background analytics, so log it quietly
      // rather than showing an error that would confuse them.
      debugPrint('Share count failed for post ${post.id}: $e');
    } finally {
      if (mounted) {
        setState(() => _sharePendingPostIds.remove(post.id));
      }
    }
  }

  /// The comments count currently shown for [post] — local override once
  /// the user has added/deleted a comment this session, otherwise the
  /// count from the feed API.
  int _currentCommentsCount(FeedPost post) {
    return _commentsCountOverride[post.id] ?? post.commentsCount;
  }

  /// Avatar/name par tap karne se us user ka public profile screen khulta
  /// hai (token session se aata hai, target_id post ka user_id hota hai).
  /// Screen khulne se pehle current video pause ho jata hai (`_feedPaused`
  /// true), aur wapas aane par khud-ba-khud resume ho jata hai (false).
  Future<void> _openPosterProfile(FeedPost post) async {
    setState(() => _feedPaused = true);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(targetId: post.userId),
      ),
    );

    if (!mounted) return;
    setState(() => _feedPaused = false);
  }

  /// Reports the creator using the user ID, as shown in the API example.
  Future<void> _openReport(FeedPost post) async {
    if (_feedPaused) return;

    if (post.id <= 0) {
      AppHelpers.showError('Invalid post.');
      return;
    }

    setState(() => _feedPaused = true);

    try {
      final message = await showReportBottomSheet(
        context,
        reportedType: 'post',
        reportedId: post.id,
        targetName: 'Post by ${post.userName}',
      );

      if (!mounted || message == null) return;

      AppHelpers.showSuccess(
        message.trim().isNotEmpty
            ? message
            : 'Report submitted successfully.',
      );
    } finally {
      if (mounted) {
        setState(() => _feedPaused = false);
      }
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_posts.isEmpty)
            _buildEmptyState()
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _posts.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildPostPage(_posts[index], index == _currentIndex);
              },
            ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopFilters(),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FamaBottomNav(
        currentIndex: 0,
        onTap: (index) => handleFamaNavTap(context, 0, index),
        onPostTap: () => showPostNowPopup(context),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_initialLoadFailed) {
      return Center(
        child: TextButton(
          onPressed: _fetchInitialFeed,
          child: Text(
            '$_errorMessage\nTap to retry.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPostPage(FeedPost post, bool isActive) {
    // _feedPaused true hone par (jaise public profile screen open hone se
    // pehle) yahan bhi false ho jata hai, taake video pause ho jaye.
    final bool videoActive = isActive && !_feedPaused;

    return Stack(
      fit: StackFit.expand,
      children: [
        _FeedVideoItem(post: post, isActive: videoActive),

        // Bottom fade for text readability
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.75),
                ],
                stops: const [0.55, 1],
              ),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildBottomInfo(post)],
          ),
        ),

        // Right side action buttons
        Positioned(
          right: 12,
          bottom: 128,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _handleShare(post),
                child: _actionButton(
                  icon: Icons.reply,
                  count: '${_currentSharesCount(post)}',
                ),
              ),
              const SizedBox(height: 18),
              Tooltip(
                message: 'Report post',
                child: Semantics(
                  button: true,
                  label: 'Report post by ${post.userName}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _openReport(post),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: _actionButton(
                        icon: Icons.error_outline_rounded,
                        count: 'Report',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _famaActionButton(post),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => showCommentsBottomSheet(
                  context,
                  postId: post.id,
                  onCommentCountChanged: (delta) {
                    if (!mounted) return;
                    setState(() {
                      _commentsCountOverride[post.id] =
                          _currentCommentsCount(post) + delta;
                    });
                  },
                ),
                child: _actionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  count: '${_currentCommentsCount(post)}',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _filterChip('All'),
          const SizedBox(width: 8),
          _filterChip('Location'),
          const SizedBox(width: 8),
          _filterChip('School'),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color:
          isSelected ? Colors.white.withOpacity(0.35) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white70, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Rob',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Tappable star button — filled amber when FAMA is given to this post,
  /// plain outline otherwise. Tapping toggles it via [_toggleFama].
  Widget _famaActionButton(FeedPost post) {
    final bool isGiven = _famaGivenPostIds.contains(post.id);

    return GestureDetector(
      onTap: () => _toggleFama(post),
      child: Column(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGiven ? Icons.star_rounded : Icons.star_border_rounded,
              color: isGiven ? _accentColor : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentFamaCount(post)}',
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String count}) {
    return Column(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontFamily: 'Rob',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(FeedPost post) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Views + time ago
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined,
                  color: Colors.white70, size: 15),
              const SizedBox(width: 4),
              Text(
                '${post.viewsCount} Views',
                style: const TextStyle(
                    fontFamily: 'Rob', fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_rounded,
                  color: Colors.white70, size: 15),
              const SizedBox(width: 4),
              Text(
                post.timeAgo,
                style: const TextStyle(
                    fontFamily: 'Rob', fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Avatar + name + star rating
          Row(
            children: [
              GestureDetector(
                onTap: () => _openPosterProfile(post),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF3A3F47),
                  backgroundImage: post.avatarUrl.isNotEmpty
                      ? NetworkImage(post.avatarUrl)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: GestureDetector(
                  onTap: () => _openPosterProfile(post),
                  child: Text(
                    post.userName,
                    style: const TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _starPill('${post.famaPoints}'),
            ],
          ),
          const SizedBox(height: 10),

          // Rank badges
          Row(
            children: [
              _rankBadge(
                icon: Icons.location_on_outlined,
                label: post.locationName,
              ),
              const SizedBox(width: 10),
              _rankBadge(
                icon: Icons.school_outlined,
                label: post.schoolName,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: _accentColor, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge({required IconData icon, required String label}) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single feed page's video — initializes its own network controller and
/// plays/pauses automatically as [isActive] changes (i.e. as the user
/// swipes between pages, or as the parent pauses it for navigation).
/// Tapping toggles play/pause manually:
/// - Paused: translucent white play icon stays visible until tapped again.
/// - Resumed: play icon disappears immediately.
class _FeedVideoItem extends StatefulWidget {
  const _FeedVideoItem({required this.post, required this.isActive});

  final FeedPost post;
  final bool isActive;

  @override
  State<_FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<_FeedVideoItem> {
  VideoPlayerController? _controller;

  // Controller ke value se derive nahi karte (wo position update par bhi
  // notify karta hai) — apna khud ka flag rakhte hain taake overlay sirf
  // actual pause/play par hi rebuild ho.
  bool _isPaused = false;

  // Video init fail ho jaye (bad URL / network / codec) to yahan true —
  // is se placeholder par retry icon dikhta hai. Isi ke bina page
  // hamesha ke liye dead (grey, non-interactive) reh jata tha.
  bool _hasInitError = false;

  @override
  void initState() {
    super.initState();
    _isPaused = !widget.isActive;
    _initController();
  }

  Future<void> _initController() async {
    if (widget.post.videoUrl.isEmpty) {
      if (mounted) setState(() => _hasInitError = true);
      return;
    }

    final VideoPlayerController controller =
    VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl));

    try {
      await controller.initialize();
      controller.setLooping(true);
    } catch (e) {
      debugPrint(
          'FEED DEBUG -> video init failed for ${widget.post.videoUrl}: $e');
      controller.dispose();
      if (mounted) setState(() => _hasInitError = true);
      return;
    }

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _hasInitError = false;
      if (widget.isActive) {
        controller.play();
        _isPaused = false;
      } else {
        _isPaused = true;
      }
    });
  }

  /// Called when the user taps the retry icon on a failed-to-load video.
  void _retryInit() {
    setState(() => _hasInitError = false);
    _initController();
  }

  @override
  void didUpdateWidget(covariant _FeedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    // Sirf tab react karo jab `isActive` ki value *actually* badli ho —
    // har parent rebuild par nahi (fama tap, share tap, comment count,
    // filter chip — in sab se FeedScreen rebuild hota hai aur
    // didUpdateWidget yahan bhi fire ho jata). Pehle is guard ke bina,
    // agar user ne video ko manually pause kar rakha tha aur post abhi
    // bhi active thi, to har aisi rebuild par video khud-ba-khud resume
    // ho jati thi — is liye pause "kaam nahi kar raha tha" lagta tha.
    if (oldWidget.isActive == widget.isActive) return;

    // Page swipe/navigation par active video ko play aur inactive video
    // ko pause karo.
    if (widget.isActive && !controller.value.isPlaying) {
      controller.play();
      setState(() => _isPaused = false);
    } else if (!widget.isActive && controller.value.isPlaying) {
      controller.pause();
      setState(() => _isPaused = true);
    }
  }

  void _togglePlayPause() {
    final VideoPlayerController? controller = _controller;
    debugPrint(
        'TAP DEBUG -> controller null? ${controller == null}, initialized? ${controller?.value.isInitialized}');
    if (controller == null || !controller.value.isInitialized) return;

    if (!_isPaused) {
      // Pause: icon persistently dikhta rehta hai jab tak dobara tap na ho.
      setState(() => _isPaused = true);
      controller.pause();
    } else {
      // Resume: play call hote hi icon isi frame mein hide ho jata hai.
      setState(() => _isPaused = false);
      controller.play();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;

    // Loading / failed state — ab ye bhi tap-aware hai. Bina init hue
    // pehle is Container mein koi GestureDetector nahi tha, is liye tap
    // bilkul kaam nahi karta tha jab tak video load na ho jaye (ya
    // hamesha ke liye dead reh jata tha agar load hi fail ho jaye).
    if (controller == null || !controller.value.isInitialized) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _hasInitError ? _retryInit : null,
        child: Container(
          color: const Color(0xFF20242B),
          child: Center(
            child: _hasInitError
                ? const Icon(Icons.refresh_rounded,
                color: Colors.white54, size: 32)
                : const CircularProgressIndicator(color: Colors.white38),
          ),
        ),
      );
    }

    return GestureDetector(
      // opaque: FittedBox/IgnorePointer overlay ki wajah se child render
      // object kabhi kabhi hit-test miss kar deta tha (default
      // `deferToChild` behavior), is liye tap kabhi register hi nahi
      // hota tha. opaque poori Stack area ko hit-testable bana deta hai.
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),

          // Pause hone par screen ke bilkul beech mein translucent white
          // circle + play icon dikhta hai (jaisa Instagram/TikTok karte
          // hain); resume hote hi icon foran disappear ho jata hai.
          if (_isPaused)
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
