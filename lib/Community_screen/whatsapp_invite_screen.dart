import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services and managers/session_manager.dart';
import '../services and managers/whatsapp_invite_service.dart';
import '../widgets/fame_stepps_app_bar.dart';
import '../widgets/app_helper.dart';


class WhatsAppInviteScreen extends StatefulWidget {
  const WhatsAppInviteScreen({super.key});

  @override
  State<WhatsAppInviteScreen> createState() =>
      _WhatsAppInviteScreenState();
}

class _WhatsAppInviteScreenState
    extends State<WhatsAppInviteScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);
  static const Color _whatsappColor = Color(0xFF298C4E);

  String _searchQuery = '';

  static const List<InviteFriend> _friends = [
    InviteFriend(
      name: 'Devon Lane',
      image: 'assets/images/f1.png',
    ),
    InviteFriend(
      name: 'Savannah Nguyen',
      image: 'assets/images/f2.png',
    ),
    InviteFriend(
      name: 'Annette Black',
      image: 'assets/images/f3.png',
    ),
    InviteFriend(
      name: 'Jenny Wilson',
      image: 'assets/images/f4.png',
    ),
    InviteFriend(
      name: 'Darrell Steward',
      image: 'assets/images/f5.png',
    ),
    InviteFriend(
      name: 'Janny Lorene',
      image: 'assets/images/f6.png',
    ),
    InviteFriend(
      name: 'Annette Black',
      image: 'assets/images/f7.png',
    ),
    InviteFriend(
      name: 'Jenny Wilson',
      image: 'assets/images/f8.png',
    ),
  ];

  List<InviteFriend> get _filteredFriends {
    final String query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _friends;
    }

    return _friends.where((friend) {
      return friend.name.toLowerCase().contains(query);
    }).toList();
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

  /// Fetches the phone number from the session, calls the invite API,
  /// and opens the WhatsApp URL returned by the backend.
  ///
  /// Shows a blocking loader while the request is in flight, and a
  /// success/error snackbar via [AppHelpers] once it completes.
  Future<void> _openWhatsApp(
      BuildContext context, {
        InviteFriend? friend,
      }) async {
    if (Get.isDialogOpen == true) return; // request already in progress

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
      final InviteResponse invite = await InviteApiService.getInviteLink(
        phoneNumber: phoneNumber,
        token: token,
      );

      // Opens WhatsApp's own contact/chat list with the invite message
      // pre-filled, so the user picks who to send it to.
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
    final List<InviteFriend> friends = _filteredFriends;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: FamaStepAppBar(
        showNextButton: false,
        onBackTap: () => Get.back(),
        onNextTap: () {},
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                10,
              ),
              child: SizedBox(
                height: 48,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  cursorColor: _darkColor,
                  cursorHeight: 18,
                  style: const TextStyle(
                    fontFamily: 'Rob',
                    fontSize: 14,
                    color: _darkColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 14,
                      color: Color(0xFF656A70),
                    ),
                    isDense: true,
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF30363D),
                    ),
                    prefixIconConstraints:
                    const BoxConstraints(
                      minWidth: 40,
                      minHeight: 48,
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    enabledBorder: _searchBorder(),
                    focusedBorder: _searchBorder(
                      color: _darkColor,
                    ),
                  ),
                ),
              ),
            ),

            // Friends List
            Expanded(
              child: friends.isEmpty
                  ? const Center(
                child: Text(
                  'No friends found',
                  style: TextStyle(
                    fontFamily: 'Rob',
                    fontSize: 14,
                    color: Color(0xFF656A70),
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final InviteFriend friend =
                  friends[index];

                  return Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border(
                        top: index == 0
                            ? const BorderSide(
                          color: _borderColor,
                        )
                            : BorderSide.none,
                        bottom: const BorderSide(
                          color: _borderColor,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Profile Image
                        ClipOval(
                          child: Image.asset(
                            friend.image,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) {
                              return Container(
                                width: 38,
                                height: 38,
                                color: const Color(
                                  0xFFF0F1F3,
                                ),
                                alignment:
                                Alignment.center,
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: _darkColor,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            friend.name,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Rob',
                              fontSize: 13,
                              color: _darkColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Individual Invite Button
                        SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: () {
                              _openWhatsApp(
                                context,
                                friend: friend,
                              );
                            },
                            style:
                            ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                              _darkColor,
                              foregroundColor:
                              Colors.white,
                              minimumSize:
                              const Size(54, 28),
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              tapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap,
                              shape:
                              const StadiumBorder(),
                            ),
                            child: const Text(
                              'Invite',
                              style: TextStyle(
                                fontFamily: 'Rob',
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom WhatsApp Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _openWhatsApp(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _whatsappColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _WhatsAppIcon(),
                    SizedBox(width: 9),
                    Text(
                      'Send Whatsapp Invite',
                      style: TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _searchBorder({
    Color color = _borderColor,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: color,
        width: 1,
      ),
    );
  }
}

class InviteFriend {
  const InviteFriend({
    required this.name,
    required this.image,
  });

  final String name;
  final String image;
}

class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 19,
      height: 19,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        "assets/images/whatsapp.png",
        width: 18,
        height: 18,
      ),
    );
  }
}