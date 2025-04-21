import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String prefixIconPath;
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
    required this.prefixIconPath,
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
    // Calculate opacity dynamically for colors
    final double fillOpacity = 0.35;
    final double hintAndIconOpacity = 0.5;

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
          prefixIcon: Padding(
            padding: iconPadding,
            child: SvgPicture.asset(
              prefixIconPath,
              colorFilter: ColorFilter.mode(
                iconColor.withOpacity(hintAndIconOpacity),
                BlendMode.srcIn,
              ),
            ),
          ),
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
            borderSide: BorderSide.none, // Or customize focus border if needed
          ),
          filled: true,
          fillColor: fillColor.withOpacity(fillOpacity),
          contentPadding: contentPadding,
          // Ensure error messages don't cause overflow
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