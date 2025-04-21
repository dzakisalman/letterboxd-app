import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/features/authentication/widgets/custom_text_field.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  // Basic email validation regex
  final _emailRegExp = RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
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
                        const SizedBox(height: 170),
                        SvgPicture.asset(
                          'assets/images/letterboxd_logo.svg',
                          height: 75,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Sign Up',
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
                          'Create an account to continue.',
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
                                controller: _usernameController,
                                hintText: 'Username',
                                prefixIconPath: 'assets/icons/username.svg',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  if (value.length < 3) {
                                      return 'Username must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _emailController,
                                hintText: 'Email',
                                prefixIconPath: 'assets/icons/email.svg',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email address';
                                  }
                                  if (!_emailRegExp.hasMatch(value)) {
                                      return 'Please enter a valid email address';
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
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: 200,
                                child: Obx(() => ElevatedButton(
                                      onPressed: _authController.isLoading
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!.validate()) {
                                                final success = await _authController.signup(
                                                   _usernameController.text,
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
                                              'Sign Up',
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
                                    'Already have an account? ',
                                    style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                        color: Color(0xFFE9A6A6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Login Page',
                                      style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                          color: Color(0xFF9C4A8B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String prefixIconPath;
  final Widget? prefixIconWidget;
  final TextInputType keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final double width;
  final double height;
  final double borderRadius;
  final Color fillColor;
  final Color iconColor;
  final Color textColor;
  final Color hintColor;
  final double fontSize;
  final EdgeInsets iconPadding;
  final EdgeInsets contentPadding;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.prefixIconPath = '',
    this.prefixIconWidget,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.width = 243,
    this.height = 33,
    this.borderRadius = 30,
    this.fillColor = const Color(0xFFC4C4C4),
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.hintColor = Colors.white,
    this.fontSize = 14,
    this.iconPadding = const EdgeInsets.all(8),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fillOpacity = 0.35;
    final double hintAndIconOpacity = 0.5;

    Widget? prefixIcon;
    if (prefixIconWidget != null) {
      prefixIcon = prefixIconWidget;
    } else if (prefixIconPath.isNotEmpty) {
      prefixIcon = Padding(
        padding: iconPadding,
        child: SvgPicture.asset(
          prefixIconPath,
          colorFilter: ColorFilter.mode(
            iconColor.withOpacity(hintAndIconOpacity),
            BlendMode.srcIn,
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: hintColor.withOpacity(hintAndIconOpacity),
            fontSize: fontSize,
          ),
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: fillColor.withOpacity(fillOpacity),
          contentPadding: contentPadding,
          errorStyle: const TextStyle(height: 0.8, fontSize: 10),
        ),
        style: TextStyle(color: textColor, fontSize: fontSize),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
} 