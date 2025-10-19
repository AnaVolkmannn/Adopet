import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../core/theme.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: AppColors.primary),
              const SizedBox(height: 30),
              const Text(
                'Anúncio salvo com sucesso!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                'Seu pet agora está visível para toda a comunidade 🐾',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'Voltar ao início',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}