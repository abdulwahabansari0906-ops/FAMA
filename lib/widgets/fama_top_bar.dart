import 'package:flutter/material.dart';
import 'fama_logo.dart';

class FamaTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? rightLabel;
  final VoidCallback? onRightTap;
  final VoidCallback? onBackTap;

  const FamaTopBar({
    super.key,
    this.rightLabel,
    this.onRightTap,
    this.onBackTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 90,
      leading: TextButton(
        onPressed: onBackTap ??
            () {
              // TODO: default back navigation
              Navigator.pop(context);
            },
        child: Container(
          height: 35,width: 120,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
              SizedBox(width: 2),
              Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      title: const FamaLogo(height: 26),
      centerTitle: true,
      actions: [
        if (rightLabel != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: ElevatedButton(
                onPressed: onRightTap /* TODO: navigate next */,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(0, 20),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(rightLabel!),
              ),
            ),
          )
        else
          const SizedBox(width: 50),
      ],
    );
  }
}
