import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_input.dart';

class DivulgarPetStart extends StatefulWidget {
  const DivulgarPetStart({super.key});

  @override
  State<DivulgarPetStart> createState() => _DivulgarPetStartState();
}

class _DivulgarPetStartState extends State<DivulgarPetStart> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  String? especieSelecionada;
  String? generoSelecionado;
  bool petSemNome = false; // 🔹 Novo estado

  final List<String> especies = ['Gato', 'Cachorro', 'Outro'];
  final List<String> generos = ['Macho', 'Fêmea'];

  void _prosseguir() {
    // 🔸 Validação flexível: ignora nome se "Pet sem nome" estiver marcado
    if ((!petSemNome && nomeController.text.isEmpty) ||
        especieSelecionada == null ||
        generoSelecionado == null ||
        descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos antes de prosseguir.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/perdido2');
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      title: 'Criar Anúncio',
      subtitle: 'Divulgue um pet para adoção responsável',
      onBack: () => Navigator.pop(context),
      onNext: _prosseguir,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🐾 Nome do pet
            if (!petSemNome)
              CustomInput(
                label: 'Nome do pet',
                hint: 'Digite o nome do pet (se houver)',
                controller: nomeController,
              ),
            if (!petSemNome) const SizedBox(height: 8),

            // ☑️ Checkbox “Pet sem nome”
            Row(
              children: [
                Checkbox(
                  value: petSemNome,
                  activeColor: const Color(0xFFDC004E),
                  onChanged: (v) {
                    setState(() {
                      petSemNome = v ?? false;
                      if (petSemNome) nomeController.clear();
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'Pet sem nome',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: Color(0xFFDC004E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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

            const SizedBox(height: 20),

            // ✍️ Descrição
            CustomInput(
              label: 'Por que está anunciando para adoção?',
              hint:
                  'Conte um pouco do motivo do anúncio: mudança, resgate, ninhada, etc.',
              controller: descricaoController,
            ),
          ],
        ),
      ),
    );
  }
}
