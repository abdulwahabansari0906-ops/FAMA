import 'package:flutter/material.dart';

class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
    this.iconColor = const Color(0xFF020A16),
    this.iconSize = 46,
    this.insideLabel,
    this.labelBesideIcon = false,
    this.outsideLabel,
  }) : assert(
  (icon == null) != (imagePath == null),
  'icon ya imagePath mein se sirf aik provide karein.',
  );

  final String title;
  final String description;

  // In dono mein se sirf aik use hoga
  final IconData? icon;
  final String? imagePath;

  final Color iconColor;
  final double iconSize;

  // Circle ke andar icon ke saath text
  final String? insideLabel;
  final bool labelBesideIcon;

  // Circle ke neeche extra text, jaise FAMA
  final String? outsideLabel;
}