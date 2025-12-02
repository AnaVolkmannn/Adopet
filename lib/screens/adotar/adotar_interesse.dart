import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/custom_drawer.dart';

class AdotarInteresse extends StatefulWidget {
  const AdotarInteresse({super.key});

  @override
  State<AdotarInteresse> createState() => _AdotarInteresseState();
}

class _AdotarInteresseState extends State<AdotarInteresse> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _mensagemController = TextEditingController();

  bool _isSending = false;
  bool _isLoadingUser = false;

  @override
  void initState() {
    super.initState();
    _telefoneController.addListener(_formatarTelefone);
    _carregarDadosUsuario();
  }

  @override
  void dispose() {
    _telefoneController.removeListener(_formatarTelefone);
    _nomeController.dispose();
    _telefoneController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  // 🔹 INPUT PADRÃO ADOPET — ROSINHA
  InputDecoration _inputAdopet(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFFE6EC),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontFamily: 'Poppins',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Color(0xFFDC004E),
  );

  // 🔥 Carrega nome e telefone do Firestore/Auth
  Future<void> _carregarDadosUsuario() async {
    try {
      setState(() => _isLoadingUser = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? nomeDb;
      String? phoneDb;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        nomeDb = data?['name']?.toString();
        phoneDb = data?['phone']?.toString();
      }

      // Nome: prioridade → Firestore > displayName
      if (_nomeController.text.trim().isEmpty) {
        if (nomeDb != null && nomeDb.trim().isNotEmpty) {
          _nomeController.text = nomeDb;
        } else if (user.displayName != null &&
            user.displayName!.trim().isNotEmpty) {
          _nomeController.text = user.displayName!;
        }
      }

      // Telefone: pega do Firestore se tiver
      if (_telefoneController.text.trim().isEmpty &&
          phoneDb != null &&
          phoneDb.trim().isNotEmpty) {
        _telefoneController.text = phoneDb;
      }
    } catch (e) {
      // Se der erro, só não preenche — não quebra a tela
      debugPrint('Erro ao carregar dados do usuário: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  // 📱 MÁSCARA DE TELEFONE -> (99) 99999-9999
  void _formatarTelefone() {
    String text = _telefoneController.text;

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

    if (formatted != _telefoneController.text) {
      _telefoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _enviarSolicitacao(BuildContext context) async {
    if (_isSending) return;

    final pet =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final nome = _nomeController.text.trim();
    final telefone = _telefoneController.text.trim();
    final mensagem = _mensagemController.text.trim();

    if (nome.isEmpty || telefone.isEmpty || mensagem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome, telefone e mensagem.'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('adoption_interests').add({
        'petId': pet['id'],
        'petName': pet['nome'],
        'tutorId': pet['tutorId'],
        'interestedUserId': user?.uid,
        'interestedName': nome,
        'interestedPhone': telefone,
        'message': mensagem,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação enviada ao tutor!'),
          backgroundColor: Color(0xFFDC004E),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar solicitação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(115),
        child: AppBar(
          backgroundColor: const Color(0xFFFFF7E6),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFDC004E),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),

                  // Título
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adotar ${pet['nome'] ?? 'um pet'}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC004E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Preencha as informações para demonstrar seu interesse',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFFFF5C00),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFFDC004E)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (_) => const CustomDrawer(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (_isLoadingUser)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: Color(0xFFDC004E),
                    backgroundColor: Color(0xFFFFE6EC),
                  ),
                ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),

                    const Text(
                      'Seus dados para contato',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFFDC004E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Essas informações serão enviadas ao tutor do pet.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFDC004E)),

                    const SizedBox(height: 16),

                    // ⭐ LABEL + INPUT NOME
                    const Text('Nome completo', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nomeController,
                      decoration: _inputAdopet('Seu nome completo'),
                    ),
                    const SizedBox(height: 16),

                    // ⭐ LABEL + INPUT TELEFONE
                    const Text('Telefone com WhatsApp', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputAdopet('(DDD) 99999-9999'),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Mensagem para o anunciante',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFDC004E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'O tutor receberá sua mensagem junto com seus dados de contato.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFDC004E)),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _mensagemController,
                      maxLines: 4,
                      decoration: _inputAdopet(
                        'Tem alguma dúvida? Pergunte ao tutor aqui...',
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ❤️ BOTÃO ENVIAR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC004E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        onPressed: (_isSending || _isLoadingUser)
                            ? null
                            : () => _enviarSolicitacao(context),
                        child: _isSending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Enviar solicitação',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}