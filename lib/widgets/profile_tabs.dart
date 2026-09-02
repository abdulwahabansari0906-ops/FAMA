import 'package:flutter/material.dart';

const Color _darkColor = Color(0xFF020A16);

class ProfileTabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const ProfileTabs({super.key, required this.selectedTab, required this.onTabSelected});

  static const List<IconData> _icons = [
    Icons.star_rounded,
    Icons.camera_alt_outlined,
    Icons.music_note_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_icons.length, (index) {
        final bool isSelected = selectedTab == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? _darkColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Icon(
                _icons[index],
                size: 20,
                color: isSelected ? _darkColor : Colors.grey,
              ),
            ),
          ),
        );
      }),
    );
  }
}