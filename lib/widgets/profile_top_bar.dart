import 'package:flutter/material.dart';

const Color _darkColor = Color(0xFF020A16);
const Color _borderColor = Color(0xFFE4E8ED);
const Color _whatsappColor = Color(0xFF298C4E);

/// Top bar: FAMA logo, Invite button, points pill, settings & logout icons.
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 20),
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
              GestureDetector(
                onTap: onInviteTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _whatsappColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/whatsapp.png', width: 14, height: 14),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 14),
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
              GestureDetector(
                onTap: onSettingsTap,
                child: const Icon(Icons.settings_outlined, color: _darkColor, size: 22),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onLogoutTap,
                child: const Icon(Icons.logout_rounded, color: _darkColor, size: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: _borderColor, height: 1),
        const SizedBox(height: 8),
      ],
    );
  }
}