import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Message_screen/message_individual_screen.dart';
import '../Profile_screen/full_screen_video_play_screen.dart';
import '../services and managers/profile_service.dart';
import '../services and managers/public_profile_view_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';
import '../widgets/grid_thumb_video.dart';

/// Public (read-only) profile screen — feed me kisi post ke avatar par tap
/// karne se khulta hai. Us user ka bio, socials, rank aur posts grid dikhata
/// hai. POST /api/profile with target_id, token session se aata hai.
class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key, required this.targetId});

  final int targetId;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  ProfileData? _profile;
  bool _isLoading = true;
  bool _loadFailed = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // AppHelpers.showLoader() (GetX dialog) pehle frame ke baad chalana
    // zaroori hai warna "visitChildElements() called during build" crash
    // aata hai.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProfile());
  }

  // ── Fetching ─────────────────────────────────────────────────────────

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    final String? token = SessionManager.accessToken;
    debugPrint('PUBLIC PROFILE DEBUG -> token: $token, targetId: ${widget.targetId}');

    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = 'Session expired. Please log in again.';
      });
      AppHelpers.showError(_errorMessage);
      return;
    }

    AppHelpers.showLoader();
    try {
      final ProfileData profile = await PublicProfileApiService.getProfileByTargetId(
        token: token,
        targetId: widget.targetId,
      );

      AppHelpers.hideLoader();
      debugPrint('PUBLIC PROFILE DEBUG -> loaded user: ${profile.user.name}, posts: ${profile.posts.length}');

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (e) {
      AppHelpers.hideLoader();
      debugPrint('PUBLIC PROFILE DEBUG -> error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      AppHelpers.showError(_errorMessage);
    }
  }

  Future<bool> _launchExternalUrl(Uri url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Handle ya to already-full link ho sakta hai (jaisa backend abhi bhejta
  /// hai) ya sirf username — dono cases handle karta hai.
  Future<void> _openSocialHandle(String? handle, String baseUrl) async {
    if (handle == null || handle.trim().isEmpty) {
      AppHelpers.showError('No link added yet.');
      return;
    }
    final String trimmed = handle.trim();
    final Uri url = trimmed.startsWith('http')
        ? Uri.parse(trimmed)
        : Uri.parse('$baseUrl$trimmed');

    final bool opened = await _launchExternalUrl(url);
    if (!opened) {
      AppHelpers.showError('Could not open link.');
    }
  }

  /// Opens a 1:1 chat with this profile's user.
  void _openMessageScreen(ProfileUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageIndividualScreen(
          name: user.name.isNotEmpty ? user.name : 'User',
          image: user.avatarUrl ?? '',
          recipientId: widget.targetId,
        ),
      ),
    );
  }

  /// Opens the native share sheet with a link to this profile.
  ///
  /// NOTE: the link format below is a placeholder — replace it with your
  /// actual public profile URL scheme once you have one.
  Future<void> _shareProfile(ProfileUser user) async {
    final String displayName = user.name.isNotEmpty ? user.name : 'this profile';
    final String link = 'https://fama.digitalpreps.com/profile/${widget.targetId}';

    try {
      await Share.share('Check out $displayName on FAMA!\n$link');
    } catch (e) {
      debugPrint('Share profile error: $e');
      AppHelpers.showError('Could not open the share sheet.');
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _darkColor,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Rob',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _darkColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final ProfileData? profile = _profile;

    if (_isLoading && profile == null) {
      // Sirf AppHelpers ka apna loader dikhta hai, koi default spinner nahi.
      return const SizedBox.shrink();
    }

    if (_loadFailed && profile == null) {
      return Center(
        child: TextButton(
          onPressed: _fetchProfile,
          child: Text(
            '$_errorMessage\nTap to retry.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF60656B)),
          ),
        ),
      );
    }

    if (profile == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _fetchProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildProfileHeader(profile),
            const SizedBox(height: 16),
            _buildBio(profile),
            const SizedBox(height: 16),
            _buildSocialLinks(profile),
            const SizedBox(height: 16),
            _buildActionButtons(profile),
            const SizedBox(height: 20),
            const Divider(color: _borderColor, height: 1),
            _buildPostGrid(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileData profile) {
    final ProfileUser user = profile.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFE4E8ED),
            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: _darkColor, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name.isNotEmpty ? user.name : 'Unnamed',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _darkColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _starPill('${user.famaPoints}'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _rankBadge(
                      icon: Icons.location_on_outlined,
                      label: '#${profile.locationRank} In ${user.locationName}',
                    ),
                    _rankBadge(
                      icon: Icons.home_outlined,
                      label: '#${profile.schoolRank} In ${user.schoolName}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _starPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _darkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _darkColor, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _darkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBio(ProfileData profile) {
    final String? bio = profile.user.bio;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        (bio != null && bio.trim().isNotEmpty) ? bio : 'No bio added yet.',
        style: const TextStyle(
          fontFamily: 'Rob',
          fontSize: 13,
          height: 1.4,
          color: Color(0xFF60656B),
        ),
      ),
    );
  }

  Widget _buildSocialLinks(ProfileData profile) {
    final ProfileUser user = profile.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _socialChip(
              icon: Icons.camera_alt_outlined,
              iconColor: const Color(0xFFC13584),
              label: 'Instagram',
              onTap: () => _openSocialHandle(
                user.instagramHandle,
                'https://instagram.com/',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _socialChip(
              icon: Icons.music_note_rounded,
              iconColor: Colors.black,
              label: 'TikTok',
              onTap: () => _openSocialHandle(
                user.tiktokHandle,
                'https://tiktok.com/@',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _socialChip(
              icon: Icons.facebook_rounded,
              iconColor: const Color(0xFF1877F2),
              label: 'Facebook',
              onTap: () => _openSocialHandle(
                user.facebookHandle,
                'https://facebook.com/',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Message + Share row — same style as the logged-in user's own profile.
  Widget _buildActionButtons(ProfileData profile) {
    final ProfileUser user = profile.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => _openMessageScreen(user),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _darkColor,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline_rounded, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Message',
                      style: TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => _shareProfile(user),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkColor,
                  side: const BorderSide(color: _borderColor),
                  shape: const StadiumBorder(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.reply, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _darkColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostGrid(ProfileData profile) {
    final List<ProfilePostApi> posts = profile.posts;

    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No posts yet.',
            style: TextStyle(
              fontFamily: 'Rob',
              fontSize: 13,
              color: Color(0xFF60656B),
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final ProfilePostApi post = posts[index];

        return GestureDetector(
          onTap: () {
            if (post.videoUrl.isEmpty) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenVideoPlayer(videoUrl: post.videoUrl),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty)
                Image.network(
                  post.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE4E8ED),
                    child: const Icon(Icons.play_circle_outline, color: _darkColor),
                  ),
                )
              else
                GridVideoThumb(videoUrl: post.videoUrl),
              Positioned(
                left: 8,
                bottom: 8,
                child: _statPill(icon: Icons.star_rounded, value: '${post.famaPoints}'),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: _statPill(icon: Icons.play_arrow_rounded, value: '${post.viewsCount}'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statPill({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}