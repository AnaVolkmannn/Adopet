import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/anuncio_base_screen.dart';

class DivulgarPet02 extends StatefulWidget {
  const DivulgarPet02({super.key});

  @override
  State<DivulgarPet02> createState() => _DivulgarPet02State();
}

class _DivulgarPet02State extends State<DivulgarPet02> {
  String? _tipoSituacao;
  String? _estadoSelecionado;
  String? _cidadeSelecionada;

  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  Map<String, dynamic>? _petData;
  bool _isEdit = false;
  bool _initialized = false;

  List<Map<String, String>> _estados = [];
  List<String> _cidades = [];

  bool _loadingEstados = false;
  bool _loadingCidades = false;

  String? _ufInicial;
  String? _cidadeInicial;

  @override
  void initState() {
    super.initState();
    _carregarEstados();

    // Máscara de data
    dataController.addListener(_formatarData);
  }

  @override
  void dispose() {
    dataController.removeListener(_formatarData);
    dataController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _petData = Map<String, dynamic>.from(args);

      _isEdit = (_petData?['mode'] == 'edit');

      if (_isEdit) {
        _tipoSituacao = _petData?['adType'];

        final desc = _petData?['description'];
        if (desc is String && desc.trim().isNotEmpty) {
          descricaoController.text = desc;
        }

        final date = _petData?['foundDate'];
        if (date is String && date.trim().isNotEmpty) {
          dataController.text = date;
        }

        _ufInicial = _petData?['state'];
        _cidadeInicial = _petData?['city'];
      }
    }

