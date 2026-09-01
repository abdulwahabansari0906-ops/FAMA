import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../services and managers/create_post_service.dart';
import '../widgets/app_helper.dart';
import '../services and managers/session_manager.dart';

/// Create Post screen — media preview (video OR multiple photos),
/// allow-comments toggle, aur "Post Now" bar.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({
    super.key,
    this.initialVideo,
    this.initialImages,
  });

  /// A single video pre-selected from the Post Now popup (TikTok / Create Post).
  final File? initialVideo;

  /// One or more photos pre-selected from the Post Now popup (Upload Post).
  final List<File>? initialImages;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  bool _allowComments = true;

  final ImagePicker _picker = ImagePicker();

  File? _videoFile;
  VideoPlayerController? _videoController;
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      _imageFiles = List<File>.from(widget.initialImages!);
    }

    if (widget.initialVideo != null) {
      _setVideo(widget.initialVideo!);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // ── Media selection ──────────────────────────────────────────────────

  /// Initializes and swaps in a new video preview, disposing the old
  /// controller only after the new one is ready (avoids a preview flash).
  Future<void> _setVideo(File file) async {
    final VideoPlayerController controller = VideoPlayerController.file(file);

    try {
      await controller.initialize();
      controller.setLooping(true);
    } catch (e) {
      debugPrint('Video load error: $e');
      AppHelpers.showError('Could not load the selected video.');
      controller.dispose();
      return;
    }

    if (!mounted) {
      controller.dispose();
      return;
    }

    final VideoPlayerController? oldController = _videoController;

    setState(() {
      _videoFile = file;
      _videoController = controller;
      _imageFiles = []; // video and photos are mutually exclusive here
    });

    await oldController?.dispose();
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return; // user cancelled
      await _setVideo(File(picked.path));
    } catch (e) {
      debugPrint('Video pick error: $e');
      AppHelpers.showError('Could not load the selected video.');
    }
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return; // user cancelled

      final VideoPlayerController? oldController = _videoController;

      setState(() {
        _imageFiles = picked.map((XFile x) => File(x.path)).toList();
        _videoFile = null;
        _videoController = null;
      });

      await oldController?.dispose();
    } catch (e) {
      debugPrint('Image pick error: $e');
      AppHelpers.showError('Could not load the selected photos.');
    }
  }

  void _removeImageAt(int index) {
    setState(() => _imageFiles.removeAt(index));
  }

  void _togglePlayback() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  // ── Posting ───────────────────────────────────────────────────────────

  /// Validates input, fetches the session token, and uploads the post.
  Future<void> _postNow() async {
    if (Get.isDialogOpen == true) return; // upload already in progress

    final bool hasVideo = _videoFile != null;
    final bool hasImages = _imageFiles.isNotEmpty;

    if (!hasVideo && !hasImages) {
      AppHelpers.showError('Please select a video or photos to post.');
      return;
    }

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    AppHelpers.showLoader();

    try {
      final CreatePostResponse response = hasVideo
          ? await CreatePostApiService.createVideoPost(
        token: token,
        videoFile: _videoFile!,
        allowComments: _allowComments,
      )
          : await CreatePostApiService.createImagePost(
        token: token,
        imageFiles: _imageFiles,
        allowComments: _allowComments,
      );

      AppHelpers.hideLoader();
      AppHelpers.showSuccess(
        response.message.isNotEmpty
            ? response.message
            : 'Post created successfully.',
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      AppHelpers.hideLoader();
      debugPrint('Create post error: $e');
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
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
    if (_imageFiles.isNotEmpty) {
      return _buildImagesPreview();
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return _buildVideoPreview(_videoController!);
    }

    return _buildEmptyPlaceholder();
  }

  Widget _buildEmptyPlaceholder() {
    return GestureDetector(
      onTap: _pickVideoFromGallery,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 220,
          width: double.infinity,
          color: const Color(0xFFDADCE0),
          child: Center(
            child: Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Color(0xFFDADCE0),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _togglePlayback,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 220,
          width: double.infinity,
          color: const Color(0xFFDADCE0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
              if (!controller.value.isPlaying)
                Center(
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFFDADCE0),
                      size: 28,
                    ),
                  ),
                ),
              // Small "change video" affordance
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: _pickVideoFromGallery,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesPreview() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles.length + 1, // +1 for the "add more" tile
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == _imageFiles.length) {
            return GestureDetector(
              onTap: _pickImagesFromGallery,
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: _darkColor,
                  size: 26,
                ),
              ),
            );
          }

          final File image = _imageFiles[index];

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  image,
                  width: 160,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: () => _removeImageAt(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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