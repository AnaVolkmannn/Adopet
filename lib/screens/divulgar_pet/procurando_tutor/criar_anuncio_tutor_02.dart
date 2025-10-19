import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';

class CriarAnuncioTutor02 extends StatelessWidget {
  const CriarAnuncioTutor02({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anúncio Tutor - Etapa 2')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Selecionar foto do animal'),
            const SizedBox(height: 25),
            CustomButton(
              text: 'Selecionar Foto',
              onPressed: () {},
            ),
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
                  onPressed: () => Navigator.pushNamed(context, '/tutor3'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}