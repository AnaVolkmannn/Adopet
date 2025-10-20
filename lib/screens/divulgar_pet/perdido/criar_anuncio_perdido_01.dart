import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';

class CriarAnuncioPerdido01 extends StatefulWidget {
  const CriarAnuncioPerdido01({super.key});

  @override
  State<CriarAnuncioPerdido01> createState() => _CriarAnuncioPerdido01State();
}

class _CriarAnuncioPerdido01State extends State<CriarAnuncioPerdido01> {
  String? situacaoSelecionada;

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: () {
        if (situacaoSelecionada == 'Perdido') {
          Navigator.pushNamed(context, '/perdido2');
        } else if (situacaoSelecionada == 'Procurando Tutor') {
          Navigator.pushNamed(context, '/tutor2');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6EC),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              'Vamos começar com algumas informações básicas!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFDC004E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            'Situação',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFFDC004E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: situacaoSelecionada,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFF7E6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFDC004E)),
              ),
            ),
            hint: const Text(
              'Selecione uma opção',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            items: const [
              DropdownMenuItem(value: 'Perdido', child: Text('Perdido')),
              DropdownMenuItem(
                value: 'Procurando Tutor',
                child: Text('Procurando Tutor'),
              ),
            ],
            onChanged: (value) {
              setState(() => situacaoSelecionada = value);
            },
          ),
        ],
      ),
    );
  }
}
