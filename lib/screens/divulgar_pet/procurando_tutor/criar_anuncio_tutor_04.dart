import 'package:flutter/material.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/custom_button.dart';

class CriarAnuncioTutor04 extends StatelessWidget {
  const CriarAnuncioTutor04({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anúncio Tutor - Etapa 4')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CustomInput(label: 'Informações adicionais (opcional)'),
            const SizedBox(height: 15),
            const CustomInput(label: 'Observações sobre o animal'),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  text: 'Voltar',
                  small: true,
                  onPressed: () => Navigator.pop(context),
                ),
                CustomButton(
                  text: 'Prosseguir',
                  small: true,
                  onPressed: () => Navigator.pushNamed(context, '/tutor5'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}