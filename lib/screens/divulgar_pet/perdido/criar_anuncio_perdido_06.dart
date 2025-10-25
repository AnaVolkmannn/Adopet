import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_input.dart';

class CriarAnuncioPerdido06 extends StatefulWidget {
  const CriarAnuncioPerdido06({super.key});

  @override
  State<CriarAnuncioPerdido06> createState() => _CriarAnuncioPerdido06State();
}

class _CriarAnuncioPerdido06State extends State<CriarAnuncioPerdido06> {
  String? _localSelecionado = 'Lar Temporário';
  bool _declaracaoAceita = false;
  bool _animalPerdido = false;

  // Localização
  String? _estadoSelecionado;
  String? _cidadeSelecionada;
  List<String> _estados = [];
  List<String> _cidades = [];

  final TextEditingController nomeLocalController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  final List<String> locais = [
    'Lar Temporário',
    'Abrigo',
    'ONG',
  ];

  @override
  void initState() {
    super.initState();
    _carregarEstados();
  }

  // 📍 Carrega estados via IBGE
  Future<void> _carregarEstados() async {
    final url = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List estadosData = json.decode(response.body);
      estadosData.sort((a, b) => a['sigla'].compareTo(b['sigla']));
      setState(() {
        _estados =
            estadosData.map<String>((e) => e['sigla'] as String).toList();
      });
    }
  }

  // 🏙️ Carrega cidades de acordo com o estado selecionado
  Future<void> _carregarCidades(String uf) async {
    setState(() {
      _cidades = [];
      _cidadeSelecionada = null;
    });

    final url = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List cidadesData = json.decode(response.body);
      cidadesData.sort((a, b) => a['nome'].compareTo(b['nome']));
      setState(() {
        _cidades =
            cidadesData.map<String>((e) => e['nome'] as String).toList();
      });
    }
  }

  void _proximoPasso() {
    if (!_declaracaoAceita) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar a Declaração de Veracidade.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/success', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: _proximoPasso,
      title: 'Criar Anúncio',
      subtitle: 'Ao criar um anúncio, você terá acesso ao Painel de Busca',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Onde o pet está agora',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC004E),
              ),
            ),
            const SizedBox(height: 10),

            // 🔘 Seleção de local
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: locais.map((opcao) {
                final selecionado = _localSelecionado == opcao;
                return ChoiceChip(
                  label: Text(
                    opcao,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: selecionado ? Colors.white : const Color(0xFFDC004E),
                      fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  selected: selecionado,
                  selectedColor: const Color(0xFFDC004E),
                  backgroundColor: Colors.transparent,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: const Color(0xFFDC004E).withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => _localSelecionado = opcao);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            // 🏠 Nome da ONG / Abrigo / Lar
            CustomInput(
              label: _localSelecionado == 'ONG'
                  ? 'Nome da ONG onde o pet está'
                  : _localSelecionado == 'Abrigo'
                      ? 'Nome do abrigo'
                      : 'Nome do lar temporário',
              hint: 'Digite o nome do local',
              controller: nomeLocalController,
              maxLines: 1,
            ),

            const SizedBox(height: 20),

            // Estado
            const Text(
              'Estado',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC004E),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _estadoSelecionado,
              decoration: _decoracaoCampo(),
              hint: const Text('Selecione o estado'),
              items: _estados
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _estadoSelecionado = v;
                });
                if (v != null) _carregarCidades(v);
              },
            ),

            const SizedBox(height: 15),

            // Cidade
            if (_estadoSelecionado != null)
              DropdownButtonFormField<String>(
                value: _cidadeSelecionada,
                decoration: _decoracaoCampo(),
                hint: const Text('Selecione a cidade'),
                items: _cidades
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _cidadeSelecionada = v),
              ),

            const SizedBox(height: 15),

            // Bairro
            CustomInput(
              label: 'Bairro',
              hint: 'Digite o bairro onde o pet está',
              controller: bairroController,
              maxLines: 1,
            ),

            const SizedBox(height: 15),

            // Telefone
            CustomInput(
              label: 'Telefone com WhatsApp',
              hint: 'Insira seu telefone com DDD',
              controller: telefoneController,
              maxLines: 1,
            ),

            const SizedBox(height: 15),

            // Checkbox: Animal achado
            Row(
              children: [
                Checkbox(
                  value: _animalPerdido,
                  activeColor: const Color(0xFFDC004E),
                  onChanged: (v) => setState(() => _animalPerdido = v ?? false),
                ),
                const Expanded(
                  child: Text(
                    'Animal achado perdido ou abandonado',
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

            if (_animalPerdido) ...[
              CustomInput(
                label: 'Descrição do local e do pet',
                hint: 'Ex: encontrei perto da praça, estava assustado...',
                controller: descricaoController,
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              CustomInput(
                label: 'Data que encontrei (opcional)',
                hint: 'Ex: 08/10/2025',
                controller: dataController,
                maxLines: 1,
              ),
            ],

            const SizedBox(height: 25),

            // Declaração
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFDC004E).withOpacity(0.4),
                  width: 1.5,
                ),
                color: const Color(0xFFFFE6EC),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _declaracaoAceita,
                    activeColor: const Color(0xFFDC004E),
                    onChanged: (v) =>
                        setState(() => _declaracaoAceita = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Declaração de Veracidade\n'
                      'Certifico que todas as informações fornecidas são precisas e atualizadas, '
                      'assumindo total responsabilidade pela divulgação deste pet.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF5A5A5A),
                      ),
                    ),
                  ),
                ],
              ),
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