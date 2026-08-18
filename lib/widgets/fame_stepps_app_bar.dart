import 'package:flutter/material.dart';

class FamaStepAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FamaStepAppBar({
    super.key,
    required this.onBackTap,
    required this.onNextTap,
    this.actionText = 'Next ›',
    this.showNextButton = true,
  });

  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final String actionText;
  final bool showNextButton;

  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 52,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: 84,

      // Bottom Divider
      shape: const Border(
        bottom: BorderSide(
          color: _borderColor,
          width: 1,
        ),
      ),

      // Back Button
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _appBarButton(
            text: '‹ Back',
            onTap: onBackTap,
          ),
        ),
      ),

      // FAMA Logo
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Color(0xFFFFC107),
            size: 17,
          ),
          SizedBox(width: 3),
          Text(
            'FAMA',
            style: TextStyle(
              fontFamily: 'Rob',
              color: Color(0xFF101010),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),

      // Right Button
      actions: [
        SizedBox(
          width: 84,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: showNextButton
                  ? _appBarButton(
                text: actionText,
                onTap: onNextTap,
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _appBarButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 52,
      height: 28,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: _darkColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          minimumSize: const Size(52, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: 'Rob',
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}