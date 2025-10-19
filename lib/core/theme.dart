import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFDC004E);
  static const secondary = Color(0xFFFF5C00);
  static const background = Color(0xFFFFF7E6);
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
}

class AppFonts {
  static final poppins = GoogleFonts.poppins();
  static final interBold = GoogleFonts.inter(fontWeight: FontWeight.bold);
}

class AppStyles {
  static const double borderRadius = 15.0;

  static ButtonStyle buttonStyle({
    Color backgroundColor = AppColors.primary,
    Size size = const Size(225, 45),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      minimumSize: size,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: AppColors.textPrimary,
  ),
  useMaterial3: true,
);
