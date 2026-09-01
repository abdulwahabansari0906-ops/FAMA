import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Community_screen/onboarding_screens.dart';
import '../Auth_Screens/login_screen.dart';
import '../Feed_screen/feed_screen.dart';
import '../services and managers/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      _navigateNext();
    });
  }

  void _navigateNext() {
    if (SessionManager.isLoggedIn) {
      // Pehle se login hai -> seedha main screen
      Get.off(
            () => const FeedScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
      return;
    }

    // Koi saved session nahi -> pehli martaba wala flow
    Get.off(
          () => const OnboardingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Image.asset(
            'assets/images/logo.png',
            height: size.height * 0.3,
            width: size.width * 0.6,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}