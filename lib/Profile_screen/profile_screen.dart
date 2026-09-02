import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services and managers/whatsapp_invite_service.dart';
import '../services and managers/profile_service.dart';
import '../services and managers/rank_service.dart';
import '../services and managers/logout_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';
import '../widgets/fama_bottom_nav.dart';
import '../Feed_screen/post_now_popup.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/profile_bio.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_logout_dialogue.dart';
import '../widgets/profile_post_grid.dart';
import '../widgets/profile_social_link.dart';
import '../widgets/profile_tabs.dart';
import '../widgets/profile_top_bar.dart';
import 'edit_profile_screen.dart';

/// Profile screen — sirf state hold karta hai aur alag-alag widgets ko
/// call karta hai. UI ka actual code widgets/profile/ me hai.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  ProfileData? _profile;
  RankData? _rank;

  bool _isLoading = true;
  bool _loadFailed = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // ── Fetching ─────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadFailed = false;
        _errorMessage = '';
      });
    }

    final String? token = SessionManager.accessToken;

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
      // Profile is required, so its error will show the retry screen.
      final ProfileData profile =
      await ProfileApiService.getProfile(token: token);

      // Rank failure should not stop the complete profile from loading.
      RankData? rank;

      try {
        rank = await RankApiService.getUserRank(token: token);
      } catch (error) {
        debugPrint('Rank API error: $error');
      }

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _rank = rank;
        _isLoading = false;
        _loadFailed = false;
        _errorMessage = '';
      });
    } catch (error) {
      if (!mounted) return;

      final String message =
      error.toString().replaceFirst('Exception: ', '');

      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = message;
      });

      AppHelpers.showError(message);
    } finally {
      AppHelpers.hideLoader();
    }
  }

  Future<void> _handleLogout() async {
    AppHelpers.showLoader();

    try {
      final String message = await LogoutService.logout();

      await SessionManager.clear();

      AppHelpers.hideLoader();
      AppHelpers.showSuccess(message);
      SessionManager.logout();
    } catch (error) {
      await SessionManager.clear();

      AppHelpers.hideLoader();
      SessionManager.logout();
    }
  }

  Future<bool> _launchExternalUrl(Uri url) async {
    try {
      return await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleTopBarInvite() async {
    if (Get.isDialogOpen == true) return;

    final String? phoneNumber = SessionManager.phoneNumber;
    final String? token = SessionManager.accessToken;

    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      AppHelpers.showError(
        'Phone number not found. Please log in again.',
      );
      return;
    }

    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError(
        'Session expired. Please log in again.',
      );
      return;
    }

    AppHelpers.showLoader();

    try {
      final InviteResponse invite =
      await InviteApiService.getInviteLink(
        phoneNumber: phoneNumber,
        token: token,
      );

      final bool opened =
      await _launchExternalUrl(invite.contactPickerUri);

      AppHelpers.hideLoader();

      if (!opened) {
        AppHelpers.showError('Could not open WhatsApp.');
      }
    } catch (error) {
      AppHelpers.hideLoader();

      AppHelpers.showError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _openSocialPlatform(String platform) async {
    final ProfileUser? user = _profile?.user;

    if (user == null) return;

    String? handle;
    String baseUrl;

    switch (platform) {
      case 'instagram':
        handle = user.instagramHandle;
        baseUrl = 'https://instagram.com/';
        break;

      case 'tiktok':
        handle = user.tiktokHandle;
        baseUrl = 'https://tiktok.com/@';
        break;

      case 'facebook':
      default:
        handle = user.facebookHandle;
        baseUrl = 'https://facebook.com/';
        break;
    }

    if (handle == null || handle.trim().isEmpty) {
      AppHelpers.showError('No link added yet.');
      return;
    }

    final Uri url = Uri.parse(
      '$baseUrl${handle.trim()}',
    );

    final bool opened = await _launchExternalUrl(url);

    if (!opened) {
      AppHelpers.showError('Could not open link.');
    }
  }

  Future<void> _openEditProfile() async {
    final ProfileData? updated =
    await Navigator.push<ProfileData>(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (updated == null || !mounted) return;

    final ProfileData? existing = _profile;

    setState(() {
      _profile = ProfileData(
        user: updated.user,
        locationRank: updated.locationRank,
        schoolRank: updated.schoolRank,
        posts: existing?.posts ?? updated.posts,
      );
    });
  }

  // ── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ProfileTopBar(
              famaPoints:
              _rank?.famaPoints ??
                  _profile?.user.famaPoints ??
                  0,
              onInviteTap: _handleTopBarInvite,
              onSettingsTap: _openEditProfile,
              onLogoutTap: () {
                showLogoutDialog(
                  context,
                  _handleLogout,
                );
              },
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FamaBottomNav(
        currentIndex: 4,
        onTap: (index) {
          handleFamaNavTap(
            context,
            4,
            index,
          );
        },
        onPostTap: () {
          showPostNowPopup(context);
        },
      ),
    );
  }

  Widget _buildBody() {
    final ProfileData? profile = _profile;

    if (_isLoading && profile == null) {
      return const SizedBox.shrink();
    }

    if (_loadFailed && profile == null) {
      return Center(
        child: TextButton(
          onPressed: _loadData,
          child: Text(
            '$_errorMessage\nTap to retry.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF60656B),
            ),
          ),
        ),
      );
    }

    if (profile == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ProfileHeader(
              user: profile.user,
              overallRank: _rank?.overallRank ?? 0,
              locationRank:
              _rank?.locationRank ??
                  profile.locationRank,
              schoolRank:
              _rank?.schoolRank ??
                  profile.schoolRank,
              famaPoints:
              _rank?.famaPoints ??
                  profile.user.famaPoints,
            ),
            const SizedBox(height: 16),
            ProfileBio(
              bio: profile.user.bio,
            ),
            const SizedBox(height: 16),
            ProfileSocialLinks(
              onTapPlatform: _openSocialPlatform,
            ),
            const SizedBox(height: 16),
            ProfileActionButtons(
              onMessageTap: () {
                // TODO: message screen par navigate karein
              },
              onShareTap: () {
                // TODO: share sheet kholein
              },
            ),
            const SizedBox(height: 16),
            ProfileTabs(
              selectedTab: _selectedTab,
              onTabSelected: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
            ),
            ProfilePostGrid(
              posts: profile.posts,
            ),
          ],
        ),
      ),
    );
  }
}