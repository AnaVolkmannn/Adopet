import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool small;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.small = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? const Size(150, 45) : const Size(225, 45);
    final buttonColor = color ?? AppColors.primary;

    return ElevatedButton(
      onPressed: onPressed,
      style: AppStyles.buttonStyle(
        backgroundColor: buttonColor,
        size: size,
      ),
      child: Text(text),
    );
  }
}