import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_button.dart';

class CriarAnuncioPerdido02 extends StatelessWidget {
  const CriarAnuncioPerdido02({super.key});

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: () => Navigator.pushNamed(context, '/perdido3'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💬 Título da seção
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6EC),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              'Vamos adicionar uma foto do seu pet!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFDC004E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            'Selecionar foto do animal',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDC004E),
            ),
          ),
          const SizedBox(height: 20),

          // 📸 Botão para selecionar imagem
          Center(
            child: CustomButton(
              text: 'Selecionar Foto',
              onPressed: () {
                // TODO: implementar seletor de imagem
              },
            ),
          ),

          const SizedBox(height: 30),

          // 🖼️ Placeholder da imagem selecionada (futuro)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFDC004E)),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                color: Color(0xFFDC004E),
                size: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
