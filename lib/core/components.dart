import 'package:flutter/material.dart';
import 'theme.dart';
import 'spacing.dart';
import 'package:google_fonts/google_fonts.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool small;
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.small = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = small
        ? const Size(150, 45)
        : const Size(225, 45);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: AppColors.textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        minimumSize: size,
        textStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class AppInput extends StatelessWidget {
  final String label;
  final bool obscure;

  const AppInput({super.key, required this.label, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.textLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          color: AppColors.textDark.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
