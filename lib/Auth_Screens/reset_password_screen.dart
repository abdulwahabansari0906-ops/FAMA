import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services and managers/forget_password_service.dart';
import '../widgets/app_helper.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.resetToken,
  });

  final String phoneNumber;
  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();

  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordController.text.trim();

    if (newPassword.isEmpty) {
      AppHelpers.showError('New password required hai.');
      return;
    }
    if (newPassword.length < 6) {
      AppHelpers.showError('Password kam se kam 6 characters ka hona chahiye.');
      return;
    }

    AppHelpers.showLoader();
    try {
      final message = await ForgotPasswordService.resetPassword(
        phoneNumber: widget.phoneNumber,
        token: widget.resetToken,
        newPassword: newPassword,
      );
      AppHelpers.hideLoader();
      AppHelpers.showSuccess(message);

      Get.offAll(() => LoginScreen());
    } catch (e) {
      AppHelpers.hideLoader();
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    "assets/images/lock.png",
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Reset Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Rob"),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apna naya password enter karein',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.black54, fontFamily: "Rob"),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: const TextStyle(fontFamily: "Rob"),
                  decoration: const InputDecoration(
                    hintText: "New Password",
                    hintStyle: TextStyle(fontFamily: "Rob"),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Rob"),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.offAll(() => LoginScreen());
                  },
                  child: const Text(
                    'Back To Login',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "Rob",
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}