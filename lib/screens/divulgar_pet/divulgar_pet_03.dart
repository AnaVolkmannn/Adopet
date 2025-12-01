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

  Map<String, dynamic>? _petData;

  bool _isEdit = false;
  bool _initialized = false;

  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 🔹 adiciona a máscara ao telefone
    telefoneController.addListener(_formatarTelefone);
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
        final phone = _petData?['contactPhone'];
        final email = _petData?['contactEmail'];

        // já formata automaticamente
        if (phone is String && phone.trim().isNotEmpty) {
          telefoneController.text = phone;
        }
        if (email is String && email.trim().isNotEmpty) {
          emailController.text = email;
        }
      }
    }

    _initialized = true;
  }

  @override
  void dispose() {
    telefoneController.removeListener(_formatarTelefone);
    telefoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // 📱 FUNÇÃO DE FORMATAÇÃO DO TELEFONE -> (99) 99999-9999
  // ------------------------------------------------------------------
  void _formatarTelefone() {
    String text = telefoneController.text;

    // remove tudo que não for número
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    String formatted = '';

    if (text.length >= 1) formatted = '(${text.substring(0, 2)}';
    if (text.length >= 2) formatted = '(${text.substring(0, 2)}) ';
    if (text.length >= 3) formatted += text.substring(2, text.length);

    if (text.length > 7) {
      formatted =
          '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}';
    }

    // Evita loop infinito
    if (formatted != telefoneController.text) {
      final cursorPos = formatted.length;
      telefoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: cursorPos),
      );
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

    final Map<String, dynamic> finalPetData = {
      ..._petData!,
      'mode': _isEdit ? 'edit' : (_petData?['mode'] ?? 'create'),
      'contactPhone': telefoneController.text.trim(),
      'contactEmail':
          emailController.text.trim().isEmpty ? null : emailController.text.trim(),
    };

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
      title: _isEdit ? 'Editar Anúncio' : 'Criar Anúncio',
      subtitle:
          _isEdit ? 'Atualize suas informações de contato' : 'Insira suas informações de contato',
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

            const Divider(
              thickness: 2,
              color: Color.fromRGBO(220, 0, 78, 1),
              indent: 16,
              endIndent: 16,
            ),

            const SizedBox(height: 25),

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