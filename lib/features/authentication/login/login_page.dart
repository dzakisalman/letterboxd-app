import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Spacer(flex: 1),
                        SizedBox(height: 170),
                        // Logo
                        SvgPicture.asset(
                          'assets/images/letterboxd_logo.svg',
                          height: 75,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Login',
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please sign in to continue.',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                hintText: 'Username',
                                prefixIconPath: 'assets/icons/username.svg',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                prefixIconPath: 'assets/icons/password.svg',
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFE9A6A6),
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.openSans(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: 200,
                                child: Obx(() => ElevatedButton(
                                      onPressed: _authController.isLoading
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!.validate()) {
                                                final success = await _authController.login(
                                                  _emailController.text,
                                                  _passwordController.text,
                                                );
                                                if (success) {
                                                  Get.offAllNamed(AppRoutes.home);
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE9A6A6),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        minimumSize: const Size(double.infinity, 48),
                                      ),
                                      child: _authController.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Login',
                                              style: GoogleFonts.openSans(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    )),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t have an account? Please ',
                                    style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                        color: Color(0xFFE9A6A6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.toNamed(AppRoutes.signup);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                          color: Color(0xFF9C4A8B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),  
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ' first.',
                                    style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                        color: Color(0xFFE9A6A6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 