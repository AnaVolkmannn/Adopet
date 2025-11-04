import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/anuncio_base_screen.dart';
import '../../widgets/custom_input.dart';

class DivulgarPet02 extends StatefulWidget {
  const DivulgarPet02({super.key});

  @override
  State<DivulgarPet02> createState() => _DivulgarPet02State();
}

class _DivulgarPet02State extends State<DivulgarPet02> {
  String? _tipoSituacao;
  String? _estadoSelecionado;
  String? _cidadeSelecionada;

  List<Map<String, String>> _estados =
      []; // [{sigla:'SC', nome:'Santa Catarina'}]
  List<String> _cidades = [];

  bool _loadingEstados = false;
  bool _loadingCidades = false;

  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarEstados();
  }

  // 📍 IBGE: estados
  Future<void> _carregarEstados() async {
    setState(() => _loadingEstados = true);
    try {
      final url = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List estadosData = json.decode(response.body);
        estadosData.sort((a, b) => a['nome'].compareTo(b['nome']));
        setState(() {
          _estados = estadosData
              .map<Map<String, String>>(
                (e) => {
                  'sigla': (e['sigla'] as String),
                  'nome': (e['nome'] as String),
                },
              )
              .toList();
        });
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao carregar estados: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _loadingEstados = false);
    }
  }

  // 🏙️ IBGE: cidades
  Future<void> _carregarCidades(String uf) async {
    setState(() {
      _loadingCidades = true;
      _cidades = [];
      _cidadeSelecionada = null;
    });
    try {
      final url = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List cidadesData = json.decode(response.body);
        cidadesData.sort((a, b) => a['nome'].compareTo(b['nome']));
        setState(() {
          _cidades = cidadesData
              .map<String>((e) => e['nome'] as String)
              .toList();
        });
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao carregar cidades: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _loadingCidades = false);
    }
  }

  bool _validarData(String valor) {
    final regex = RegExp(
      r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}$',
    );
    if (!regex.hasMatch(valor)) return false;
    try {
      final p = valor.split('/');
      final dia = int.parse(p[0]), mes = int.parse(p[1]), ano = int.parse(p[2]);
      final data = DateTime(ano, mes, dia);
      return data.day == dia && data.month == mes && data.year == ano;
    } catch (_) {
      return false;
    }
  }

  void _proximoPasso() {
    if (_tipoSituacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha o tipo de anúncio: doar ou encontrado.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }
    // if (_estadoSelecionado == null || _cidadeSelecionada == null) {
    //    ScaffoldMessenger.of(context).showSnackBar(
    //      const SnackBar(
    //       content: Text('Selecione o estado e a cidade.'),
    //       backgroundColor: Color(0xFFDC004E),
    //      ),
    //    );
    //    return;
    //  }
    if (dataController.text.isNotEmpty &&
        !_validarData(dataController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma data válida no formato DD/MM/AAAA.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/divulgar3');
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: _proximoPasso,
      title: 'Criar Anúncio',
      subtitle: 'Informe os detalhes para divulgar seu pet',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de anúncio',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC004E),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _tipoSituacao,
              decoration: _decoracaoCampo(),
              hint: const Text('Selecione o tipo de anúncio'),
              items: const [
                DropdownMenuItem(
                  value: 'Doacao',
                  child: Text('Quero doar um pet meu'),
                ),
                DropdownMenuItem(
                  value: 'Achado',
                  child: Text('Encontrei um pet perdido'),
                ),
              ],
              onChanged: (v) => setState(() => _tipoSituacao = v),
            ),

            const SizedBox(height: 25),

            const Text(
              'Localização do pet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC004E),
              ),
            ),
            const SizedBox(height: 10),

            // 🔽 Estado
            _loadingEstados
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _estadoSelecionado,
                    decoration: _decoracaoCampo(),
                    hint: const Text('Selecione o estado'),
                    items: _estados
                        .map(
                          (e) => DropdownMenuItem(
                            value: e['sigla'],
                            child: Text('${e['sigla']} - ${e['nome']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _estadoSelecionado = v;
                      });
                      if (v != null) _carregarCidades(v);
                    },
                  ),

            const SizedBox(height: 15),

            // 🔽 Cidade
            if (_loadingCidades)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_estadoSelecionado != null)
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _cidadeSelecionada,
                decoration: _decoracaoCampo(),
                hint: const Text('Selecione a cidade'),
                items: _cidades
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _cidadeSelecionada = v),
              ),

            const SizedBox(height: 20),

            CustomInput(
              label: 'Descrição do pet e da situação',
              hint:
                  'Conte detalhes sobre o pet e o motivo do anúncio (ex: estou de mudança, encontrei assustado na rua...)',
              controller: descricaoController,
              maxLines: 3,
            ),
            const SizedBox(height: 15),

            CustomInput(
              label: 'Data do encontro (pet perdido - opcional)',
              hint: 'Ex: 10/05/2025',
              controller: dataController,
              maxLines: 1,
              keyboardType: TextInputType.datetime,
            ),
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
}
