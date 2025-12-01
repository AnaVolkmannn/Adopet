import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),
      body: Stack(
        children: [
          // ⭐ Conteúdo principal mais alto
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 300), 
              // ↑ Adicionei padding superior de 40 pixels
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🌟 Logo do Adopet
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Bem-vindo ao Adopet 💗',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5A4636),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Conectamos adotantes e protetores para promover o amor e reduzir o abandono.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7B6A58),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  CustomButton(
                    text: 'VAMOS COMEÇAR!',
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                  ),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      'Já tenho uma conta',
                      style: TextStyle(
                        color: Color(0xFFFF5C00),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🐾 Gatinho no rodapé, intacto
          Positioned(
            bottom: -100,
            left: 0,
            right: 60,
            child: Image.asset(
              'assets/images/gatinho.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}