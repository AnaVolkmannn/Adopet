import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_input.dart';

class DivulgarPetStart extends StatefulWidget {
  const DivulgarPetStart({super.key});

  @override
  State<DivulgarPetStart> createState() => _DivulgarPetStartState();
}

class _DivulgarPetStartState extends State<DivulgarPetStart> {
  final picker = ImagePicker();

  // Campos gerais
  String tipoAnuncio = 'Pet único';
  String? especieSelecionada;
  String? generoSelecionado;

  // Pet único
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeAnosController = TextEditingController();
  final TextEditingController idadeMesesController = TextEditingController();
  final TextEditingController corOlhosController = TextEditingController();
  bool petSemNome = false;
  String? corSelecionada;
  String? porteSelecionado;
  final List<File> fotosPetUnico = [];

  final List<String> especies = ['Gato', 'Cachorro'];
  final List<String> generos = ['Macho', 'Fêmea'];
  final List<String> cores = [
    'Preto',
    'Branco',
    'Marrom',
    'Cinza',
    'Caramelo',
    'Mesclado',
  ];
  final List<String> portes = ['Pequeno', 'Médio', 'Grande'];

  // 📸 Selecionar imagem
  Future<void> _selecionarImagemUnica() async {
    if (fotosPetUnico.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você pode adicionar até 3 fotos.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => fotosPetUnico.add(File(pickedFile.path)));
    }
  }

  // 🚀 Validação
  void _prosseguir() {
    bool idadeValida = idadeAnosController.text.isNotEmpty ||
        idadeMesesController.text.isNotEmpty;

    // ⚠️ Agora não exige fotos
    if ((!petSemNome && nomeController.text.isEmpty) ||
        especieSelecionada == null ||
        generoSelecionado == null ||
        !idadeValida ||
        corSelecionada == null ||
        porteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos obrigatórios antes de prosseguir.',
          ),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/perdido6');
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      title: 'Criar Anúncio',
      subtitle: 'Divulgue um pet ou uma ninhada para adoção responsável',
      onBack: () => Navigator.pop(context),
      onNext: _prosseguir,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPetUnico(),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // 🐶 PET ÚNICO
  // -------------------------------
  Widget _buildPetUnico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!petSemNome)
          CustomInput(
            label: 'Nome do pet',
            hint: 'Digite o nome do pet (se houver)',
            controller: nomeController,
            maxLines: 1,
          ),
        if (!petSemNome) const SizedBox(height: 8),
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
            const Text(
              'Pet sem nome',
              style: TextStyle(
                color: Color(0xFFDC004E),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text('Espécie', style: _labelStyle),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: especieSelecionada,
          decoration: _decoracaoCampo(),
          hint: const Text('Selecione a espécie'),
          items: especies
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => especieSelecionada = v),
        ),
        const SizedBox(height: 20),

        const Text('Gênero', style: _labelStyle),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: generoSelecionado,
          decoration: _decoracaoCampo(),
          hint: const Text('Selecione o gênero'),
          items: generos
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => generoSelecionado = v),
        ),
        const SizedBox(height: 20),

        const Text('Porte do pet', style: _labelStyle),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: porteSelecionado,
          decoration: _decoracaoCampo(),
          hint: const Text('Selecione o porte'),
          items: portes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => porteSelecionado = v),
        ),
        const SizedBox(height: 20),

        // 📸 Fotos
        const Text('Fotos (até 3) — opcional', style: _labelStyle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < fotosPetUnico.length; i++)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      fotosPetUnico[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => fotosPetUnico.removeAt(i)),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            // 📸 Placeholder para adicionar novas imagens
            GestureDetector(
              onTap: _selecionarImagemUnica,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDC004E),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Color(0xFFDC004E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),

        // Idade
        const Text('Idade do pet', style: _labelStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomInput(
                label: 'Anos',
                hint: 'Ex: 2',
                controller: idadeAnosController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomInput(
                label: 'Meses',
                hint: 'Ex: 6',
                controller: idadeMesesController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text('Cor predominante', style: _labelStyle),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: corSelecionada,
          decoration: _decoracaoCampo(),
          hint: const Text('Selecione a cor'),
          items: cores
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => corSelecionada = v),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static const _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    color: Color(0xFFDC004E),
    fontWeight: FontWeight.w600,
  );

  InputDecoration _decoracaoCampo() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFFF7E6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFDC004E)),
      ),
    );
  }
}
