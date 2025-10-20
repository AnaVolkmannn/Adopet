import 'package:flutter/material.dart';
import 'custom_button.dart';

class AnuncioBaseScreen extends StatelessWidget {
  final Widget child;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String title;
  final String subtitle;

  const AnuncioBaseScreen({
    super.key,
    required this.child,
    required this.onBack,
    required this.onNext,
    this.title = 'Criar Anúncio',
    this.subtitle = 'Ao criar um anúncio, você terá acesso ao Painel de Busca',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E6),
        elevation: 0,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC004E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFFFF5C00),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFDC004E)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            10,
            24,
            80,
          ), // espaço inferior fixo pros botões
          child: SingleChildScrollView(child: child),
        ),
      ),
      bottomSheet: Container(
        color: const Color(0xFFFFF7E6),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomButton(text: 'Voltar', small: true, onPressed: onBack),
            CustomButton(text: 'Prosseguir', small: true, onPressed: onNext),
          ],
        ),
      ),
    );
  }
}
