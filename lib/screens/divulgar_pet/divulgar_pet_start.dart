import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';

class DivulgarPetStart extends StatefulWidget {
  const DivulgarPetStart({super.key});

  @override
  State<DivulgarPetStart> createState() => _DivulgarPetStartState();
}

class _DivulgarPetStartState extends State<DivulgarPetStart> {
  String? situacaoSelecionada;
  String? especieSelecionada;
  String? generoSelecionado;

  final List<String> especies = ['Gato', 'Cachorro', 'Outro'];
  final List<String> generos = ['Macho', 'Fêmea'];

  void _prosseguir() {
    if (situacaoSelecionada == null ||
        especieSelecionada == null ||
        generoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos antes de prosseguir.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    // 🚀 Direcionamento correto de fluxo
    if (situacaoSelecionada == 'Perdido') {
      Navigator.pushNamed(context, '/perdido2');
    } else if (situacaoSelecionada == 'Procurando Tutor') {
      Navigator.pushNamed(context, '/tutor2'); // 🔥 atualizado
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: _prosseguir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💬 Mensagem introdutória
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

          // 🐾 Situação
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
            onChanged: (value) => setState(() => situacaoSelecionada = value),
          ),
          const SizedBox(height: 6),
          const Text(
            'Seu pet sumiu ou você encontrou um e quer achar o tutor',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFFFF5C00),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          // 🐶 Espécie
          const Text(
            'Espécie',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFFDC004E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: especieSelecionada,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFF7E6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFDC004E)),
              ),
            ),
            hint: const Text(
              'Selecione a espécie',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            items: especies
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => especieSelecionada = value),
          ),

          const SizedBox(height: 20),

          // 🧡 Gênero
          const Text(
            'Gênero',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFFDC004E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: generoSelecionado,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFF7E6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFDC004E)),
              ),
            ),
            hint: const Text(
              'Selecione o gênero',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            items: generos
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => generoSelecionado = value),
          ),
        ],
      ),
    );
  }
}
