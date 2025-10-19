import 'package:flutter/material.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomInput(label: 'Nome de usuário'),
            const SizedBox(height: 15),
            const CustomInput(label: 'E-mail'),
            const SizedBox(height: 15),
            const CustomInput(label: 'Senha', obscure: true),
            const SizedBox(height: 25),
            CustomButton(
              text: 'Criar conta',
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Já tenho uma conta'),
            ),
          ],
        ),
      ),
    );
  }
}