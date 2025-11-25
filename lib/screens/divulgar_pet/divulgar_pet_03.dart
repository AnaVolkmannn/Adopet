import 'package:flutter/material.dart';
import '../../widgets/anuncio_base_screen.dart';
import '../../widgets/custom_input.dart';

class DivulgarPet03 extends StatefulWidget {
  const DivulgarPet03({super.key});

  @override
  State<DivulgarPet03> createState() => _DivulgarPet03State();
}

class _DivulgarPet03State extends State<DivulgarPet03> {
  bool _declaracaoAceita = false;

  // Dados vindos das telas 1 e 2
  Map<String, dynamic>? _petData;

  // Controladores
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_petData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _petData = Map<String, dynamic>.from(args);
      }
    }
  }

  // FINALIZAÇÃO
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

    if (telefoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um telefone para contato.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    if (_petData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar os dados do anúncio.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    // 🔥 COMPLETA O MAPA COM OS DADOS DA TELA 3
    final Map<String, dynamic> finalPetData = {
      ..._petData!, // dados das telas 1 e 2
      'contactPhone': telefoneController.text.trim(),
      'contactEmail': emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
    };

    // 👉 Aqui em vez de só ir para success,
    // vamos passar para o fluxo que salva no Firestore.
    Navigator.pushNamed(
      context,
      '/success',
      arguments: finalPetData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: _proximoPasso,
      title: 'Criar Anúncio',
      subtitle: 'Insira suas informações de contato',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações de contato',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(255, 92, 0, 1),
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

            const Divider(
              thickness: 2,
              color: Color.fromRGBO(220, 0, 78, 1),
              indent: 16,
              endIndent: 16,
            ),

            const SizedBox(height: 25),

            // DECLARAÇÃO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xFFDC004E).withOpacity(0.4),
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
}