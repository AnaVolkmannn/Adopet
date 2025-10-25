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
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController corOlhosController = TextEditingController();
  bool petSemNome = false;
  String? racaSelecionada;
  String? corSelecionada;
  String? porteSelecionado;
  final List<File> fotosPetUnico = [];

  // Ninhada
  int qtdMachos = 0;
  int qtdFemeas = 0;
  final Map<String, List<File?>> fotosPorGenero = {'Macho': [], 'Fêmea': []};

  final List<String> especies = ['Gato', 'Cachorro', 'Outro'];
  final List<String> generos = ['Macho', 'Fêmea'];
  final List<String> racas = [
    'Sem raça definida',
    'Labrador',
    'Vira-lata',
    'Persa',
    'Siamês',
    'Poodle',
    'Outro',
  ];
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

  Future<void> _selecionarImagem(String genero, int index) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        fotosPorGenero[genero]![index] = File(pickedFile.path);
      });
    }
  }

  // 🚀 Validação
  void _prosseguir() {
    if (tipoAnuncio == 'Pet único') {
      if ((!petSemNome && nomeController.text.isEmpty) ||
          especieSelecionada == null ||
          generoSelecionado == null ||
          // 🔧 DESATIVADO PARA TESTE -> fotosPetUnico.isEmpty ||
          idadeController.text.isEmpty ||
          racaSelecionada == null ||
          corSelecionada == null ||
          corOlhosController.text.isEmpty ||
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
    } else {
      if (especieSelecionada == null || (qtdMachos + qtdFemeas == 0)
      // 🔧 DESATIVADO PARA TESTE -> || !_todasFotosSelecionadas()
      ) {
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
    }

    Navigator.pushNamed(context, '/perdido6');
  }

  bool _todasFotosSelecionadas() {
    for (var entry in fotosPorGenero.entries) {
      for (var foto in entry.value) {
        if (foto == null) return false;
      }
    }
    return true;
  }

  void _atualizarListas() {
    fotosPorGenero['Macho'] = List.generate(
      qtdMachos,
      (index) => fotosPorGenero['Macho']!.length > index
          ? fotosPorGenero['Macho']![index]
          : null,
    );
    fotosPorGenero['Fêmea'] = List.generate(
      qtdFemeas,
      (index) => fotosPorGenero['Fêmea']!.length > index
          ? fotosPorGenero['Fêmea']![index]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    _atualizarListas();

    return AnuncioBaseScreen(
      title: 'Criar Anúncio',
      subtitle: 'Divulgue um pet ou uma ninhada para adoção responsável',
      onBack: () => Navigator.pop(context),
      onNext: _prosseguir,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de anúncio
            const Text('Tipo de Anúncio', style: _labelStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tipoAnuncio,
              decoration: _decoracaoCampo(),
              items: const [
                DropdownMenuItem(value: 'Pet único', child: Text('Pet único')),
                DropdownMenuItem(
                  value: 'Ninhada de filhotes',
                  child: Text('Ninhada de filhotes'),
                ),
              ],
              onChanged: (v) => setState(() => tipoAnuncio = v!),
            ),
            const SizedBox(height: 20),

            // =====================
            // 🐾 PET ÚNICO
            // =====================
            if (tipoAnuncio == 'Pet único') ...[
              if (!petSemNome)
                CustomInput(
                  label: 'Nome do pet',
                  hint: 'Digite o nome do pet (se houver)',
                  controller: nomeController,
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

              // Espécie e gênero
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

              // 📸 Fotos (limite 3)
              const Text(
                'Fotos (até 3) — opcional por enquanto 🔧',
                style: _labelStyle,
              ),
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
                          onTap: () =>
                              setState(() => fotosPetUnico.removeAt(i)),
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

              // Idade, Raça
              CustomInput(
                label: 'Idade (em meses ou anos)',
                hint: 'Ex: 2 anos',
                controller: idadeController,
              ),
              const SizedBox(height: 20),

              const Text('Raça', style: _labelStyle),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: racaSelecionada,
                decoration: _decoracaoCampo(),
                hint: const Text('Selecione a raça'),
                items: racas
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => racaSelecionada = v),
              ),
              const SizedBox(height: 20),

              // Cor e olhos
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

              CustomInput(
                label: 'Cor dos olhos',
                hint: 'Ex: Castanhos, azuis...',
                controller: corOlhosController,
              ),
              const SizedBox(height: 20),

              // Porte
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
            ],

            // =====================
            // 🍼 NINHADA
            // =====================
            if (tipoAnuncio == 'Ninhada de filhotes') ...[
              const Text('Quantos filhotes há na ninhada?', style: _labelStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      label: 'Machos',
                      hint: '0',
                      controller: TextEditingController(
                        text: qtdMachos.toString(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        setState(() {
                          qtdMachos = int.tryParse(v) ?? 0;
                          _atualizarListas();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomInput(
                      label: 'Fêmeas',
                      hint: '0',
                      controller: TextEditingController(
                        text: qtdFemeas.toString(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        setState(() {
                          qtdFemeas = int.tryParse(v) ?? 0;
                          _atualizarListas();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              if (qtdMachos + qtdFemeas > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adicione uma foto para cada filhote (opcional)',
                      style: _labelStyle,
                    ),
                    const SizedBox(height: 10),
                    _buildFotoSection('Macho', qtdMachos),
                    const SizedBox(height: 16),
                    _buildFotoSection('Fêmea', qtdFemeas),
                  ],
                ),
            ],
          ],
        ),
      ),
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

  Widget _buildFotoSection(String genero, int quantidade) {
    if (quantidade == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(quantidade, (index) {
        final foto = fotosPorGenero[genero]![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _selecionarImagem(genero, index),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFDC004E), width: 1.5),
                image: foto != null
                    ? DecorationImage(image: FileImage(foto), fit: BoxFit.cover)
                    : null,
              ),
              child: foto == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo,
                            color: Color(0xFFDC004E),
                            size: 30,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$genero ${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFFDC004E),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
