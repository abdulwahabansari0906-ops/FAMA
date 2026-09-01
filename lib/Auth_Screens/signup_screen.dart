import 'package:fama/Auth_Screens/login_screen.dart';
import 'package:fama/Auth_Screens/signup_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services and managers/session_manager.dart';
import '../services and managers/signup_service.dart';
import '../widgets/app_helper.dart';
import '../widgets/fama_logo.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleSignUp() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      AppHelpers.showError('Phone number aur password dono required hain.');
      return;
    }

    AppHelpers.showLoader();
    try {
      final response = await SignUpService.signUp(
        phoneNumber: phone,
        password: password,
      );
      await SessionManager.saveSignupSession(response);
      AppHelpers.hideLoader();
      AppHelpers.showSuccess(response.message);
      Get.to(() => const SignupDetailsScreen());
    } catch (e) {
      AppHelpers.hideLoader();
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: FamaLogo(height: 44)),
              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontFamily: "Rob"),
                  decoration: const InputDecoration(
                    hintText: "Phone Number",
                    hintStyle: TextStyle(fontFamily: "Rob"),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                height: 50,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontFamily: "Rob"),
                  decoration: const InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(fontFamily: "Rob"),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Rob"),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Have An Account? ',
                      style: TextStyle(fontSize: 12, fontFamily: "Rob")),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => LoginScreen());
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Rob",
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}