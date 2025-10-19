import 'package:flutter/material.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/custom_button.dart';

class CriarAnuncioPerdido01 extends StatelessWidget {
  const CriarAnuncioPerdido01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anúncio Perdido - Etapa 1')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CustomInput(label: 'Situação: Perdido'),
            const SizedBox(height: 15),
            const CustomInput(label: 'Espécie'),
            const SizedBox(height: 15),
            const CustomInput(label: 'Gênero'),
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
                  onPressed: () => Navigator.pushNamed(context, '/perdido2'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}