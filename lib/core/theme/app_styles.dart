import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppColors {
  static const Color primary = Color.fromRGBO(67, 168, 77, 1); // update this if needed
  static const Color secondary = Colors.white;
  static const Color background = Colors.white;
  static const Color text = Colors.black87;
}

class AppTextStyles {
  static final TextStyle title = GoogleFonts.inter(
    fontSize: 25,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
    color: AppColors.primary,
  );

  static final TextStyle heading = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static final TextStyle subtitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static final TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static final TextStyle link = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  static final TextStyle divider = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  // ---- Additional styles for new pages ----
  static final TextStyle h4Bold = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static final TextStyle h5Bold = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static final TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static final TextStyle bodyBold = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
}
