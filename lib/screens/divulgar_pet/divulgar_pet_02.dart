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
  String? _estadoSelecionado; // UF (ex: "SC")
  String? _cidadeSelecionada;

  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  // Dados vindos da tela 1 (e possivelmente do anúncio já existente)
  Map<String, dynamic>? _petData;

  // Modo edição/criação
  bool _isEdit = false;
  bool _initialized = false;

  // Estados e cidades vindos da API do IBGE
  List<Map<String, String>> _estados = []; // [{sigla: 'SC', nome: 'Santa Catarina'}]
  List<String> _cidades = [];

  bool _loadingEstados = false;
  bool _loadingCidades = false;

  // Valores iniciais (para modo edição)
  String? _ufInicial;
  String? _cidadeInicial;

  @override
  void initState() {
    super.initState();
    _carregarEstados();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    // Pega os argumentos enviados pela Tela 1
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _petData = Map<String, dynamic>.from(args);
      _isEdit = (_petData?['mode'] == 'edit');

      // Preenche campos em modo edição
      if (_isEdit) {
        _tipoSituacao = _petData?['adType'] as String?;

        final desc = _petData?['description'];
        if (desc is String && desc.trim().isNotEmpty) {
          descricaoController.text = desc;
        }

        final foundDate = _petData?['foundDate'];
        if (foundDate is String && foundDate.trim().isNotEmpty) {
          dataController.text = foundDate;
        }

        _ufInicial = _petData?['state'] as String?;
        _cidadeInicial = _petData?['city'] as String?;
      }
    }

    _initialized = true;
    // Se os estados já tiverem carregado, tenta aplicar UF/cidade aqui
    _aplicarEstadoCidadeSePossivel();
  }

  @override
  void dispose() {
    descricaoController.dispose();
    dataController.dispose();
    super.dispose();
  }

  // ---------------- API IBGE: ESTADOS ----------------
  Future<void> _carregarEstados() async {
    setState(() {
      _loadingEstados = true;
    });

    try {
      final uri = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _estados = data
            .map((e) => {
                  'sigla': (e['sigla'] ?? '').toString(),
                  'nome': (e['nome'] ?? '').toString(),
                })
            .where((e) => e['sigla']!.isNotEmpty && e['nome']!.isNotEmpty)
            .cast<Map<String, String>>()
            .toList();

        // Depois de carregar os estados, tenta aplicar UF/cidade inicial (modo edição)
        _aplicarEstadoCidadeSePossivel();
      } else {
        // Se quiser, você pode mostrar um SnackBar aqui também
      }
    } catch (_) {
      // Ignora erro silenciosamente ou exibe algo se quiser
    } finally {
      if (mounted) {
        setState(() {
          _loadingEstados = false;
        });
      }
    }
  }

  // ---------------- API IBGE: CIDADES ----------------
  Future<void> _carregarCidades(String uf, {String? cidadeInicial}) async {
    setState(() {
      _loadingCidades = true;
      _cidades = [];
      _cidadeSelecionada = null;
    });

    try {
      final uri = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios?orderBy=nome',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cidades = data
            .map((e) => (e['nome'] ?? '').toString())
            .where((nome) => nome.isNotEmpty)
            .cast<String>()
            .toList();

        if (cidadeInicial != null && _cidades.contains(cidadeInicial)) {
          _cidadeSelecionada = cidadeInicial;
        }
      }
    } catch (_) {
      // opcional: tratar erro
    } finally {
      if (mounted) {
        setState(() {
          _loadingCidades = false;
        });
      }
    }
  }

  // Tenta aplicar UF e cidade inicial (quando modo edição)
  void _aplicarEstadoCidadeSePossivel() {
    if (!_isEdit) return;
    if (_ufInicial == null) return;
    if (_estados.isEmpty) return;

    final uf = _ufInicial!;
    final existeUf = _estados.any((e) => e['sigla'] == uf);
    if (!existeUf) return;

    // Define o estado selecionado e carrega cidades a partir da UF
    _estadoSelecionado = uf;

    // Chama carregamento de cidades com cidade inicial (se houver)
    _carregarCidades(uf, cidadeInicial: _cidadeInicial);
  }

  // ---------------- VALIDAÇÃO + PRÓXIMO PASSO ----------------
  void _proximoPasso() {
    if (_petData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocorreu um erro ao carregar os dados do pet. Volte e tente novamente.',
          ),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    if (_tipoSituacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha o tipo de anúncio: doar ou encontrado.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    if (_estadoSelecionado == null || _cidadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o estado e a cidade.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    // Monta o mapa com os dados da tela 2
    final Map<String, dynamic> updatedPetData = {
      ..._petData!, // todos os dados das telas anteriores (e do anúncio, se edição)

      // mantém o modo
      'mode': _isEdit ? 'edit' : (_petData?['mode'] ?? 'create'),

      // sobrescreve campos da tela 2
      'adType': _tipoSituacao, // "Doacao" ou "Achado"
      'state': _estadoSelecionado, // UF
      'city': _cidadeSelecionada,  // nome da cidade
      'description': descricaoController.text.trim(),
      'foundDate': dataController.text.trim().isEmpty
          ? null
          : dataController.text.trim(), // por enquanto String
    };

    // Envia para a tela 3
    Navigator.pushNamed(
      context,
      '/divulgar3',
      arguments: updatedPetData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: _proximoPasso,
      title: _isEdit ? 'Editar Anúncio' : 'Criar Anúncio',
      subtitle: _isEdit
          ? 'Atualize os detalhes do anúncio do seu pet'
          : 'Informe os detalhes para divulgar seu pet',
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
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFDC004E),
                      ),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _estadoSelecionado,
                    decoration: _decoracaoCampo(),
                    hint: const Text('Selecione o estado'),
                    items: _estados
                        .map(
                          (estado) => DropdownMenuItem(
                            value: estado['sigla'],
                            child: Text(
                              '${estado['sigla']} - ${estado['nome']}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _estadoSelecionado = v;
                        _cidadeSelecionada = null;
                        _cidades = [];
                      });
                      _carregarCidades(v);
                    },
                  ),
            const SizedBox(height: 15),

            // 🔽 Cidade
            if (_estadoSelecionado != null)
              _loadingCidades
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFFDC004E),
                        ),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _cidadeSelecionada,
                      decoration: _decoracaoCampo(),
                      hint: const Text('Selecione a cidade'),
                      items: _cidades
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _cidadeSelecionada = v),
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