    _initialized = true;
    _aplicarEstadoCidadeSePossivel();
  }

  // ---------------------------------------------------------------------
  // MÁSCARA PARA DATA
  // ---------------------------------------------------------------------
  void _formatarData() {
    String text = dataController.text;
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 8) text = text.substring(0, 8);

    String formatted = "";

    if (text.length >= 2) {
      formatted = text.substring(0, 2) + "/";
    } else if (text.length >= 1) {
      formatted = text;
    }

    if (text.length >= 4) {
      formatted += text.substring(2, 4) + "/";
    } else if (text.length > 2) {
      formatted += text.substring(2);
    }

    if (text.length > 4) {
      formatted += text.substring(4);
    }

    if (formatted != dataController.text) {
      dataController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ---------------------------------------------------------------------
  // CARREGAR ESTADOS
  // ---------------------------------------------------------------------
  Future<void> _carregarEstados() async {
    setState(() => _loadingEstados = true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _estados = data
            .map((e) => {
                  'sigla': e['sigla'].toString(),
                  'nome': e['nome'].toString(),
                })
            .toList();

        _aplicarEstadoCidadeSePossivel();
      }
    } catch (_) {
      // você pode logar o erro aqui se quiser
    } finally {
      if (mounted) setState(() => _loadingEstados = false);
    }
  }

  // ---------------------------------------------------------------------
  // CARREGAR CIDADES
  // ---------------------------------------------------------------------
  Future<void> _carregarCidades(String uf, {String? cidadeInicial}) async {
    setState(() {
      _loadingCidades = true;
      _cidades = [];
      _cidadeSelecionada = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios?orderBy=nome',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _cidades = data.map((e) => e['nome'].toString()).toList();

        if (cidadeInicial != null && _cidades.contains(cidadeInicial)) {
          _cidadeSelecionada = cidadeInicial;
        }
      }
    } catch (_) {
      // idem
    } finally {
      if (mounted) setState(() => _loadingCidades = false);
    }
  }

  void _aplicarEstadoCidadeSePossivel() {
    if (!_isEdit || _ufInicial == null || _estados.isEmpty) return;

    final uf = _ufInicial!;
    if (_estados.any((e) => e['sigla'] == uf)) {
      _estadoSelecionado = uf;
      _carregarCidades(uf, cidadeInicial: _cidadeInicial);
    }
  }

  // ---------------------------------------------------------------------
  // VALIDA DATA
  // ---------------------------------------------------------------------
  bool _validarData(String data) {
    if (data.isEmpty) return true; // opcional

    final partes = data.split("/");
    if (partes.length != 3) return false;

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);

    if (dia == null || mes == null || ano == null) return false;
    if (dia < 1 || dia > 31) return false;
    if (mes < 1 || mes > 12) return false;
    if (ano < 1900) return false;

    try {
      final dt = DateTime(ano, mes, dia);
      return dt.day == dia && dt.month == mes && dt.year == ano;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // REGRAS PARA HABILITAR BOTÃO "PROSSEGUIR"
  // ---------------------------------------------------------------------
  bool get _podeAvancar {
    if (_tipoSituacao == null ||
        _estadoSelecionado == null ||
        _cidadeSelecionada == null) {
      return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------
  // BOTÃO "PRÓXIMO"
  // ---------------------------------------------------------------------
  void _proximoPasso() {
    if (_tipoSituacao == null) {
      return _erro("Escolha o tipo de anúncio.");
    }

    if (_estadoSelecionado == null || _cidadeSelecionada == null) {
      return _erro("Selecione o estado e a cidade.");
    }

    if (!_validarData(dataController.text.trim())) {
      return _erro("Digite uma data válida no formato dd/mm/aaaa.");
    }

    final updatedData = {
      ..._petData!, // mantém TUDO da tela 1

      'mode': _isEdit ? 'edit' : 'create',
      'adType': _tipoSituacao,
      'state': _estadoSelecionado,
      'city': _cidadeSelecionada,
      'description': descricaoController.text.trim(),
      'foundDate': dataController.text.trim().isEmpty
          ? null
          : dataController.text.trim(),

      // 🔥 IMPORTANTE → manter imagens vindas da tela 1
      'existingPhotos': _petData!['existingPhotos'],
      'newPhotos': _petData!['newPhotos'],
    };

    Navigator.pushNamed(
      context,
      '/divulgar3',
      arguments: updatedData,
    );
  }

  void _erro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFDC004E)),
    );
  }

  // ---------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: _proximoPasso,
      nextEnabled: _podeAvancar,
      title: _isEdit ? 'Editar Anúncio' : 'Criar Anúncio',
      subtitle: _isEdit
          ? 'Atualize os detalhes do anúncio do seu pet'
          : 'Informe os detalhes para divulgar seu pet',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo de anúncio', style: _labelStyle),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _tipoSituacao,
              decoration: _decoracaoAdopet("Selecione o tipo de anúncio"),
              dropdownColor: const Color(0xFFFFE6EC),
              items: const [
                DropdownMenuItem(
                  value: 'Para doar',
                  child: Text('Quero doar um pet meu'),
                ),
                DropdownMenuItem(
                  value: 'Encontrei perdido',
                  child: Text('Encontrei um pet perdido'),
                ),
              ],
              onChanged: (v) => setState(() => _tipoSituacao = v),
            ),

            const SizedBox(height: 25),

            const Text('Localização do pet', style: _labelStyle),
            const SizedBox(height: 10),

            _loadingEstados
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFFDC004E)),
                  )
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _estadoSelecionado,
                    decoration: _decoracaoAdopet("Selecione o estado"),
                    dropdownColor: const Color(0xFFFFE6EC),
                    items: _estados
                        .map((e) => DropdownMenuItem(
                              value: e['sigla'],
                              child: Text("${e['sigla']} - ${e['nome']}"),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _estadoSelecionado = v;
                        _cidadeSelecionada = null;
                      });
                      _carregarCidades(v);
                    },
                  ),

            const SizedBox(height: 15),

            if (_estadoSelecionado != null)
              _loadingCidades
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFDC004E),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _cidadeSelecionada,
                      decoration: _decoracaoAdopet("Selecione a cidade"),
                      dropdownColor: const Color(0xFFFFE6EC),
                      items: _cidades
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _cidadeSelecionada = v),
                    ),

            const SizedBox(height: 20),

            const Text('Descrição do pet e da situação', style: _labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: descricaoController,
              maxLines: 3,
              decoration: _decoracaoAdopet(
                "Conte mais detalhes sobre o pet e o motivo do anúncio...",
              ),
            ),

            const SizedBox(height: 20),

            if (_tipoSituacao == 'Encontrei perdido') ...[
              const Text(
                "Data em que encontrou o pet",
                style: _labelStyle,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dataController,
                keyboardType: TextInputType.number,
                maxLines: 1,
                decoration: _decoracaoAdopet("dd/mm/aaaa"),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // ESTILOS
  // ---------------------------------------------------------------------
  static const _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    color: Color(0xFFDC004E),
    fontWeight: FontWeight.w600,
  );

  static InputDecoration _decoracaoAdopet(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFFE6EC),
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