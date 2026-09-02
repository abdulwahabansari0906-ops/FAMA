import 'package:flutter/material.dart';

class ProfileBio extends StatelessWidget {
  final String? bio;
  const ProfileBio({super.key, required this.bio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        (bio != null && bio!.trim().isNotEmpty) ? bio! : 'No bio added yet.',
        style: const TextStyle(
          fontFamily: 'Rob',
          fontSize: 13,
          height: 1.4,
          color: Color(0xFF60656B),
        ),
      ),
    );
  }
}