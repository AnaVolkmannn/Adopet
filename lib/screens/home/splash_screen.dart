import 'package:flutter/material.dart';
import '../../../core/theme.dart'; // usa suas cores

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ⏳ Espera 3 segundos e vai pra próxima tela
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // 🌸 Fundo rosa
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🐾 Sua logo centralizada
            Image.asset(
              'assets/images/logov2.png', // caminho da sua logo
              width: 500,
              height: 500,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}