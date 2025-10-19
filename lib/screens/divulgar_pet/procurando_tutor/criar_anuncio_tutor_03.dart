import 'package:flutter/material.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/custom_button.dart';

class CriarAnuncioTutor03 extends StatelessWidget {
  const CriarAnuncioTutor03({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anúncio Tutor - Etapa 3')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomInput(label: 'Raça'),
              const SizedBox(height: 15),
              const CustomInput(label: 'Porte'),
              const SizedBox(height: 15),
              const CustomInput(label: 'Cor predominante'),
              const SizedBox(height: 15),
              const CustomInput(label: 'Cor dos olhos'),
              const SizedBox(height: 15),
              const CustomInput(label: 'Idade'),
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
                    onPressed: () => Navigator.pushNamed(context, '/tutor4'),
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