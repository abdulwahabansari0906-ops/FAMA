import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isMe;

  const ChatMessage({required this.text, required this.isMe});
}

/// Individual chat screen — ek user ke sath conversation.
class MessageIndividualScreen extends StatefulWidget {
  final String name;
  final String image;

  const MessageIndividualScreen({
    super.key,
    required this.name,
    required this.image,
  });

  @override
  State<MessageIndividualScreen> createState() => _MessageIndividualScreenState();
}

class _MessageIndividualScreenState extends State<MessageIndividualScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  final TextEditingController _messageController = TextEditingController();

  final List<ChatMessage> _messages = const [
    ChatMessage(text: 'Hi...!', isMe: true),
    ChatMessage(text: 'Hello, How are you, today?', isMe: false),
    ChatMessage(text: "I'm fine!🥰 What about you?", isMe: true),
    ChatMessage(text: 'Everything is good😊', isMe: false),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
      _messageController.clear();
    });
    // TODO: message ko backend/socket ke through bhejein
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: const Border(bottom: BorderSide(color: _borderColor, width: 1)),
          leadingWidth: 90,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              height: 32,
              width: 74,
              decoration: BoxDecoration(
                color: _darkColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                    SizedBox(width: 2),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE4E8ED),
                backgroundImage: AssetImage(widget.image),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Rob',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _darkColor,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: chat options (block/report/mute) dikhayein
              },
              icon: const Icon(Icons.more_vert, color: _darkColor),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _messageBubble(_messages[index]),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessage message) {
    final Alignment alignment = message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = message.isMe ? _darkColor : const Color(0xFFF0F1F3);
    final Color textColor = message.isMe ? Colors.white : _darkColor;

    final CircleAvatar avatar = CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFFE4E8ED),
      backgroundImage: AssetImage(widget.image),
    );

    final Widget bubble = Container(
      constraints: const BoxConstraints(maxWidth: 220),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          fontFamily: 'Rob',
          fontSize: 13,
          color: textColor,
        ),
      ),
    );

    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: message.isMe
            ? [bubble, const SizedBox(width: 6), avatar]
            : [avatar, const SizedBox(width: 6), bubble],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _borderColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                cursorColor: _darkColor,
                style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: _darkColor),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFF60656B)),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _darkColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Send',
                style: TextStyle(fontFamily: 'Rob', fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}