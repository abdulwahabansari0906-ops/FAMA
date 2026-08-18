import 'package:flutter/material.dart';
import '../widgets/fama_bottom_nav.dart';
import '../Feed_screen/post_now_popup.dart';
import 'message_individual_screen.dart';

class ChatPreview {
  final String name;
  final String image;
  final String stars;
  final String lastMessage;

  const ChatPreview({
    required this.name,
    required this.image,
    required this.stars,
    required this.lastMessage,
  });
}

/// Messages list screen — sab conversations ek list mein.
class MessagesMainScreen extends StatelessWidget {
  const MessagesMainScreen({super.key});

  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);
  static const Color _whatsappColor = Color(0xFF298C4E);

  static const List<ChatPreview> _chats = [
    ChatPreview(
      name: 'Savannah Nguyen',
      image: 'assets/images/f1.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
    ChatPreview(
      name: 'Devon Lane',
      image: 'assets/images/f2.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
    ChatPreview(
      name: 'Annette Black',
      image: 'assets/images/f3.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
    ChatPreview(
      name: 'Jenny Wilson',
      image: 'assets/images/f4.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
    ChatPreview(
      name: 'Darrell Steward',
      image: 'assets/images/f5.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
    ChatPreview(
      name: 'Janny Lorene',
      image: 'assets/images/f6.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
    ChatPreview(
      name: 'Annette Black',
      image: 'assets/images/f7.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
    ChatPreview(
      name: 'Jenny Wilson',
      image: 'assets/images/f8.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
    ChatPreview(
      name: 'Darlene Robertson',
      image: 'assets/images/f9.png',
      stars: '365',
      lastMessage: 'Lorem ipsum dolor sit amet consectetur...',
    ),
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
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _chats.length,
                separatorBuilder: (context, index) =>
                const Divider(height: 1, color: _borderColor),
                itemBuilder: (context, index) => _chatTile(context, _chats[index]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FamaBottomNav(
        currentIndex: 3,
        onTap: (index) => handleFamaNavTap(context, 3, index),
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

  Widget _chatTile(BuildContext context, ChatPreview chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageIndividualScreen(
              name: chat.name,
              image: chat.image,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE4E8ED),
              backgroundImage: AssetImage(chat.image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          chat.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Rob',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _darkColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _starPill(chat.stars),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 12,
                      color: Color(0xFF60656B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _starPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 12),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _darkColor,
            ),
          ),
        ],
      ),
    );
  }
}