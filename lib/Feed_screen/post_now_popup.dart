import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'create_post_screen.dart';
import '../services and managers/post_eligibility_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';

/// "+" button dabane par pehle posting-eligibility check hoti hai
/// (session token ke sath), phir agar allowed ho to
/// Post TikTok / Create Post / Upload Post popup dikhta hai.
/// Feed screen (ya kisi bhi screen) se call karo:
/// ```dart
/// onPostTap: () => showPostNowPopup(context),
/// ```
Future<void> showPostNowPopup(BuildContext context) async {
  final String? token = SessionManager.accessToken;

  if (token == null || token.trim().isEmpty) {
    AppHelpers.showError('Session expired. Please log in again.');
    return;
  }

  if (Get.isDialogOpen == true) return; // already loading

  AppHelpers.showLoader();

  PostEligibilityResponse eligibility;
  try {
    eligibility = await PostEligibilityService.checkEligibility(token: token);
  } catch (e) {
    AppHelpers.hideLoader();
    AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    return;
  }

  AppHelpers.hideLoader();

  if (!eligibility.canPost) {
    AppHelpers.showInfo(
      'You can post again in ${eligibility.remainingFormatted}.',
      title: 'Posting limit reached',
    );
    return;
  }

  if (!context.mounted) return;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Post Now',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      // parentContext (outer screen) navigation ke liye pass karte hain,
      // taake popup band hone ke baad bhi valid rahe.
      return _PostNowPopup(parentContext: context);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          alignment: Alignment.bottomCenter,
          scale: Tween<double>(begin: 0.9, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Opens the gallery to pick a single video, then pushes [CreatePostScreen]
/// pre-loaded with it. Used by both "Post TikTok" and "Create Post" tiles.
Future<void> _pickVideoAndOpenCreatePost(
    BuildContext dialogContext, BuildContext parentContext) async {
  Navigator.pop(dialogContext); // close the popup first (uses dialog's own context)

  final ImagePicker picker = ImagePicker();
  final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

  if (video == null || !parentContext.mounted) return; // user cancelled

  Navigator.push(
    parentContext, // parent screen's context — still mounted
    MaterialPageRoute(
      builder: (_) => CreatePostScreen(initialVideo: File(video.path)),
    ),
  );
}

/// Opens the gallery to pick one or more photos, then pushes
/// [CreatePostScreen] pre-loaded with them. Used by "Upload Post".
Future<void> _pickImagesAndOpenCreatePost(
    BuildContext dialogContext, BuildContext parentContext) async {
  Navigator.pop(dialogContext); // close the popup first

  final ImagePicker picker = ImagePicker();
  final List<XFile> images = await picker.pickMultiImage();

  if (images.isEmpty || !parentContext.mounted) return; // user cancelled

  Navigator.push(
    parentContext,
    MaterialPageRoute(
      builder: (_) => CreatePostScreen(
        initialImages: images.map((XFile x) => File(x.path)).toList(),
      ),
    ),
  );
}

class _PostNowPopup extends StatelessWidget {
  const _PostNowPopup({required this.parentContext});

  final BuildContext parentContext;

  static const Color _darkColor = Color(0xFF020A16);

  // Bottom nav bar ki approx height, taake popup uske upar exactly baithe.
  static const double _bottomNavHeight = 78;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            left: 20,
            right: 20,
            bottom: _bottomNavHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Popup card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PopupTile(
                        icon: Icons.music_note_rounded,
                        iconBg: Colors.black,
                        iconColor: Colors.white,
                        label: 'Post TikTok',
                        onTap: () =>
                            _pickVideoAndOpenCreatePost(context, parentContext),
                      ),
                      const Divider(height: 1, color: Color(0xFFE4E8ED)),
                      _PopupTile(
                        icon: Icons.add_box_outlined,
                        iconColor: _darkColor,
                        label: 'Create Post',
                        onTap: () =>
                            _pickVideoAndOpenCreatePost(context, parentContext),
                      ),
                      const Divider(height: 1, color: Color(0xFFE4E8ED)),
                      _PopupTile(
                        icon: Icons.file_upload_outlined,
                        iconColor: _darkColor,
                        label: 'Upload Post',
                        onTap: () =>
                            _pickImagesAndOpenCreatePost(context, parentContext),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Chhota pointer arrow jo "+" button ki taraf point kare
                CustomPaint(
                  size: const Size(16, 8),
                  painter: _PointerPainter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopupTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;
  final String label;
  final VoidCallback onTap;

  const _PopupTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.iconBg,
  });

  static const Color _darkColor = Color(0xFF020A16);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (iconBg != null)
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(icon, color: iconColor, size: 14),
              )
            else
              Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Rob',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _darkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Popup ke neeche chhota downward-pointing triangle banata hai.
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}