import 'package:flutter/material.dart';
import '../Feed_screen/feed_screen.dart';
import '../Ranking_screen/ranking_screen.dart';
import '../Message_screen/messages_main_screen.dart';
import '../Profile_screen/profile_screen.dart';

/// FamaBottomNav ke onTap se call karo — 4 tabs ke beech navigate karta hai.
/// currentScreenIndex de kar current screen par dobara navigate hone se bachta hai.
void handleFamaNavTap(BuildContext context, int currentScreenIndex, int tappedIndex) {
  if (tappedIndex == currentScreenIndex) return;

  late final Widget destination;
  switch (tappedIndex) {
    case 0:
      destination = const FeedScreen();
      break;
    case 1:
      destination = const RankingScreen();
      break;
    case 3:
      destination = const MessagesMainScreen();
      break;
    case 4:
      destination = const ProfileScreen();
      break;
    default:
      return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => destination),
  );
}

/// FAMA app ka reusable bottom navigation bar.
/// 5 tabs: Feed, Ranking, Post (center highlighted button), Message, Profile.
///
/// Usage:
/// ```dart
/// bottomNavigationBar: FamaBottomNav(
///   currentIndex: 0, // 0=Feed, 1=Ranking, 3=Message, 4=Profile
///   onTap: (index) { ... },
///   onPostTap: () => showPostNowPopup(context),
/// ),
/// ```
class FamaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final VoidCallback? onPostTap;

  const FamaBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.onPostTap,
  });

  static const Color _bgColor = Color(0xFF020A16);
  static const Color _accentColor = Color(0xFFFFC839);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(
              icon: Icons.star_border_rounded,
              activeIcon: Icons.star_rounded,
              label: 'Feed',
              index: 0,
            ),
            _navItem(
              icon: Icons.emoji_events_outlined,
              activeIcon: Icons.emoji_events,
              label: 'Ranking',
              index: 1,
            ),
            _postButton(),
            _navItem(
              icon: Icons.mail_outline_rounded,
              activeIcon: Icons.mail_rounded,
              label: 'Message',
              index: 3,
            ),
            _navItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;
    final Color color = isActive ? Colors.white : Colors.white54;

    return GestureDetector(
      onTap: () => onTap?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? activeIcon : icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Rob',
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _postButton() {
    return GestureDetector(
      onTap: onPostTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accentColor, width: 2.5),
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 24),
      ),
    );
  }
}