import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'custom_drawer.dart'; // 👈 importa o menu lateral

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
    this.subtitle = 'Divulgar um pet para adoção responsável',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 Cor de fundo padrão
      backgroundColor: const Color(0xFFFFF7E6),

      // ☰ Menu lateral (Drawer global)
      endDrawer: const CustomDrawer(),

      // 🩷 Cabeçalho fixo
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(115),
        child: AppBar(
          backgroundColor: const Color(0xFFFFF7E6),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔙 Botão de voltar
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFDC004E),
                    ),
                    onPressed: onBack,
                  ),

                  const SizedBox(width: 4),

                  // 🩷 Título e subtítulo
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC004E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFFFF5C00),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 📄 Conteúdo da tela filha
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 80),
          child: SingleChildScrollView(child: child),
        ),
      ),

      // 🩶 Rodapé fixo com botões padrão
      bottomSheet: Container(
        color: const Color(0xFFFFF7E6),

        // 👉 Só margem inferior agora
        padding: const EdgeInsets.only(bottom: 60, left: 24, right: 24, top: 10),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomButton(
              text: 'Voltar',
              small: true,
              onPressed: onBack,
            ),
            CustomButton(
              text: 'Prosseguir',
              small: true,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
