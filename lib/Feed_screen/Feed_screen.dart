import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services and managers/feed_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';
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
    debugPrint('FEED DEBUG -> token: $token');

    if (token == null || token.trim().isEmpty) {
      // IMPORTANT: pehle yahan sirf toast dikha ke return ho raha tha,
      // isLoading/_initialLoadFailed update nahi hota tha -> screen hamesha
      // ke liye blank reh jaati thi (sirf top filters dikhte thay).
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
        _initialLoadFailed = posts.isEmpty; // empty ho to bhi feedback dikhao
        _errorMessage = posts.isEmpty ? 'No posts found yet.' : '';
      });
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
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    if (index >= _posts.length - 3) {
      _loadMore();
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
    return Stack(
      fit: StackFit.expand,
      children: [
        _FeedVideoItem(post: post, isActive: isActive),

        // Bottom fade for text readability
        Container(
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
              _actionButton(icon: Icons.reply, count: '${post.sharesCount}'),
              const SizedBox(height: 18),
              _actionButton(
                icon: Icons.star_border_rounded,
                count: '${post.famaPoints}',
              ),
              const SizedBox(height: 18),
              _actionButton(
                icon: Icons.chat_bubble_outline_rounded,
                count: post.allowComments ? '0' : '—',
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
          color: isSelected ? Colors.white.withOpacity(0.35) : Colors.transparent,
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
      padding: const EdgeInsets.only(right: 10,left: 10,bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Views + time ago
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 15),
              const SizedBox(width: 4),
              Text(
                '${post.viewsCount} Views',
                style: const TextStyle(fontFamily: 'Rob', fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_rounded, color: Colors.white70, size: 15),
              const SizedBox(width: 4),
              Text(
                post.timeAgo,
                style: const TextStyle(fontFamily: 'Rob', fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Avatar + name + star rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF3A3F47),
                backgroundImage: post.avatarUrl.isNotEmpty
                    ? NetworkImage(post.avatarUrl)
                    : null,
              ),
              const SizedBox(width: 10),
              Flexible(
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
/// swipes between pages).
class _FeedVideoItem extends StatefulWidget {
  const _FeedVideoItem({required this.post, required this.isActive});

  final FeedPost post;
  final bool isActive;

  @override
  State<_FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<_FeedVideoItem> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    if (widget.post.videoUrl.isEmpty) return;

    final VideoPlayerController controller =
    VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl));

    try {
      await controller.initialize();
      controller.setLooping(true);
    } catch (e) {
      debugPrint('FEED DEBUG -> video init failed for ${widget.post.videoUrl}: $e');
      controller.dispose();
      return;
    }

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() => _controller = controller);
    if (widget.isActive) controller.play();
  }

  @override
  void didUpdateWidget(covariant _FeedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (widget.isActive && !controller.value.isPlaying) {
      controller.play();
    } else if (!widget.isActive && controller.value.isPlaying) {
      controller.pause();
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
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: const Color(0xFF20242B));
    }

    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}