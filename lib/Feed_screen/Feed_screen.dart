import 'package:flutter/material.dart';
import '../widgets/fama_bottom_nav.dart';
import 'post_now_popup.dart';

/// TikTok-style main newsfeed — fullscreen video/image post ke upar
/// filters, engagement actions aur creator info overlay hota hai.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const Color _accentColor = Color(0xFFFFC839);

  // 'All' | 'Location' | 'School'
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background post image / video thumbnail
          // TODO: is Image.asset ki jagah apna video player / PageView.builder
          // lagayein taake TikTok jaisa vertical swipe feed bane.
          Image.asset(
            'assets/images/feed_post_1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF20242B),
            ),
          ),

          // Bottom fade for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.75),
                ],
                stops: const [0.55, 1],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopFilters(),
                const Spacer(),
                _buildBottomInfo(),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Right side action buttons
          Positioned(
            right: 12,
            bottom: 128,
            child: Column(
              children: [
                _actionButton(icon: Icons.reply, count: '2.5k'),
                const SizedBox(height: 18),
                _actionButton(icon: Icons.star_border_rounded, count: '2.5k'),
                const SizedBox(height: 18),
                _actionButton(icon: Icons.chat_bubble_outline_rounded, count: '181'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FamaBottomNav(
        currentIndex: 0,
        onTap: (index) => handleFamaNavTap(context, 0, index),
        onPostTap: () => showPostNowPopup(context),
      ),
    );
  }

  Widget _buildTopFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _filterChip('All'),
          const SizedBox(width: 8),
          _filterChip('Location'),
          const SizedBox(width: 8),
          _filterChip('School'),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.35) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white70, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Rob',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String count}) {
    return Column(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontFamily: 'Rob',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Views + time ago
          Row(
            children: const [
              Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 15),
              SizedBox(width: 4),
              Text(
                '9k Views',
                style: TextStyle(fontFamily: 'Rob', fontSize: 12, color: Colors.white70),
              ),
              SizedBox(width: 14),
              Icon(Icons.access_time_rounded, color: Colors.white70, size: 15),
              SizedBox(width: 4),
              Text(
                '3 Hrs Ago',
                style: TextStyle(fontFamily: 'Rob', fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Avatar + name + star rating, and rank badges
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF3A3F47),
                backgroundImage: AssetImage('assets/images/f3.png'),
              ),
              const SizedBox(width: 10),
              const Text(
                'Annette Black',
                style: TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              _starPill('365'),
            ],
          ),
          const SizedBox(height: 10),

          // Rank badges
          Row(
            children: [
              _rankBadge(icon: Icons.location_on_outlined, label: '#345 In Location'),
              const SizedBox(width: 10),
              _rankBadge(icon: Icons.school_outlined, label: '#57 In School'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: _accentColor, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}