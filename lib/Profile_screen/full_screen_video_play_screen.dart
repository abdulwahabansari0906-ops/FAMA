import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fullscreen video player — profile grid me kisi post par tap karne par
/// khulta hai. Auto-plays, loops, aur tap se pause/play toggle hota hai.
class FullScreenVideoPlayer extends StatefulWidget {
  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final VideoPlayerController controller =
    VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await controller.initialize();
      controller.setLooping(true);
    } catch (e) {
      debugPrint('FULLSCREEN VIDEO DEBUG -> init failed: $e');
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
    controller.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(child: _buildVideo()),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideo() {
    if (_hasError) {
      return const Text(
        'Could not play this video.',
        style: TextStyle(color: Colors.white70),
      );
    }

    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          controller.value.isPlaying ? controller.pause() : controller.play();
        });
      },
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}