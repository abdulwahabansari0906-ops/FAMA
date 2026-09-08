import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services and managers/conversation_apis_services.dart';
import '../services and managers/profile_service.dart';
import '../services and managers/whatsapp_invite_service.dart';
import '../widgets/fama_bottom_nav.dart';
import '../Feed_screen/post_now_popup.dart';
import '../widgets/app_helper.dart';
import '../services and managers/session_manager.dart';
import 'message_individual_screen.dart';

/// Messages list screen — sab conversations ek list mein (POST
/// /api/conversations/list se live data).
class MessagesMainScreen extends StatefulWidget {
  const MessagesMainScreen({super.key});

  @override
  State<MessagesMainScreen> createState() => _MessagesMainScreenState();
}

class _MessagesMainScreenState extends State<MessagesMainScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);
  static const Color _whatsappColor = Color(0xFF298C4E);

  List<ConversationSummary> _conversations = [];
  bool _isLoading = true;
  bool _loadFailed = false;
  String _errorMessage = '';

  // Session se live fama points.
  int get _famaPoints => SessionManager.famaPoints;

  @override
  void initState() {
    super.initState();
    // AppHelpers.showLoader() (GetX dialog) pehle frame ke baad chalana
    // zaroori hai warna "visitChildElements() called during build" crash
    // aata hai.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchConversations());
    _syncFamaPoints();
  }

  // ── Fetching ─────────────────────────────────────────────────────────

  Future<void> _fetchConversations() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = 'Session expired. Please log in again.';
      });
      AppHelpers.showError(_errorMessage);
      return;
    }

    AppHelpers.showLoader();
    try {
      final List<ConversationSummary> conversations =
      await ConversationApiService.getConversations(token: token);

      AppHelpers.hideLoader();
      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (e) {
      AppHelpers.hideLoader();
      debugPrint('Conversations list error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      AppHelpers.showError(_errorMessage);
    }
  }

  /// Session mein fama points ko fresh rakhne ke liye halka profile
  /// fetch — sirf points sync karta hai, UI loader nahi dikhata.
  Future<void> _syncFamaPoints() async {
    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) return;

    try {
      final ProfileData profile = await ProfileApiService.getProfile(token: token);
      await SessionManager.updateFamaPoints(profile.user.famaPoints);
      if (!mounted) return;
      setState(() {}); // pill ko rebuild karke naye points dikhao
    } catch (e) {
      debugPrint('Fama points sync error: $e');
      // Silent fail — purana cached value hi dikhta rahega.
    }
  }

  Future<bool> _launchExternalUrl(Uri url) async {
    try {
      return await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// Top bar ke Invite button ka handler — session se phone number aur
  /// token nikal kar invite API call karta hai, phir WhatsApp ki contact
  /// list kholta hai (bina kisi fixed number ke) taake user khud select
  /// kar ke invite link kisi ko bhi send kar sake.
  Future<void> _handleTopBarInvite() async {
    if (Get.isDialogOpen == true) return; // request already in progress

    final String? phoneNumber = SessionManager.phoneNumber;
    final String? token = SessionManager.accessToken;

    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      AppHelpers.showError(
        'Phone number not found. Please log in again.',
      );
      return;
    }

    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError(
        'Session expired. Please log in again.',
      );
      return;
    }

    AppHelpers.showLoader();

    try {
      final InviteResponse invite = await InviteApiService.getInviteLink(
        phoneNumber: phoneNumber,
        token: token,
      );

      // Opens WhatsApp's own contact/chat list with the invite message
      // pre-filled, so the user picks who to send it to.
      final bool opened = await _launchExternalUrl(invite.contactPickerUri);

      AppHelpers.hideLoader();

      if (!opened) {
        AppHelpers.showError('Could not open WhatsApp.');
      }
    } catch (e) {
      AppHelpers.hideLoader();
      debugPrint('Invite error: $e');
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _openConversation(ConversationSummary conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageIndividualScreen(
          name: (conversation.otherUserName != null &&
              conversation.otherUserName!.trim().isNotEmpty)
              ? conversation.otherUserName!
              : 'User',
          image: conversation.otherUserAvatar ?? '',
          recipientId: conversation.otherUserId,
        ),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildBody()),
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

  Widget _buildBody() {
    if (_isLoading && _conversations.isEmpty) {
      // Sirf AppHelpers ka apna loader dikhta hai, koi default spinner nahi.
      return const SizedBox.shrink();
    }

    if (_loadFailed && _conversations.isEmpty) {
      return Center(
        child: TextButton(
          onPressed: _fetchConversations,
          child: Text(
            '$_errorMessage\nTap to retry.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF60656B)),
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchConversations,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'No conversations yet.',
                style: TextStyle(fontFamily: 'Rob', color: Color(0xFF60656B)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchConversations,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _conversations.length,
        separatorBuilder: (context, index) =>
        const Divider(height: 1, color: _borderColor),
        itemBuilder: (context, index) => _chatTile(_conversations[index]),
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
                  children: [
                    Image.asset(
                      'assets/images/whatsapp.png',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 5),
                    const Text(
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
              // Star count pill — ab live fama points dikhata hai
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_famaPoints',
                      style: const TextStyle(
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


  Widget _chatTile(ConversationSummary conversation) {
    final bool hasAvatar = conversation.otherUserAvatar != null &&
        conversation.otherUserAvatar!.isNotEmpty;
    final String displayName =
    (conversation.otherUserName != null &&
        conversation.otherUserName!.trim().isNotEmpty)
        ? conversation.otherUserName!
        : 'User';
    final String preview = (conversation.lastMessage != null &&
        conversation.lastMessage!.trim().isNotEmpty)
        ? conversation.lastMessage!
        : 'Say hi 👋';

    return InkWell(
      onTap: () => _openConversation(conversation),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE4E8ED),
              backgroundImage:
              hasAvatar ? NetworkImage(conversation.otherUserAvatar!) : null,
              child: !hasAvatar
                  ? const Icon(Icons.person, color: _darkColor, size: 26)
                  : null,
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
                          displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Rob',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _darkColor,
                          ),
                        ),
                      ),
                      if (conversation.timeAgo.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          conversation.timeAgo,
                          style: const TextStyle(
                            fontFamily: 'Rob',
                            fontSize: 11,
                            color: Color(0xFF9AA0A6),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
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
}