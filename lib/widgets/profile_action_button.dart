import 'package:flutter/material.dart';

const Color _darkColor = Color(0xFF020A16);
const Color _borderColor = Color(0xFFE4E8ED);

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onMessageTap;
  final VoidCallback onShareTap;
  final VoidCallback onReportTap;

  const ProfileActionButtons({
    super.key,
    required this.onMessageTap,
    required this.onShareTap,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onMessageTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _darkColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: const StadiumBorder(),
                ),
                child: _buttonContent(
                  icon: Icons.mail_outline_rounded,
                  label: 'Message',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: onShareTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  side: const BorderSide(color: _borderColor),
                  shape: const StadiumBorder(),
                ),
                child: _buttonContent(
                  icon: Icons.reply,
                  label: 'Share',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onReportTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: const StadiumBorder(),
                ),
                child: _buttonContent(
                  icon: Icons.flag_outlined,
                  label: 'Your Reports',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonContent({
    required IconData icon,
    required String label,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}