import 'package:flutter/material.dart';
import '../services and managers/conversation_apis_services.dart';
import '../services and managers/profile_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';

/// Individual chat screen — ek user ke sath conversation.
class MessageIndividualScreen extends StatefulWidget {
  final String name;
  final String image;

  /// The other user's id — used to start/find the conversation.
  final int recipientId;

  const MessageIndividualScreen({
    super.key,
    required this.name,
    required this.image,
    required this.recipientId,
  });

  @override
  State<MessageIndividualScreen> createState() => _MessageIndividualScreenState();
}

class _MessageIndividualScreenState extends State<MessageIndividualScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _conversationId;
  List<ChatMessageApi> _messages = [];
  bool _isSending = false;

  // NEW: current logged-in user's own avatar url.
  String? _myAvatarUrl;

  @override
  void initState() {
    super.initState();
    // AppHelpers.showLoader() (GetX dialog) pehle frame ke baad chalana
    // zaroori hai warna "visitChildElements() called during build" crash
    // aata hai.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startConversation());
    _loadMyProfile();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Apni (logged-in user ki) profile pic ek baar fetch karke state mein
  /// rakh leta hai — taake har bubble build pe API call na karni pade.
  Future<void> _loadMyProfile() async {
    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) return;

    try {
      final ProfileData profile = await ProfileApiService.getProfile(token: token);
      if (!mounted) return;
      setState(() {
        _myAvatarUrl = profile.user.avatarUrl;
      });
    } catch (e) {
      debugPrint('My profile fetch error: $e');
      // Silent fail — sirf fallback icon dikhega, chat kaam karti rahegi.
    }
  }

  /// Recipient (jisko message bheja ja raha hai) ki avatar image.
  ImageProvider? get _avatarImage {
    if (widget.image.isEmpty) return null;
    return widget.image.startsWith('http')
        ? NetworkImage(widget.image)
        : AssetImage(widget.image) as ImageProvider;
  }

  /// Current logged-in user (mai khud) ki avatar image.
  ImageProvider? get _myAvatarImage {
    final String? img = _myAvatarUrl;
    if (img == null || img.trim().isEmpty) return null;
    return img.startsWith('http')
        ? NetworkImage(img)
        : AssetImage(img) as ImageProvider;
  }

  // ── Conversation setup + message list ──────────────────────────────

  Future<void> _startConversation() async {
    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    AppHelpers.showLoader();
    try {
      final int conversationId = await ConversationApiService.getOrCreateConversation(
        token: token,
        recipientId: widget.recipientId,
      );

      final List<ChatMessageApi> messages = await ConversationApiService.getMessages(
        token: token,
        conversationId: conversationId,
      );

      AppHelpers.hideLoader();
      if (!mounted) return;
      setState(() {
        _conversationId = conversationId;
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      AppHelpers.hideLoader();
      debugPrint('Conversation start error: $e');
      if (!mounted) return;
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Re-fetches the message list — used for pull-to-refresh and right
  /// after sending a message. Silent on failure (no loader/snackbar),
  /// since it's a background refresh and shouldn't interrupt the user.
  Future<void> _refreshMessages() async {
    final int? conversationId = _conversationId;
    final String? token = SessionManager.accessToken;
    if (conversationId == null || token == null || token.trim().isEmpty) return;

    try {
      final List<ChatMessageApi> messages = await ConversationApiService.getMessages(
        token: token,
        conversationId: conversationId,
      );
      if (!mounted) return;
      setState(() => _messages = messages);
    } catch (e) {
      debugPrint('Message refresh error: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ── Sending ──────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final int? conversationId = _conversationId;
    final String? token = SessionManager.accessToken;

    if (conversationId == null) {
      AppHelpers.showError('Conversation is not ready yet. Please wait.');
      return;
    }
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await ConversationApiService.sendMessage(
        token: token,
        conversationId: conversationId,
        message: text,
      );
      await _refreshMessages();
      _scrollToBottom();
    } catch (e) {
      debugPrint('Send message error: $e');
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
      // Text wapas box mein daal do taake user ka message zaya na ho.
      _messageController.text = text;
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────

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
                backgroundImage: _avatarImage,
                child: _avatarImage == null
                    ? const Icon(Icons.person, size: 16, color: _darkColor)
                    : null,
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
              child: RefreshIndicator(
                onRefresh: _refreshMessages,
                child: _messages.isEmpty
                    ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Text(
                        'No messages yet. Say hi!',
                        style: TextStyle(
                          fontFamily: 'Rob',
                          color: Color(0xFF60656B),
                        ),
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _messageBubble(_messages[index]),
                ),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessageApi message) {
    final bool isMe = message.senderId == SessionManager.userId;
    final Alignment alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isMe ? _darkColor : const Color(0xFFF0F1F3);
    final Color textColor = isMe ? Colors.white : _darkColor;

    // FIX: isMe ke hisab se sahi avatar select karo.
    final ImageProvider? avatarImg = isMe ? _myAvatarImage : _avatarImage;

    final CircleAvatar avatar = CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFFE4E8ED),
      backgroundImage: avatarImg,
      child: avatarImg == null
          ? const Icon(Icons.person, size: 14, color: _darkColor)
          : null,
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
        message.message,
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
        children: isMe
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
              onPressed: _isSending ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _darkColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: const StadiumBorder(),
              ),
              child: _isSending
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
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