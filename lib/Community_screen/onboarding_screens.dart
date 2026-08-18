import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/onboarding_controllers.dart';
import '../widgets/onboarding_items.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const Color _darkColor = Color(0xFF020A16);
  static const Color _yellowColor = Color(0xFFFFC31A);
  static const Color _inactiveDotColor = Color(0xFFE4E7EA);

  static const List<OnboardingItem> _pages = [
    OnboardingItem(
      icon: Icons.star_rounded,
      iconColor: _yellowColor,
      iconSize: 80,
      outsideLabel: 'FAMA',
      title: 'Become A Celebrity\nIn Your City',
      description: 'Earn Fama | Climb Rankings',
    ),
    OnboardingItem(
      imagePath: "assets/images/lock.png",
      iconSize: 66,
      insideLabel: '21:32',
      title: 'One Post Per Day',
      description: 'Limited To 1 Post Per\nDay',
    ),
    OnboardingItem(
      imagePath: "assets/images/prize.png",
      iconSize: 70,
      title: 'Local Leaderboard',
      description:
      'Climb Leaderboard Rankings To\n'
          'Become Most Popular Celebrity\n'
          'In Your City And School',
    ),
    OnboardingItem(
      icon: Icons.star_rounded,
      iconColor: _yellowColor,
      iconSize: 50,
      insideLabel: '2,735',
      labelBesideIcon: true,
      title: 'Earn FAMA',
      description:
      'Each Like On Your Posts Earns\n'
          'You 1 FAMA To Rank Higher On\n'
          'Leaderboard',
    ),
    OnboardingItem(
      imagePath: "assets/images/message.png",
      iconSize: 70,
      title: 'Rank-Based Messaging',
      description:
      'Only Higher Ranked Users\n'
          'Can Initiate Messages With\n'
          'Lower Ranks',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Agar controller pehle se register nahi hai, to yahin register kar dein.
    // Isse "OnboardingController not found" wala error kabhi nahi aayega,
    // chahe aap named routes use karein ya Get.to() bina binding ke.
    final OnboardingController controller = Get.isRegistered<OnboardingController>()
        ? Get.find<OnboardingController>()
        : Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: controller.pageController,
          itemCount: _pages.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, index) {
            return _OnboardingPage(
              item: _pages[index],
              indicator: Obx(
                    () => _PageIndicator(
                  activeIndex: controller.currentPage.value,
                  totalPages: _pages.length,
                ),
              ),
            );
          },
        ),
      ),

      // Bottom Button
      bottomNavigationBar: Obx(
            () {
          final bool isLastPage =
              controller.currentPage.value == _pages.length - 1;

          return ColoredBox(
            color: _darkColor,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: controller.nextPage,
                  style: TextButton.styleFrom(
                    backgroundColor: _darkColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.item,
    required this.indicator,
  });

  final OnboardingItem item;
  final Widget indicator;

  static const Color _darkColor = Color(0xFF020A16);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OnboardingVisual(item: item),

            if (item.outsideLabel != null) ...[
              const SizedBox(height: 14),
              Text(
                item.outsideLabel!,
                style: const TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _darkColor,
                ),
              ),
            ],

            const SizedBox(height: 26),

            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rob',
                fontSize: 28,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: _darkColor,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rob',
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w400,
                color: _darkColor,
              ),
            ),

            const SizedBox(height: 28),

            indicator,
          ],
        ),
      ),
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  const _OnboardingVisual({
    required this.item,
  });

  final OnboardingItem item;

  static const Color _darkColor = Color(0xFF020A16);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE2E6EA),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: _buildVisualContent(),
    );
  }

  Widget _buildVisualContent() {
    final Widget visual = item.imagePath != null
        ? Image.asset(
      item.imagePath!,
      width: item.iconSize,
      height: item.iconSize,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.broken_image_outlined,
          size: 36,
          color: _darkColor,
        );
      },
    )
        : Icon(
      item.icon,
      size: item.iconSize,
      color: item.iconColor,
    );

    if (item.insideLabel == null) {
      return visual;
    }

    final Widget label = Text(
      item.insideLabel!,
      style: const TextStyle(
        fontFamily: 'Rob',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _darkColor,
      ),
    );

    if (item.labelBesideIcon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          visual,
          const SizedBox(width: 7),
          label,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        visual,
        const SizedBox(height: 3),
        Text(
          item.insideLabel!,
          style: const TextStyle(
            fontFamily: 'Rob',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _darkColor,
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.activeIndex,
    required this.totalPages,
  });

  final int activeIndex;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalPages,
            (index) {
          final bool isActive = index == activeIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF020A16)
                  : const Color(0xFFE4E7EA),
            ),
          );
        },
      ),
    );
  }
}