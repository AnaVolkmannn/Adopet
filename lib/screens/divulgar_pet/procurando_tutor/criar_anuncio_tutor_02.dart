import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_button.dart';

class CriarAnuncioTutor02 extends StatelessWidget {
  const CriarAnuncioTutor02({super.key});

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      title: 'Criar Anúncio',
      subtitle: 'Ao criar um anúncio, você terá acesso ao Painel de Busca',
      onBack: () => Navigator.pop(context),
      onNext: () => Navigator.pushNamed(context, '/tutor3'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🐾 Título da seção
          const Text(
            'Selecione uma foto do pet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFFDC004E),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 25),

          // 🖼️ Área de imagem
          GestureDetector(
            onTap: () {
              // TODO: implementar seleção de imagem (galeria/câmera)
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE6EC),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFDC004E).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_a_photo,
                  size: 60,
                  color: Color(0xFFDC004E),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Adicione uma foto nítida do pet para ajudar o tutor a reconhecê-lo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFFFF5C00),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
