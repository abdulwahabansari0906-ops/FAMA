import 'package:flutter/material.dart';
import '../widgets/fama_bottom_nav.dart';
import '../Feed_screen/post_now_popup.dart';

class LeaderboardUser {
  final int rank;
  final String name;
  final String image;
  final String stars;

  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.image,
    required this.stars,
  });
}

/// Ranking screen — Celebrities / Videos tabs ke sath leaderboard grid.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);
  static const Color _whatsappColor = Color(0xFF298C4E);
  static const Color _rankBadgeColor = Color(0xFFE12C2C);

  bool _isCelebritiesTab = true;

  // 'Day' | 'Week' | 'Month' | 'All Time'
  String _selectedTimeFilter = 'All Time';

  static const List<LeaderboardUser> _users = [
    LeaderboardUser(rank: 1, name: 'Savannah', image: 'assets/images/f1.png', stars: '365'),
    LeaderboardUser(rank: 2, name: 'Devon Lane', image: 'assets/images/f2.png', stars: '365'),
    LeaderboardUser(rank: 3, name: 'Annette', image: 'assets/images/f3.png', stars: '365'),
    LeaderboardUser(rank: 4, name: 'Janny', image: 'assets/images/f4.png', stars: '365'),
    LeaderboardUser(rank: 5, name: 'Devon Lane', image: 'assets/images/f5.png', stars: '365'),
    LeaderboardUser(rank: 6, name: 'Robert Fox', image: 'assets/images/f6.png', stars: '365'),
    LeaderboardUser(rank: 7, name: 'Annette', image: 'assets/images/f7.png', stars: '365'),
    LeaderboardUser(rank: 8, name: 'Eleanor Pena', image: 'assets/images/f8.png', stars: '365'),
    LeaderboardUser(rank: 9, name: 'Kathryn', image: 'assets/images/f1.png', stars: '365'),
    LeaderboardUser(rank: 10, name: 'Albert Flores', image: 'assets/images/f2.png', stars: '365'),
    LeaderboardUser(rank: 11, name: 'Cameron', image: 'assets/images/f3.png', stars: '365'),
    LeaderboardUser(rank: 12, name: 'Jacob Jones', image: 'assets/images/f4.png', stars: '365'),
    LeaderboardUser(rank: 13, name: 'Hawkins', image: 'assets/images/f5.png', stars: '365'),
    LeaderboardUser(rank: 14, name: 'McKinney', image: 'assets/images/f6.png', stars: '365'),
    LeaderboardUser(rank: 15, name: 'Alexander', image: 'assets/images/f7.png', stars: '365'),
    LeaderboardUser(rank: 16, name: 'Howard', image: 'assets/images/f8.png', stars: '365'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildTabs(),
            _buildFilterDropdowns(),
            const SizedBox(height: 10),
            _buildTimeChips(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildUserRow(_users.sublist(0, 4)),
                    const SizedBox(height: 18),
                    _sectionLabel('Top 4'),
                    const SizedBox(height: 14),
                    _buildUserRow(_users.sublist(4, 8)),
                    const SizedBox(height: 18),
                    _sectionLabel('Top 8'),
                    const SizedBox(height: 14),
                    _buildUserRow(_users.sublist(8, 12)),
                    const SizedBox(height: 18),
                    _buildUserRow(_users.sublist(12, 16)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FamaBottomNav(
        currentIndex: 1,
        onTap: (index) => handleFamaNavTap(context, 1, index),
        onPostTap: () => showPostNowPopup(context),
      ),
    );
  }

  Widget _buildTopBar() {
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
              // Invite button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _whatsappColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:  [
                    Image.asset(
                      'assets/images/whatsapp.png',
                      width: 14,
                      height: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
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
              const SizedBox(width: 8),
              // Star count pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '365',
                      style: TextStyle(
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
              const Icon(Icons.settings_outlined, color: _darkColor, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: _borderColor, height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _tabItem('Celebrities', isSelected: _isCelebritiesTab)),
        Expanded(child: _tabItem('Videos', isSelected: !_isCelebritiesTab)),
      ],
    );
  }

  Widget _tabItem(String label, {required bool isSelected}) {
    return GestureDetector(
      onTap: () => setState(() => _isCelebritiesTab = label == 'Celebrities'),
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
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Rob',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? _darkColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdowns() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(child: _dropdownChip('Location')),
          const SizedBox(width: 8),
          Expanded(child: _dropdownChip('School')),
          const SizedBox(width: 8),
          Expanded(child: _dropdownChip('Gender')),
        ],
      ),
    );
  }

  Widget _dropdownChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Rob',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _darkColor,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _darkColor),
        ],
      ),
    );
  }

  Widget _buildTimeChips() {
    final List<String> filters = ['Day', 'Week', 'Month', 'All Time'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = _selectedTimeFilter == filter;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeFilter = filter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _darkColor : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Rob',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _darkColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),
        ),

      ],
    );
  }

  Widget _buildUserRow(List<LeaderboardUser> users) {
    return Row(
      children: users.map((user) {
        return Expanded(child: _userCard(user));
      }).toList(),
    );
  }

  Widget _userCard(LeaderboardUser user) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFE4E8ED),
              backgroundImage: AssetImage(user.image),
            ),
            Positioned(
              top: -4,
              left: -4,
              child: Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  color: _rankBadgeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${user.rank}',
                    style: const TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          user.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Rob',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _darkColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 13),
            const SizedBox(width: 2),
            Text(
              user.stars,
              style: const TextStyle(
                fontFamily: 'Rob',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}