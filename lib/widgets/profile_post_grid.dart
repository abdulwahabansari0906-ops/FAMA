import 'package:flutter/material.dart';
import '../../services and managers/profile_service.dart';
import '../Profile_screen/full_screen_video_play_screen.dart';
import 'grid_thumb_video.dart';

const Color _darkColor = Color(0xFF020A16);

class ProfilePostGrid extends StatelessWidget {
  final List<ProfilePostApi> posts;
  const ProfilePostGrid({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No posts yet.',
            style: TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFF60656B)),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final ProfilePostApi post = posts[index];

        return GestureDetector(
          onTap: () {
            if (post.videoUrl.isEmpty) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FullScreenVideoPlayer(videoUrl: post.videoUrl)),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty)
                Image.network(
                  post.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE4E8ED),
                    child: const Icon(Icons.play_circle_outline, color: _darkColor),
                  ),
                )
              else
                GridVideoThumb(videoUrl: post.videoUrl),
              Positioned(
                left: 8,
                bottom: 8,
                child: _StatPill(icon: Icons.star_rounded, value: '${post.famaPoints}'),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: _StatPill(icon: Icons.play_arrow_rounded, value: '${post.viewsCount}'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  const _StatPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}