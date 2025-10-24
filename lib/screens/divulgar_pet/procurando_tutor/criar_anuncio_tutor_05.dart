import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_input.dart';

class CriarAnuncioTutor05 extends StatelessWidget {
  const CriarAnuncioTutor05({super.key});

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: () => Navigator.pushNamed(context, '/tutor6'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💬 Introdução
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Informe onde o pet foi visto pela última vez 🐾',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 📍 Campo de endereço
          CustomInput(
            label: 'Endereço onde o animal foi visto',
            hint: 'Ex: Rua das Flores, 123 - Centro, Jaraguá do Sul',
          ),
        ],
      ),
    );
  }
}
