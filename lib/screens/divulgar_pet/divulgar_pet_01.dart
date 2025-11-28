import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_input.dart';

class DivulgarPet01 extends StatefulWidget {
  const DivulgarPet01({super.key});

  @override
  State<DivulgarPet01> createState() => _DivulgarPet01State();
}

class _DivulgarPet01State extends State<DivulgarPet01> {
  final picker = ImagePicker();

  // Campos gerais
  String? especieSelecionada;
  String? generoSelecionado;
  String? porteSelecionado;

  // Pet único
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeAnosController = TextEditingController();
  final TextEditingController idadeMesesController = TextEditingController();
  bool petSemNome = false;

  final List<File> fotosPetUnico = [];

  final List<String> especies = ['Gato', 'Cachorro'];
  final List<String> generos = ['Macho', 'Fêmea'];
  final List<String> portes = ['Pequeno', 'Médio', 'Grande'];

  // 🔹 CONTROLE DE EDIÇÃO
  bool _isEdit = false;
  Map<String, dynamic>? _originalData;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _originalData = Map<String, dynamic>.from(args);
      _isEdit = (_originalData?['mode'] == 'edit');

      if (_isEdit) {
        // Preenche campos com dados do anúncio existente
        petSemNome = _originalData?['noName'] ?? false;

        if (!petSemNome) {
          nomeController.text = _originalData?['name'] ?? '';
        }

        especieSelecionada = _originalData?['species'];
        generoSelecionado = _originalData?['gender'];
        porteSelecionado = _originalData?['size'];

        final ageYears = _originalData?['ageYears'];
        final ageMonths = _originalData?['ageMonths'];

        if (ageYears != null) {
          idadeAnosController.text = ageYears.toString();
        }
        if (ageMonths != null) {
          idadeMesesController.text = ageMonths.toString();
        }

        // Fotos: se quiser tratar edição de fotos depois, aqui é o lugar :)
      }
    }

    _initialized = true;
  }

  @override
  void dispose() {
    nomeController.dispose();
    idadeAnosController.dispose();
    idadeMesesController.dispose();
    super.dispose();
  }

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

  // 🚀 VALIDAÇÃO + ENVIO DOS DADOS PARA A TELA 2
  void _prosseguir() {
    // Validação dos campos obrigatórios básicos
    if ((!petSemNome && nomeController.text.isEmpty) ||
        especieSelecionada == null ||
        generoSelecionado == null ||
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

    // 🔹 Validação da idade (anos e meses)
    final String anosText = idadeAnosController.text.trim();
    final String mesesText = idadeMesesController.text.trim();

    final bool temAnos = anosText.isNotEmpty;
    final bool temMeses = mesesText.isNotEmpty;

    // Pelo menos um dos campos deve ser preenchido
    if (!temAnos && !temMeses) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a idade em anos e/ou meses.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    int? ageYears;
    int? ageMonths;

    if (temAnos) {
      ageYears = int.tryParse(anosText);
      if (ageYears == null || ageYears < 0 || ageYears >= 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Os anos devem ser um número entre 1 e 19.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }
    }

    if (temMeses) {
      ageMonths = int.tryParse(mesesText);
      if (ageMonths == null || ageMonths <= 0 || ageMonths >= 12) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Os meses devem ser um número entre 1 e 11.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }
    }

    // 🔥 MONTA O MAP COM BASE NO QUE JÁ EXISTIA + O QUE FOI EDITADO/CRIADO AQUI
    final Map<String, dynamic> petData = {
      // se estiver editando, preserva tudo que veio do anúncio (petId, adType, state, etc.)
      ...?_originalData,

      // garante que o modo continua consistente
      'mode': _isEdit ? 'edit' : 'create',

      // sobrescreve com os dados atuais da tela 1
      'name': petSemNome ? null : nomeController.text.trim(),
      'noName': petSemNome,
      'species': especieSelecionada,
      'gender': generoSelecionado,
      'size': porteSelecionado,
      'ageYears': ageYears,
      'ageMonths': ageMonths,

      // novas fotos (se o usuário adicionou agora)
      'photos': fotosPetUnico,
    };

    // 👉 MANDANDO PARA A TELA 2
    Navigator.pushNamed(
      context,
      '/divulgar2',
      arguments: petData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      title: _isEdit ? 'Editar Anúncio' : 'Criar Anúncio',
      subtitle: _isEdit
          ? 'Atualize as informações do seu pet'
          : 'Divulgue um pet seu ou um pet perdido para adoção responsável',
      onBack: () => Navigator.pop(context),
      onNext: _prosseguir,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildPetUnico()],
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
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
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
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
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
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
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

            // 📸 Botão adicionar foto
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