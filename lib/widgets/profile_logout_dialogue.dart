import 'package:flutter/material.dart';

const Color _darkColor = Color(0xFF020A16);
const Color _borderColor = Color(0xFFE4E8ED);

/// Logout confirmation dialog. `onConfirm` tabhi call hota hai jab
/// user "Yes" tap kare.
void showLogoutDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Logout',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Rob',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _darkColor,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFF60656B)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                foregroundColor: _darkColor,
                side: const BorderSide(color: _borderColor),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'No',
                style: TextStyle(fontFamily: 'Rob', fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _darkColor,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(fontFamily: 'Rob', fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    },
  );
}