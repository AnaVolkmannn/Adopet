import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_input.dart';

class CriarAnuncioPerdido04 extends StatelessWidget {
  const CriarAnuncioPerdido04({super.key});

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: () => Navigator.pushNamed(context, '/perdido5'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💬 Introdução
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(0.15), // tom suave do laranja
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Fale um pouco mais sobre o seu pet 💕',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 🐾 Nome do pet
          CustomInput(label: 'Nome do pet', hint: 'Digite o nome do seu pet'),
          const SizedBox(height: 20),

          // ✍️ Descrição
          const Text(
            'Descrição',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFFDC004E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFF7E6),
              hintText: 'Conte mais detalhes: comportamento, sinais, etc.',
              hintStyle: const TextStyle(
                color: Colors.black38,
                fontFamily: 'Poppins',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFDC004E)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
