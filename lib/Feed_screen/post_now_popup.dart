import 'package:flutter/material.dart';
import 'create_post_screen.dart';

/// "+" button dabane par ye popup dikhta hai — Post TikTok / Create Post / Upload Post.
/// Feed screen (ya kisi bhi screen) se call karo:
/// ```dart
/// onPostTap: () => showPostNowPopup(context),
/// ```
Future<void> showPostNowPopup(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Post Now',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _PostNowPopup();
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

class _PostNowPopup extends StatelessWidget {
  const _PostNowPopup();

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
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: TikTok se post karne ka flow yahan lagayein
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE4E8ED)),
                      _PopupTile(
                        icon: Icons.add_box_outlined,
                        iconColor: _darkColor,
                        label: 'Create Post',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE4E8ED)),
                      _PopupTile(
                        icon: Icons.file_upload_outlined,
                        iconColor: _darkColor,
                        label: 'Upload Post',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: gallery se file upload karne ka flow yahan lagayein
                        },
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