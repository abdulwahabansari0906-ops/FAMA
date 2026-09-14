import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReportedVideoPreview extends StatefulWidget {
  const ReportedVideoPreview({
    super.key,
    required this.videoUrl,
    required this.isContentAvailable,
    this.width = 96,
    this.height = 128,
  });

  final String videoUrl;
  final bool isContentAvailable;
  final double width;
  final double height;

  @override
  State<ReportedVideoPreview> createState() =>
      _ReportedVideoPreviewState();
}

class _ReportedVideoPreviewState extends State<ReportedVideoPreview>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;

  bool _loading = false;
  bool _failed = false;

  bool get _available =>
      widget.isContentAvailable && widget.videoUrl.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant ReportedVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl ||
        oldWidget.isContentAvailable != widget.isContentAvailable) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final previous = _controller;
    _controller = null;
    previous?.dispose();

    if (!_available) {
      setState(() {
        _loading = false;
        _failed = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _failed = false;
    });

    VideoPlayerController? candidate;

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl.trim()),
      );

      candidate = controller;
      _controller = controller;

      await controller.initialize();

      if (!mounted || _controller != controller) return;

      setState(() => _loading = false);
    } catch (_) {
      if (!mounted || _controller != candidate) return;

      _controller = null;
      candidate?.dispose();

      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    try {
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        if (controller.value.position >= controller.value.duration) {
          await controller.seekTo(Duration.zero);
        }

        if (!mounted || _controller != controller) return;

        await controller.play();
      }
    } catch (_) {
      if (!mounted || _controller != controller) return;

      setState(() => _failed = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Widget _placeholder(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(height: 6),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rob',
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _retryButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _initializeVideo,
      child: _placeholder(Icons.refresh_rounded, 'Tap to retry'),
    );
  }

  Widget _buildContent() {
    final controller = _controller;

    if (!_available) {
      return _placeholder(Icons.videocam_off_outlined, 'Unavailable');
    }

    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFFC839),
          ),
        ),
      );
    }

    if (_failed || controller == null) {
      return _retryButton();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.hasError) return _retryButton();

        return Semantics(
          button: true,
          label: value.isPlaying ? 'Pause video' : 'Play video',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlayback,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
                if (!value.isPlaying)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                if (value.isBuffering)
                  const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFFC839),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Color(0xFFFFC839),
                      bufferedColor: Colors.white38,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ColoredBox(
          color: Colors.black,
          child: _buildContent(),
        ),
      ),
    );
  }
}