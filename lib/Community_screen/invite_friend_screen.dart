import 'package:fama/Community_screen/whatsapp_invite_screen.dart';
import 'package:fama/Feed_screen/feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services and managers/whatsapp_invite_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';
import '../widgets/fame_stepps_app_bar.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  static const Color _darkColor = Color(0xFF020A16);
  static const Color _whatsappColor = Color(0xFF298C4E);

  static const String _inviteMessage = '''
Join me on FAMA and earn rewards with me!

https://your-invite-link.com
''';

  void _skipStep() {
    // "Signup ke baad seedha bottom nav (FeedScreen) par le jata hai"
    // TODO: agar backend par "onboarding complete" flag save karna ho to yahan call karein
    Get.offAll(() => const FeedScreen());
  }

  Future<bool> _launchExternalUrl(Uri url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// "Invite Friends On WhatsApp" button ka handler — session se phone
  /// number nikaal kar invite API call karta hai aur backend se aaya hua
  /// whatsapp_url open karta hai (WhatsApp ki apni contact list khulti
  /// hai, taake user khud choose kare kise bheja jaye).
  Future<void> _handleInvite() async {
    if (Get.isDialogOpen == true) return; // request already in progress

    final String? phoneNumber = SessionManager.phoneNumber;
    final String? token = SessionManager.accessToken;

    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      AppHelpers.showError('Phone number not found. Please log in again.');
      return;
    }

    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    AppHelpers.showLoader();

    try {
      final InviteResponse invite = await InviteApiService.getInviteLink(
        phoneNumber: phoneNumber,
        token: token,
      );

      final bool opened = await _launchExternalUrl(invite.contactPickerUri);

      AppHelpers.hideLoader();

      if (!opened) {
        AppHelpers.showError('Could not open WhatsApp.');
      }
    } catch (e) {
      AppHelpers.hideLoader();
      debugPrint('Invite error: $e');
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Reusable AppBar
      appBar: FamaStepAppBar(
        actionText: 'Skip',
        onBackTap: () => Get.back(),
        onNextTap: _skipStep,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Heading
                      const Text(
                        'Invite Friends',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 21,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: _darkColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      const Text(
                        'Earn FAMA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _darkColor,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Center Image
                      Image.asset(
                        'assets/images/friend.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        semanticLabel: 'Invite friends',
                      ),

                      const SizedBox(height: 16),

                      // Reward Text
                      const Text(
                        'Earn 5 FAMA Per Invite',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 20,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: _darkColor,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // WhatsApp Invite Button
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 250,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _handleInvite,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _whatsappColor,
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            child: const Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                _WhatsAppIcon(),
                                SizedBox(width: 9),
                                Flexible(
                                  child: Text(
                                    'Invite Friends On WhatsApp',
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Rob',
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// WhatsApp-style icon without external icon package
class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,

      ),
      child: Image.asset("assets/images/whatsapp.png",
        width: 18,height: 18,),
    );
  }
}