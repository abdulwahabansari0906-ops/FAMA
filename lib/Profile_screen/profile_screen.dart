import 'package:flutter/material.dart';
import '../widgets/fama_bottom_nav.dart';
import '../Feed_screen/post_now_popup.dart';

class ProfilePost {
  final String image;
  final String stars;
  final String views;

  const ProfilePost({
    required this.image,
    required this.stars,
    required this.views,
  });
}

/// Profile screen — user info, bio, social links, aur post grid (tabs se filter).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);
  static const Color _whatsappColor = Color(0xFF298C4E);

  // 0 = star/all posts, 1 = instagram, 2 = tiktok
  int _selectedTab = 0;

  static const List<ProfilePost> _posts = [
    ProfilePost(image: 'assets/images/p1.jpg', stars: '255', views: '2.5k'),
    ProfilePost(image: 'assets/images/p2.jpg', stars: '255', views: '2.5k'),
    ProfilePost(image: 'assets/images/p3.jpg', stars: '255', views: '2.5k'),
    ProfilePost(image: 'assets/images/p4.jpg', stars: '255', views: '2.5k'),
    ProfilePost(image: 'assets/images/p5.jpg', stars: '255', views: '2.5k'),
    ProfilePost(image: 'assets/images/p6.jpg', stars: '255', views: '2.5k'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildBio(),
                    const SizedBox(height: 16),
                    _buildSocialLinks(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildTabs(),
                    _buildPostGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FamaBottomNav(
        currentIndex: 4,
        onTap: (index) => handleFamaNavTap(context, 4, index),
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

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFE4E8ED),
            backgroundImage: AssetImage('assets/images/f1.png'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Guy Hawkins',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _darkColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _starPill('365'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _rankBadge(icon: Icons.location_on_outlined, label: '#478 In Location'),
                    _rankBadge(icon: Icons.home_outlined, label: '#9,892 In School'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _starPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _darkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _darkColor, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _darkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBio() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Lorem ipsum dolor sit amet consectetur. Odio diam tempus '
            'cras arcu duis diam et. Justo vitae aliquam.',
        style: TextStyle(
          fontFamily: 'Rob',
          fontSize: 13,
          height: 1.4,
          color: Color(0xFF60656B),
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _socialChip(
              icon: Icons.camera_alt_outlined,
              iconColor: const Color(0xFFC13584),
              label: 'Instagram',
              onTap: () {
                // TODO: Instagram profile link kholein
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _socialChip(
              icon: Icons.music_note_rounded,
              iconColor: Colors.black,
              label: 'TikTok',
              onTap: () {
                // TODO: TikTok profile link kholein
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _socialChip(
              icon: Icons.facebook_rounded,
              iconColor: const Color(0xFF1877F2),
              label: 'Facebook',
              onTap: () {
                // TODO: Facebook profile link kholein
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: message screen par navigate karein
                },
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
                      style: TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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
                onPressed: () {
                  // TODO: share sheet kholein
                },
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
                      style: TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _tabItem(icon: Icons.star_rounded, index: 0)),
        Expanded(child: _tabItem(icon: Icons.camera_alt_outlined, index: 1)),
        Expanded(child: _tabItem(icon: Icons.music_note_rounded, index: 2)),
      ],
    );
  }

  Widget _tabItem({required IconData icon, required int index}) {
    final bool isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
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
          icon,
          size: 20,
          color: isSelected ? _darkColor : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final ProfilePost post = _posts[index];

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              post.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE4E8ED),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: _statPill(icon: Icons.star_rounded, value: post.stars),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: _statPill(icon: Icons.play_arrow_rounded, value: post.views),
            ),
          ],
        );
      },
    );
  }

  Widget _statPill({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}