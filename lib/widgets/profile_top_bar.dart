import 'package:flutter/material.dart';

const Color _darkColor = Color(0xFF020A16);
const Color _borderColor = Color(0xFFE4E8ED);
const Color _whatsappColor = Color(0xFF298C4E);

/// Top bar: FAMA logo, Invite button, points pill,
/// settings and logout icons.
class ProfileTopBar extends StatelessWidget {
  final int famaPoints;
  final VoidCallback onInviteTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const ProfileTopBar({
    super.key,
    required this.famaPoints,
    required this.onInviteTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  Future<void> _showLogoutDialog(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          // Center title
          title: const Text(
            'Logout',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,fontFamily: "Rob",
              fontWeight: FontWeight.w700,
              color: _darkColor,
            ),
          ),

          // Center message
          content: const Text(
            'Are you sure you want to logout?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Rob",
              fontWeight: FontWeight.w400,
              color: Color(0xFF5A6472),
            ),
          ),

          // Center buttons
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: _darkColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,fontFamily: "Rob",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,fontFamily: "Rob",
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      onLogoutTap();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC839),
                size: 20,
              ),
              const SizedBox(width: 4),
              const Text(
                'FAMA',
                style: TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _darkColor,
                ),
              ),
              const Spacer(),

              // Invite button
              GestureDetector(
                onTap: onInviteTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _whatsappColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/whatsapp.png',
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Invite',
                        style: TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // FAMA points
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFC839),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$famaPoints',
                      style: const TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _darkColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Settings
              GestureDetector(
                onTap: onSettingsTap,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.settings_outlined,
                    color: _darkColor,
                    size: 22,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Logout
              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.logout_rounded,
                    color: _darkColor,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(
          color: _borderColor,
          height: 1,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}