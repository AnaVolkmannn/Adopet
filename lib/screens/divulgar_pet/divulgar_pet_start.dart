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
  String tipoAnuncio = 'Pet único';
  String? especieSelecionada;
  String? generoSelecionado;
  int qtdMachos = 0;
  int qtdFemeas = 0;

  // Armazenar as fotos selecionadas
  final Map<String, List<File?>> fotosPorGenero = {'Macho': [], 'Fêmea': []};

  final List<String> especies = ['Gato', 'Cachorro', 'Outro'];
  final List<String> generos = ['Macho', 'Fêmea'];

  // 🩷 Selecionar imagem da galeria
  Future<void> _selecionarImagem(String genero, int index) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        fotosPorGenero[genero]![index] = File(pickedFile.path);
      });
    }
  }

  // 🚀 Validação e prosseguir
  void _prosseguir() {
    if (tipoAnuncio == 'Pet único') {
      if (especieSelecionada == null || generoSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preencha todos os campos antes de prosseguir.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }
    } else {
      if (especieSelecionada == null ||
          (qtdMachos + qtdFemeas == 0) ||
          !_todasFotosSelecionadas()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Preencha todos os campos e adicione todas as fotos.',
            ),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }
    }

    Navigator.pushNamed(context, '/perdido2');
  }

  bool _todasFotosSelecionadas() {
    for (var entry in fotosPorGenero.entries) {
      for (var foto in entry.value) {
        if (foto == null) return false;
      }
    }
    return true;
  }

  // 🔄 Atualiza listas de fotos conforme a quantidade digitada
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
            const Text(
              'Tipo de Anúncio',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Color(0xFFDC004E),
                fontWeight: FontWeight.w600,
              ),
            ),
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

            // Espécie
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
              decoration: _decoracaoCampo(),
              hint: const Text('Selecione a espécie'),
              items: especies
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => especieSelecionada = v),
            ),

            const SizedBox(height: 20),

            // Gênero (Pet único)
            if (tipoAnuncio == 'Pet único') ...[
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
                decoration: _decoracaoCampo(),
                hint: const Text('Selecione o gênero'),
                items: generos
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => generoSelecionado = v),
              ),
            ],

            // Campos de quantidade (Ninhada)
            if (tipoAnuncio == 'Ninhada de filhotes') ...[
              const Text(
                'Quantos filhotes há na ninhada?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Color(0xFFDC004E),
                  fontWeight: FontWeight.w600,
                ),
              ),
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

              // Upload das fotos
              if (qtdMachos + qtdFemeas > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adicione uma foto para cada filhote',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Color(0xFFDC004E),
                        fontWeight: FontWeight.w600,
                      ),
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
