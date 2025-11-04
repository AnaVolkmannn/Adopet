import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vindo ao Adopet 🐾',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Criar Conta',
              onPressed: () => Navigator.pushNamed(context, '/signup'),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Já tenho uma conta',
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ],
        ),
      ),
    );
  }
}