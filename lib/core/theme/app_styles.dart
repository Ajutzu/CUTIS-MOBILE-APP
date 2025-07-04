import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Colors.pink;
  static const Color secondary = Colors.white;
  static const Color background = Colors.white;
  static const Color text = Colors.black87;
  // Removed accent color
}

class AppTextStyles {
  static final base = GoogleFonts.inter();

  static const TextStyle title = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  static const TextStyle divider = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.text, // Changed from AppColors.accent to AppColors.primary
  );
}
