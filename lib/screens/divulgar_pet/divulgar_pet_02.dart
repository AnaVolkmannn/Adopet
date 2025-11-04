import 'package:flutter/material.dart';
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

  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  // 🗺️ Lista local de estados e cidades
  final Map<String, List<String>> _estadosECidades = {
    'SC': ['Florianópolis', 'Joinville', 'Blumenau', 'Criciúma', 'Chapecó'],
    'SP': ['São Paulo', 'Campinas', 'Santos', 'Ribeirão Preto', 'Sorocaba'],
    'RJ': ['Rio de Janeiro', 'Niterói', 'Petrópolis', 'Volta Redonda'],
    'RS': ['Porto Alegre', 'Caxias do Sul', 'Pelotas', 'Santa Maria'],
    'PR': ['Curitiba', 'Londrina', 'Maringá', 'Cascavel'],
    'MG': ['Belo Horizonte', 'Uberlândia', 'Juiz de Fora', 'Montes Claros'],
  };

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
    if (_estadoSelecionado == null || _cidadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o estado e a cidade.'),
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
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _estadoSelecionado,
              decoration: _decoracaoCampo(),
              hint: const Text('Selecione o estado'),
              items: _estadosECidades.keys
                  .map(
                    (sigla) =>
                        DropdownMenuItem(value: sigla, child: Text(sigla)),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _estadoSelecionado = v;
                  _cidadeSelecionada = null;
                });
              },
            ),
            const SizedBox(height: 15),

            // 🔽 Cidade
            if (_estadoSelecionado != null)
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _cidadeSelecionada,
                decoration: _decoracaoCampo(),
                hint: const Text('Selecione a cidade'),
                items: _estadosECidades[_estadoSelecionado]!
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
