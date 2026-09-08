import 'package:flutter/material.dart';
import '../services and managers/post_coment_api_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';

/// Opens the comments bottom sheet for [postId]. Call this from the
/// comment icon's onTap in FeedScreen:
///
/// ```dart
/// onTap: () => showCommentsBottomSheet(
///   context,
///   postId: post.id,
///   onCommentCountChanged: (delta) => ...,
/// ),
/// ```
///
/// [onCommentCountChanged] fires with `+1` right after a comment is
/// successfully added and `-1` right after one is successfully deleted —
/// use it to update the count shown behind the sheet (e.g. on the feed)
/// immediately, without waiting for the sheet to close or a full refresh.
Future<void> showCommentsBottomSheet(
    BuildContext context, {
      required int postId,
      ValueChanged<int>? onCommentCountChanged,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CommentsSheet(
      postId: postId,
      onCommentCountChanged: onCommentCountChanged,
    ),
  );
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.postId, this.onCommentCountChanged});

  final int postId;
  final ValueChanged<int>? onCommentCountChanged;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  final TextEditingController _commentController = TextEditingController();
  final List<PostComment> _comments = [];

  bool _isLoading = true;
  bool _loadFailed = false;
  String _errorMessage = '';
  bool _isPosting = false;

  // Comment ids currently being deleted — hides them immediately
  // (optimistic) while the request is in flight.
  final Set<int> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ── Fetching ─────────────────────────────────────────────────────────

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    final String? token = SessionManager.accessToken;
    debugPrint('COMMENTS DEBUG -> token: $token, postId: ${widget.postId}');

    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = 'Session expired. Please log in again.';
      });
      return;
    }

    try {
      final CommentsListResult result = await PostCommentsApiService.getComments(
        token: token,
        postId: widget.postId,
      );

      if (!mounted) return;
      setState(() {
        _comments
          ..clear()
          ..addAll(result.comments);
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (e) {
      debugPrint('COMMENTS DEBUG -> fetch error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ── Add ──────────────────────────────────────────────────────────────

  Future<void> _handleSend() async {
    final String text = _commentController.text.trim();
    if (text.isEmpty || _isPosting) return;

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    setState(() => _isPosting = true);

    try {
      final PostComment newComment = await PostCommentsApiService.addComment(
        token: token,
        postId: widget.postId,
        comment: text,
      );

      if (!mounted) return;
      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
        _isPosting = false;
      });
      widget.onCommentCountChanged?.call(1);
    } catch (e) {
      debugPrint('COMMENTS DEBUG -> add error: $e');
      if (!mounted) return;
      setState(() => _isPosting = false);
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────

  Future<void> _handleDelete(PostComment comment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete comment',
          style: TextStyle(fontFamily: 'Rob', fontWeight: FontWeight.w700, color: _darkColor),
        ),
        content: const Text(
          'Are you sure you want to delete this comment?',
          style: TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFF60656B)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Rob', color: _darkColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Rob', color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    setState(() => _deletingIds.add(comment.id));

    try {
      await PostCommentsApiService.deleteComment(token: token, commentId: comment.id);
      if (!mounted) return;
      setState(() {
        _comments.removeWhere((c) => c.id == comment.id);
        _deletingIds.remove(comment.id);
      });
      widget.onCommentCountChanged?.call(-1);
    } catch (e) {
      debugPrint('COMMENTS DEBUG -> delete error: $e');
      if (!mounted) return;
      setState(() => _deletingIds.remove(comment.id));
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Comments',
              style: TextStyle(
                fontFamily: 'Rob',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _darkColor,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: _borderColor, height: 1),
            Expanded(child: _buildList()),
            const Divider(color: _borderColor, height: 1),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _darkColor),
      );
    }

    if (_loadFailed) {
      return Center(
        child: TextButton(
          onPressed: _fetchComments,
          child: Text(
            '$_errorMessage\nTap to retry.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF60656B)),
          ),
        ),
      );
    }

    if (_comments.isEmpty) {
      return const Center(
        child: Text(
          'No comments yet. Be the first!',
          style: TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFF60656B)),
        ),
      );
    }

    final int? myUserId = SessionManager.userId;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final PostComment comment = _comments[index];
        final bool isMine = myUserId != null && comment.userId == myUserId;
        final bool isDeleting = _deletingIds.contains(comment.id);

        return Opacity(
          opacity: isDeleting ? 0.4 : 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE4E8ED),
                backgroundImage: (comment.userAvatar != null && comment.userAvatar!.isNotEmpty)
                    ? NetworkImage(comment.userAvatar!)
                    : null,
                child: (comment.userAvatar == null || comment.userAvatar!.isEmpty)
                    ? const Icon(Icons.person, color: _darkColor, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (comment.userName != null && comment.userName!.isNotEmpty)
                          ? comment.userName!
                          : 'User',
                      style: const TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _darkColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.comment,
                      style: const TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 13,
                        color: Color(0xFF3A3F47),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMine)
                IconButton(
                  onPressed: isDeleting ? null : () => _handleDelete(comment),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: 8),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: _darkColor),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFFA9AEB4)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: _darkColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isPosting
                ? const SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2, color: _darkColor),
              ),
            )
                : IconButton(
              onPressed: _handleSend,
              icon: const Icon(Icons.send_rounded, color: _darkColor),
            ),
          ],
        ),
      ),
    );
  }
}