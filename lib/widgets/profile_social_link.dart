import 'package:flutter/material.dart';

const Color _darkColor = Color(0xFF020A16);
const Color _borderColor = Color(0xFFE4E8ED);

class ProfileSocialLinks extends StatelessWidget {
  final ValueChanged<String> onTapPlatform; // 'instagram' | 'tiktok' | 'facebook'

  const ProfileSocialLinks({super.key, required this.onTapPlatform});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _SocialChip(
              icon: Icons.camera_alt_outlined,
              iconColor: const Color(0xFFC13584),
              label: 'Instagram',
              onTap: () => onTapPlatform('instagram'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SocialChip(
              icon: Icons.music_note_rounded,
              iconColor: Colors.black,
              label: 'TikTok',
              onTap: () => onTapPlatform('tiktok'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SocialChip(
              icon: Icons.facebook_rounded,
              iconColor: const Color(0xFF1877F2),
              label: 'Facebook',
              onTap: () => onTapPlatform('facebook'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _SocialChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}