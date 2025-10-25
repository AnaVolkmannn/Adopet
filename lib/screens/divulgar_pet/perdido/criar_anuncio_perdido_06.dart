import 'package:flutter/material.dart';
import '../../../widgets/anuncio_base_screen.dart';
import '../../../widgets/custom_input.dart';

class CriarAnuncioPerdido06 extends StatefulWidget {
  const CriarAnuncioPerdido06({super.key});

  @override
  State<CriarAnuncioPerdido06> createState() => _CriarAnuncioPerdido06State();
}

class _CriarAnuncioPerdido06State extends State<CriarAnuncioPerdido06> {
  String? _localSelecionado;
  bool _declaracaoAceita = false;
  bool _animalPerdido = false;

  final List<String> locais = [
    'Lar Temporário',
    'Abrigo',
    'ONG',
    'Petshop',
    'Canil',
    'Outro',
  ];

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: () {
        if (!_declaracaoAceita) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Você precisa aceitar a Declaração de Veracidade.'),
              backgroundColor: Color(0xFFDC004E),
            ),
          );
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/success',
          (route) => false,
        );
      },
      title: 'Criar Anúncio',
      subtitle: 'Ao criar um anúncio, você terá acesso ao Painel de Busca',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🩷 Onde o pet está agora
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

          // ✅ Checkbox: Animal perdido ou abandonado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: _animalPerdido,
                  activeColor: const Color(0xFFDC004E),
                  onChanged: (v) {
                    setState(() => _animalPerdido = v ?? false);
                  },
                ),
                const Expanded(
                  child: Text(
                    'Animal perdido ou abandonado',
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
          ),

          // 🏠 Campos que aparecem quando o checkbox está marcado
          if (_animalPerdido) ...[
            const SizedBox(height: 10),
            CustomInput(
              label: 'Endereço onde foi encontrado',
              hint: 'Digite o local aproximado',
            ),
            const SizedBox(height: 15),
            CustomInput(
              label: 'Descrição do local',
              hint: 'Ex: Próximo à praça, perto de um mercado...',
            ),
            const SizedBox(height: 20),
          ],

          // 📅 Data que encontrou
          CustomInput(
            label: 'Data que encontrei (opcional)',
            hint: 'Ex: 8 de outubro de 2025',
          ),
          const SizedBox(height: 15),

          // ☎️ Telefone com WhatsApp
          CustomInput(
            label: 'Telefone com WhatsApp',
            hint: 'Insira seu telefone com DDD',
          ),
          const SizedBox(height: 20),

          // ✅ Declaração de veracidade
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
                  onChanged: (v) {
                    setState(() => _declaracaoAceita = v ?? false);
                  },
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
    );
  }
}
