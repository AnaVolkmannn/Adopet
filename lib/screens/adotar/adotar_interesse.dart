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

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  // 🔹 INPUT PADRÃO ADOPET — MESMO DA TELA DE LOGIN
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
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFDC004E)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adotar ${pet['nome'] ?? 'um Pet'}',
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
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFD9D9D9),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                const Text(
                  'SEUS DADOS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFFDC004E),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFDC004E)),

                const SizedBox(height: 16),

                // ⭐ INPUT NOME — PADRÃO ADOPET
                TextField(
                  controller: _nomeController,
                  decoration: _inputAdopet('Seu nome completo'),
                ),
                const SizedBox(height: 16),

                // ⭐ INPUT TELEFONE — PADRÃO ADOPET
                TextField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputAdopet('Telefone para contato'),
                ),

                const SizedBox(height: 50),

                const Text(
                  'Mensagem para o anunciante',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFDC004E),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFDC004E)),
                const SizedBox(height: 16),

                // ⭐ INPUT MENSAGEM — PADRÃO ADOPET
                TextField(
                  controller: _mensagemController,
                  maxLines: 4,
                  decoration: _inputAdopet('Por que você quer adotar esse pet?'),
                ),

                const SizedBox(height: 32),

                // ❤️ BOTÃO ENVIAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC004E),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isSending ? null : () => _enviarSolicitacao(context),
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
                          'Enviar Solicitação',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}