import 'package:fama/Auth_Screens/forgot_password_screen.dart';
import 'package:fama/Auth_Screens/signup_details_screen.dart';
import 'package:fama/Auth_Screens/signup_screen.dart';
import 'package:fama/Community_screen/onboarding_screens.dart';
import 'package:fama/Feed_screen/feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../widgets/fama_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

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

              SizedBox(height: 50,
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: "Rob",
                  ),
                  decoration: const InputDecoration(
                    hintText: "Phone Number",
                    hintStyle: TextStyle(
                      fontFamily: "Rob",
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(height: 50,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    fontFamily: "Rob",
                  ),
                  decoration: const InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(
                      fontFamily: "Rob",
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Get.to(()=>ForgotPasswordScreen());
                  },
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(color: Colors.black87, fontSize: 15,
                        fontFamily: "Rob"),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () {
                  // TODO: login API call yahan lagayein, success par neeche wali line chalegi
                  Get.offAll(() => const FeedScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w600,
                      fontFamily: "Rob"),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't Have Account? ",
                    style: TextStyle(fontSize: 12,
                        fontFamily: "Rob"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to (()=>SignUpScreen());
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 12,fontFamily: "Rob",
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