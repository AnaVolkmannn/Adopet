import 'package:flutter/material.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/custom_button.dart';

class CriarAnuncioPerdido06 extends StatefulWidget {
  const CriarAnuncioPerdido06({super.key});

  @override
  State<CriarAnuncioPerdido06> createState() => _CriarAnuncioPerdido06State();
}

class _CriarAnuncioPerdido06State extends State<CriarAnuncioPerdido06> {
  bool aceitouDeclaracao = false;

  void _salvar(BuildContext context) {
    if (!aceitouDeclaracao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa marcar a declaração de veracidade.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, '/success', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E6),
        elevation: 0,
        title: const Text(
          'Anúncio Perdido - Etapa 6',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Color(0xFFDC004E),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFDC004E)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomInput(
                label: 'Data do desaparecimento',
                hint: 'Ex: 12/10/2025',
              ),
              const SizedBox(height: 15),
              const CustomInput(label: 'Seu telefone', hint: '(47) 99999-9999'),
              const SizedBox(height: 20),

              // ✅ Check de veracidade obrigatório
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: aceitouDeclaracao,
                    activeColor: const Color(0xFFDC004E),
                    onChanged: (v) =>
                        setState(() => aceitouDeclaracao = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'DECLARO A VERACIDADE DOS FATOS INSERIDOS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC004E),
                      ),
                    ),
                  ),
                ],
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
                    text: 'Salvar',
                    small: true,
                    onPressed: () =>
                        _salvar(context), // só salva se checkbox marcada
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
