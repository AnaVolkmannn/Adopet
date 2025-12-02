import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/anuncio_base_screen.dart';

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
    telefoneController.addListener(_formatarTelefone);
    _carregarContatoUsuario(); // 🔥 busca dados do cadastro
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
        final mail = _petData?['contactEmail'];

        if (phone is String && phone.trim().isNotEmpty) {
          telefoneController.text = phone;
        }
        if (mail is String && mail.trim().isNotEmpty) {
          emailController.text = mail;
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
  // 📱 CARREGA CONTATO DO CADASTRO (FIRESTORE + AUTH)
  // ------------------------------------------------------------------
  Future<void> _carregarContatoUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Evita sobrescrever caso já tenha vindo algo do anúncio em edição
      if (telefoneController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty) {
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String? phoneDb;
      String? emailDb;

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        phoneDb = data?['phone']?.toString();
        emailDb = data?['email']?.toString();
      }

      if (telefoneController.text.trim().isEmpty &&
          phoneDb != null &&
          phoneDb.trim().isNotEmpty) {
        telefoneController.text = phoneDb;
      }

      if (emailController.text.trim().isEmpty) {
        if (emailDb != null && emailDb.trim().isNotEmpty) {
          emailController.text = emailDb;
        } else if (user.email != null && user.email!.trim().isNotEmpty) {
          emailController.text = user.email!;
        }
      }
    } catch (_) {
      // Se der erro, só não preenche — não quebra a tela
    }
  }

  // ------------------------------------------------------------------
  // 📱 MÁSCARA DE TELEFONE -> (99) 99999-9999
  // ------------------------------------------------------------------
  void _formatarTelefone() {
    String text = telefoneController.text;

    // mantém só números
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    String formatted = '';

    if (text.isEmpty) {
      formatted = '';
    } else if (text.length <= 2) {
      // (99
      formatted = '(${text.substring(0, text.length)}';
    } else if (text.length <= 7) {
      // (99) 99999
      formatted =
          '(${text.substring(0, 2)}) ${text.substring(2, text.length)}';
    } else {
      // (99) 99999-9999
      formatted =
          '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}';
    }

    if (formatted != telefoneController.text) {
      telefoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // 🔥 força rebuild pra atualizar o estado do botão "Prosseguir"
    if (mounted) {
      setState(() {});
    }
  }

  // ------------------------------------------------------------------
  // REGRA PARA HABILITAR O BOTÃO "PROSSEGUIR"
  // ------------------------------------------------------------------
  bool get _podeAvancar {
    final telOk = telefoneController.text.trim().isNotEmpty;
    return _declaracaoAceita && telOk;
  }

  // ------------------------------------------------------------------
  // FINALIZAÇÃO
  // ------------------------------------------------------------------
  void _proximoPasso() {
    if (!_declaracaoAceita) {
      _erro("Você precisa aceitar a Declaração de Veracidade.");
      return;
    }

    if (telefoneController.text.trim().isEmpty) {
      _erro("Informe um telefone para contato.");
      return;
    }

    if (_petData == null) {
      _erro("Erro ao carregar os dados do anúncio.");
      return;
    }

    final Map<String, dynamic> finalPetData = {
      ..._petData!, // mantém os dados das telas 1 e 2

      'mode': _isEdit ? 'edit' : 'create',
      'contactPhone': telefoneController.text.trim(),
      'contactEmail': emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),

      // 🔥 ESSENCIAL: repassar IMAGENS adiante
      'existingPhotos': _petData!['existingPhotos'],
      'newPhotos': _petData!['newPhotos'],
    };

    Navigator.pushNamed(context, '/success', arguments: finalPetData);
  }

  void _erro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFDC004E),
      ),
    );
  }

  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AnuncioBaseScreen(
      onBack: () => Navigator.pop(context),
      onNext: _proximoPasso,
      nextEnabled: _podeAvancar, // 🔥 integra com o botão padrão da base
      title: _isEdit ? 'Editar Anúncio' : 'Criar Anúncio',
      subtitle: _isEdit
          ? 'Atualize suas informações de contato'
          : 'Insira suas informações de contato',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações de contato',
              style: _labelStyle,
            ),
            const SizedBox(height: 16),

            // TELEFONE (rosinha)
            const Text(
              'Telefone com WhatsApp',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Color(0xFFDC004E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              maxLines: 1,
              decoration: _decoracaoAdopet('(DDD) 99999-9999'),
            ),

            const SizedBox(height: 18),

            // EMAIL (rosinha)
            const Text(
              'E-mail (opcional)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Color(0xFFDC004E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
              decoration: _decoracaoAdopet('exemplo@email.com'),
            ),

            const SizedBox(height: 25),

            const Divider(
              thickness: 2,
              color: Color(0xFFDC004E),
              indent: 16,
              endIndent: 16,
            ),

            const SizedBox(height: 25),

            // DECLARAÇÃO DE VERACIDADE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE6EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFDC004E).withOpacity(0.4),
                  width: 1.5,
                ),
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
                      'Confirmo que todas as informações fornecidas são verdadeiras e atualizadas, '
                      'e autorizo a divulgação deste pet na plataforma.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF5A5A5A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // ESTILOS PADRÃO ADOPET
  // ------------------------------------------------------------------
  static const _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFFDC004E),
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