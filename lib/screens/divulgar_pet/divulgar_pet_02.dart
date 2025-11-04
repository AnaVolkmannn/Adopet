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
  bool _declaracaoAceita = false;
  bool _temIdentificacao = false;

  String? _tipoSituacao; // “Doacao” ou “Achado”
  String? _estadoSelecionado;
  String? _cidadeSelecionada;
  List<String> _estados = [];
  List<String> _cidades = [];

  // Controladores
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController pontoReferenciaController =
      TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tipoSituacao = null; // ✅ Garante que o dropdown comece limpo
    _carregarEstados();
  }

  // 📍 IBGE: estados
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

  // 🏙️ IBGE: cidades
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

  // ✅ Validação de data dd/mm/aaaa (opcional)
  bool _validarData(String valor) {
    final regex =
        RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}$');
    if (!regex.hasMatch(valor)) return false;

    try {
      final partes = valor.split('/');
      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);
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

    if (!_declaracaoAceita) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Você precisa aceitar a Declaração de Veracidade.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

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

    // Aqui você poderia montar o objeto para enviar à API, ex:
    // final anuncio = {
    //   'tipoSituacao': _tipoSituacao,
    //   'estado': _estadoSelecionado,
    //   'cidade': _cidadeSelecionada,
    //   'bairro': bairroController.text,
    //   'referencia': pontoReferenciaController.text,
    //   'telefone': telefoneController.text,
    //   'email': emailController.text,
    //   'descricao': descricaoController.text,
    //   'temIdentificacao': _temIdentificacao,
    //   'data': dataController.text,
    // };

    Navigator.pushNamedAndRemoveUntil(context, '/success', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () {
        setState(() {
          _tipoSituacao = null; // ✅ Limpa valor ao voltar
        });
        Navigator.pop(context);
      },
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

            // 🔽 Dropdown de tipo de anúncio
            DropdownButtonFormField<String>(
              value: _tipoSituacao,
              decoration: _decoracaoCampo(),
              hint: const Text('Selecione o tipo de anúncio'),
              items: const [
                DropdownMenuItem(
                    value: 'Doacao', child: Text('🩷 Quero doar um pet')),
                DropdownMenuItem(
                    value: 'Achado',
                    child: Text('🕵️ Encontrei um pet perdido')),
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

            DropdownButtonFormField<String>(
              value: _estadoSelecionado,
              decoration: _decoracaoCampo(),
              hint: const Text('Selecione o estado'),
              items: _estados
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _estadoSelecionado = v;
                });
                if (v != null) _carregarCidades(v);
              },
            ),
            const SizedBox(height: 15),

            if (_estadoSelecionado != null)
              DropdownButtonFormField<String>(
                value: _cidadeSelecionada,
                decoration: _decoracaoCampo(),
                hint: const Text('Selecione a cidade'),
                items: _cidades
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _cidadeSelecionada = v),
              ),
            const SizedBox(height: 15),

            CustomInput(
              label: 'Bairro',
              hint: 'Digite o bairro onde o pet está',
              controller: bairroController,
              maxLines: 1,
            ),
            const SizedBox(height: 15),

            CustomInput(
              label: 'Ponto de referência (opcional)',
              hint: 'Ex: próximo à escola, praça ou mercado',
              controller: pontoReferenciaController,
              maxLines: 1,
            ),

            const SizedBox(height: 25),

            const Text(
              'Informações de contato',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC004E),
              ),
            ),
            const SizedBox(height: 10),

            CustomInput(
              label: 'Telefone com WhatsApp',
              hint: '(DDD) 99999-9999',
              controller: telefoneController,
              maxLines: 1,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            CustomInput(
              label: 'E-mail (opcional)',
              hint: 'Digite seu e-mail de contato',
              controller: emailController,
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 25),

            const Text(
              'Detalhes adicionais',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC004E),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: _temIdentificacao,
                  activeColor: const Color(0xFFDC004E),
                  onChanged: (v) =>
                      setState(() => _temIdentificacao = v ?? false),
                ),
                const Expanded(
                  child: Text(
                    'O pet tem coleira, placa ou microchip?',
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

            const SizedBox(height: 10),

            CustomInput(
              label: 'Descrição do pet e da situação',
              hint:
                  'Conte detalhes sobre o pet e o motivo do anúncio',
              controller: descricaoController,
              maxLines: 3,
            ),

            const SizedBox(height: 15),

            CustomInput(
              label: 'Data do ocorrido (opcional)',
              hint: 'Ex: 10/05/2025',
              controller: dataController,
              maxLines: 1,
              keyboardType: TextInputType.datetime,
            ),

            const SizedBox(height: 25),

            // ✅ Declaração final
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
                      'Confirmo que as informações fornecidas são verdadeiras e atualizadas, '
                      'e autorizo a divulgação deste pet na plataforma.',
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
        borderSide:
            const BorderSide(color: Color(0xFFDC004E)),
      ),
    );
  }
}