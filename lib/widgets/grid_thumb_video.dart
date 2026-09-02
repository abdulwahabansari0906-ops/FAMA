import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Grid tile ke liye video ka paused first-frame preview — jab
/// thumbnail_url na ho tab blank rehne ke bajaye yehi asal video frame
/// dikhata hai, wahi cover size me jo tile ka hai, aur uske upar play icon.
class GridVideoThumb extends StatefulWidget {
  const GridVideoThumb({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<GridVideoThumb> createState() => _GridVideoThumbState();
}

class _GridVideoThumbState extends State<GridVideoThumb> {
  static const Color _placeholderIconColor = Color(0xFF020A16);

  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    if (widget.videoUrl.isEmpty) {
      if (!mounted) return;
      setState(() => _hasError = true);
      return;
    }

    final VideoPlayerController controller =
    VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await controller.initialize();
      await controller.seekTo(const Duration(milliseconds: 200));
      await controller.pause();
    } catch (e) {
      debugPrint('GRID THUMB DEBUG -> init failed for ${widget.videoUrl}: $e');
      controller.dispose();
      if (!mounted) return;
      setState(() => _hasError = true);
      return;
    }

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() => _controller = controller);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: const Color(0xFFE4E8ED),
        child: const Icon(
          Icons.play_circle_outline,
          color: _placeholderIconColor,
          size: 28,
        ),
      );
    }

    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(color: Color(0xFFE4E8ED));
    }

    return ClipRect(
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
          const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}