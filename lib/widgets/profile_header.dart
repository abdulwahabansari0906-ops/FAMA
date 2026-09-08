import 'package:fama/widgets/profile_rank_pill.dart';
import 'package:flutter/material.dart';
import '../../services and managers/profile_service.dart';


/// Avatar + name + star pill + rank badges (overall / location / school).
class ProfileHeader extends StatelessWidget {
  final ProfileUser user;
  final int overallRank;
  final int locationRank;
  final int schoolRank;
  final int famaPoints;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.overallRank,
    required this.locationRank,
    required this.schoolRank,
    required this.famaPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFE4E8ED),
            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, size: 34, color: Color(0xFF020A16))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name.isNotEmpty ? user.name : 'Unnamed',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF020A16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StarPill(value: '$famaPoints'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    RankBadge(icon: Icons.emoji_events_outlined, label: '#$overallRank Overall'),
                    RankBadge(
                      icon: Icons.location_on_outlined,
                      label: '#$locationRank In ${user.locationName}',
                    ),
                    RankBadge(
                      icon: Icons.home_outlined,
                      label: '#$schoolRank In ${user.schoolName}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}