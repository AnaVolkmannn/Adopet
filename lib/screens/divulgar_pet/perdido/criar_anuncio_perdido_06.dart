import 'package:flutter/material.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/custom_button.dart';

class CriarAnuncioPerdido06 extends StatelessWidget {
  const CriarAnuncioPerdido06({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anúncio Perdido - Etapa 6')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomInput(label: 'Data do desaparecimento'),
              const SizedBox(height: 15),
              const CustomInput(label: 'Seu telefone'),
              const SizedBox(height: 15),
              const CustomInput(label: 'Declaração de veracidade dos fatos'),
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
                    text: 'Salvar',
                    small: true,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/success', (route) => false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}