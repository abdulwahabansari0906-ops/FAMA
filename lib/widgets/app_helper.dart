import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'loader.dart';

/// Central helpers for showing/hiding a full-screen loader and
/// GetX snackbars from anywhere in the app (no BuildContext needed).
class AppHelpers {
  AppHelpers._();

  // ── Loader ──────────────────────────────────────────────────────────────

  /// Shows a blocking loader dialog (barrier is not dismissible, so the
  /// user can't tap through it while an API call is in progress).
  static void showLoader({Color color = Colors.yellow}) {
    if (Get.isDialogOpen == true) return; // avoid stacking multiple loaders
    Get.dialog(
      PopScope(
        canPop: true, // block back button while loading
        child: Loader(color: color),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.15),
    );
  }

  /// Hides the loader dialog if it's currently showing.
  static void hideLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  // ── Snackbars ─────────────────────────────────────────────────────────

  static void showSuccess(String message, {String title = 'Success'}) {
    _closeAnyOpenSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      margin: const EdgeInsets.all(16),
      icon: Icon(Icons.check_circle, color: Colors.green.shade800),
      duration: const Duration(seconds: 2),
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    _closeAnyOpenSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade800,
      margin: const EdgeInsets.all(16),
      icon: Icon(Icons.error_outline, color: Colors.red.shade800),
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _closeAnyOpenSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      margin: const EdgeInsets.all(16),
      icon: Icon(Icons.info_outline, color: Colors.blue.shade800),
      duration: const Duration(seconds: 3),
    );
  }

  static void _closeAnyOpenSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }
}