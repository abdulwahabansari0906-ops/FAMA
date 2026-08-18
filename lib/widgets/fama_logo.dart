import 'package:flutter/material.dart';

/// FAMA logo widget — assets/logo.png use karta hai
/// (star + FAMA text wali image, jo pubspec.yaml me register honi chahiye)
class FamaLogo extends StatelessWidget {
  final double height;
  const FamaLogo({super.key, this.height = 40});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
