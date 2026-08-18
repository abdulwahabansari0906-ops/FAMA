import 'package:flutter/material.dart';

/// Create Post screen — media preview, allow-comments toggle, aur "Post Now" bar.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  bool _allowComments = true;

  void _postNow() {
    // TODO: media upload + post creation API call yahan lagayein
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
          centerTitle: true,
          shape: const Border(bottom: BorderSide(color: _borderColor, width: 1)),
          leadingWidth: 84,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: _darkColor,
                  minimumSize: const Size(52, 28),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
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
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 18),
              SizedBox(width: 4),
              Text(
                'FAMA',
                style: TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _darkColor,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 14),
                      SizedBox(width: 4),
                      Text(
                        '288',
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
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMediaPreview(),
                    const SizedBox(height: 24),
                    _buildAllowCommentsRow(),
                  ],
                ),
              ),
            ),
            _buildPostNowBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return GestureDetector(
      onTap: () {
        // TODO: gallery/camera se media pick karein (image_picker package)
      },
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFDADCE0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFDADCE0), size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildAllowCommentsRow() {
    return Row(
      children: [
        const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: _darkColor),
        const SizedBox(width: 10),
        const Text(
          'Allow Comments',
          style: TextStyle(
            fontFamily: 'Rob',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _darkColor,
          ),
        ),
        const Spacer(),
        Switch(
          value: _allowComments,
          onChanged: (value) => setState(() => _allowComments = value),
          activeColor: Colors.white,
          activeTrackColor: _darkColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFDADCE0),
        ),
      ],
    );
  }

  Widget _buildPostNowBar() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _postNow,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _darkColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 18),
            SizedBox(width: 8),
            Text(
              'Post Now',
              style: TextStyle(
                fontFamily: 'Rob',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}