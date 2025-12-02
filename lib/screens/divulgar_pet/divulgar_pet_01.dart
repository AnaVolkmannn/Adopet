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

  // -----------------------------
  // CAMPOS DO PET
  // -----------------------------
  String? especieSelecionada;
  String? generoSelecionado;
  String? porteSelecionado;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeAnosController = TextEditingController();
  final TextEditingController idadeMesesController = TextEditingController();
  bool petSemNome = false;

  // Duas listas separadas:
  List<String> fotosExistentes = []; // URLs já no Firebase
  List<File> fotosNovas = [];        // Arquivos escolhidos agora

  final List<String> especies = ['Gato', 'Cachorro'];
  final List<String> generos = ['Macho', 'Fêmea'];
  final List<String> portes = ['Pequeno', 'Médio', 'Grande'];

  // CONTROLE DE EDIÇÃO
  bool _isEdit = false;
  Map<String, dynamic>? _originalData;
  bool _initialized = false;

  int get _totalFotos => fotosExistentes.length + fotosNovas.length;

  bool get _podeAvancar {
    final hasNameOrNoName = petSemNome || nomeController.text.trim().isNotEmpty;
    final hasBasicFields =
        hasNameOrNoName &&
        especieSelecionada != null &&
        generoSelecionado != null &&
        porteSelecionado != null;

    final anosText = idadeAnosController.text.trim();
    final mesesText = idadeMesesController.text.trim();
    final idadePreenchida = anosText.isNotEmpty || mesesText.isNotEmpty;

    final hasFoto = _totalFotos > 0;

    return hasBasicFields && idadePreenchida && hasFoto;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _originalData = Map<String, dynamic>.from(args);
      _isEdit = (_originalData?['mode'] == 'edit');

      if (_isEdit) {
        petSemNome = _originalData?['noName'] ?? false;
        if (!petSemNome) {
          nomeController.text = _originalData?['name'] ?? '';
        }

        especieSelecionada = _originalData?['species'];
        generoSelecionado = _originalData?['gender'];
        porteSelecionado = _originalData?['size'];

        final ageYears = _originalData?['ageYears'];
        final ageMonths = _originalData?['ageMonths'];
        if (ageYears != null) idadeAnosController.text = ageYears.toString();
        if (ageMonths != null) idadeMesesController.text = ageMonths.toString();

        // Carregar fotos existentes
        final raw = _originalData?['photoUrls'];
        if (raw is List) {
          fotosExistentes = raw.whereType<String>().toList();
        }
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

  // Selecionar imagem
  Future<void> _selecionarImagemUnica() async {
    final total = _totalFotos;

    if (total >= 3) {
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
      setState(() => fotosNovas.add(File(pickedFile.path)));
    }
  }

  // Prosseguir
  void _prosseguir() {
    // Campos obrigatórios básicos
    if ((!petSemNome && nomeController.text.isEmpty) ||
        especieSelecionada == null ||
        generoSelecionado == null ||
        porteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Preencha todos os campos obrigatórios antes de prosseguir.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    // Idade obrigatória
    final anosText = idadeAnosController.text.trim();
    final mesesText = idadeMesesController.text.trim();

    if (anosText.isEmpty && mesesText.isEmpty) {
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

    if (anosText.isNotEmpty) {
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

    if (mesesText.isNotEmpty) {
      ageMonths = int.tryParse(mesesText);
      if (ageMonths! < 0 || ageMonths! > 11) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Os meses devem ser um número entre 0 e 11.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }
    }

    // Pelo menos 1 foto obrigatória
    if (_totalFotos == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos 1 foto do pet para continuar.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    // Enviar para a próxima tela
    final Map<String, dynamic> petData = {
      ...?_originalData,
      'mode': _isEdit ? 'edit' : 'create',
      'name': petSemNome ? null : nomeController.text.trim(),
      'noName': petSemNome,
      'species': especieSelecionada,
      'gender': generoSelecionado,
      'size': porteSelecionado,
      'ageYears': ageYears,
      'ageMonths': ageMonths,

      'existingPhotos': fotosExistentes,
      'newPhotos': fotosNovas,
    };

    Navigator.pushNamed(context, '/divulgar2', arguments: petData);
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
      // 🔥 novo: controla visualmente o botão "Próximo"
      nextEnabled: _podeAvancar,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildPetUnico()],
        ),
      ),
    );
  }

  // -------------------------
  // 🐶 PET ÚNICO
  // -------------------------
  Widget _buildPetUnico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome do pet
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome do pet',
              style: _labelStyle,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nomeController,
              maxLines: 1,
              enabled: !petSemNome,
              onChanged: (_) => setState(() {}), // atualiza _podeAvancar
              decoration: _decoracaoCampoAdopet(
                petSemNome
                    ? 'Pet sem nome'
                    : 'Digite o nome do pet (se houver)',
              ),
            ),
          ],
        ),

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

        // ----------------------------
        // FOTOS
        // ----------------------------
        const Text('Adicione pelo menos 1 foto', style: _labelStyle),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Fotos existentes
            for (int i = 0; i < fotosExistentes.length; i++)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      fotosExistentes[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => fotosExistentes.removeAt(i));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Fotos novas
            for (int i = 0; i < fotosNovas.length; i++)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      fotosNovas[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => fotosNovas.removeAt(i));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Botão de adicionar foto
            if (_totalFotos < 3)
              GestureDetector(
                onTap: () async {
                  await _selecionarImagemUnica();
                  setState(() {}); // atualiza contador e _podeAvancar
                },
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

        const SizedBox(height: 8),

        // 🔥 Badge de quantidade de fotos
        Text(
          '$_totalFotos/3 fotos adicionadas',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: _totalFotos == 0
                ? const Color(0xFFDC004E)
                : Colors.black54,
            fontWeight:
                _totalFotos == 0 ? FontWeight.w600 : FontWeight.w400,
          ),
        ),

        const SizedBox(height: 25),

        // ----------------------------
        // DROPDOWN — ESPÉCIE
        // ----------------------------
        const Text('Espécie', style: _labelStyle),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: especieSelecionada,
          decoration: _decoracaoCampoAdopet("Selecione a espécie"),
          dropdownColor: const Color(0xFFFFE6EC),
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
          items: especies
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => especieSelecionada = v),
        ),

        const SizedBox(height: 20),

        // ----------------------------
        // DROPDOWN — GÊNERO
        // ----------------------------
        const Text('Gênero', style: _labelStyle),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: generoSelecionado,
          decoration: _decoracaoCampoAdopet("Selecione o gênero"),
          dropdownColor: const Color(0xFFFFE6EC),
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
          items: generos
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => generoSelecionado = v),
        ),

        const SizedBox(height: 20),

        // ----------------------------
        // DROPDOWN — PORTE
        // ----------------------------
        const Text('Porte do pet', style: _labelStyle),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: porteSelecionado,
          decoration: _decoracaoCampoAdopet("Selecione o porte"),
          dropdownColor: const Color(0xFFFFE6EC),
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
          items: portes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => porteSelecionado = v),
        ),

        const SizedBox(height: 25),

        // ----------------------------
        // IDADE
        // ----------------------------
        const Text('Idade do pet', style: _labelStyle),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anos', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(
                    controller: idadeAnosController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: _decoracaoCampoAdopet('Ex: 2'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Meses', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(
                    controller: idadeMesesController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: _decoracaoCampoAdopet('Ex: 6'),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ----------------------------
  // ESTILOS
  // ----------------------------
  static const _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    color: Color(0xFFDC004E),
    fontWeight: FontWeight.w600,
  );

  static InputDecoration _decoracaoCampoAdopet(String hint) {
    return const InputDecoration(
      filled: true,
      fillColor: Color(0xFFFFE6EC),
      hintText: null,
    ).copyWith(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontFamily: 'Poppins',
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }
}
