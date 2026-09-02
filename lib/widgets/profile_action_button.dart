import 'package:flutter/material.dart';

const Color _darkColor = Color(0xFF020A16);
const Color _borderColor = Color(0xFFE4E8ED);

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onMessageTap;
  final VoidCallback onShareTap;

  const ProfileActionButtons({
    super.key,
    required this.onMessageTap,
    required this.onShareTap,
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
                  shape: const StadiumBorder(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline_rounded, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Message',
                      style: TextStyle(fontFamily: 'Rob', fontSize: 13, fontWeight: FontWeight.w600),
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
                onPressed: onShareTap,
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
                      style: TextStyle(fontFamily: 'Rob', fontSize: 13, fontWeight: FontWeight.w600),
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
}