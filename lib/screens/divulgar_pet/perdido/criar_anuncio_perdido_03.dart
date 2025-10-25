import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_input.dart';

class CriarAnuncioPerdido03 extends StatelessWidget {
  const CriarAnuncioPerdido03({super.key});

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: () => Navigator.pushNamed(context, '/perdido6'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🩷 Título introdutório
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(0.15), // tom suave de laranja
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Agora vamos detalhar as características do seu pet 🐾',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 🐶 Inputs estilizados
          CustomInput(label: 'Raça', hint: 'Digite a raça do animal'),
          const SizedBox(height: 15),
          CustomInput(label: 'Porte', hint: 'Pequeno, médio ou grande?'),
          const SizedBox(height: 15),
          CustomInput(
            label: 'Cor predominante',
            hint: 'Ex: marrom, preto, branco...',
          ),
          const SizedBox(height: 15),
          CustomInput(label: 'Cor dos olhos', hint: 'Ex: castanho, azul...'),
          const SizedBox(height: 15),
          CustomInput(label: 'Idade', hint: 'Ex: 2 anos, 6 meses...'),
        ],
      ),
    );
  }
}
