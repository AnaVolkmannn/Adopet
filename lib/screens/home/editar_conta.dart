import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditarContaScreen extends StatefulWidget {
  const EditarContaScreen({super.key});

  @override
  State<EditarContaScreen> createState() => _EditarContaScreenState();
}

class _EditarContaScreenState extends State<EditarContaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _telefoneController.addListener(_formatarTelefone);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.removeListener(_formatarTelefone);
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------
  // 📱 MÁSCARA DE TELEFONE -> (99) 99999-9999
  // ------------------------------------------------------
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
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, text.length)}';
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

  Future<void> _carregarDados() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }

      final nomeBase = user.displayName ?? 'Usuário';

      // Tenta buscar dados extras no Firestore
      final docUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String? nomeDb;
      String? telefoneDb;
      String? emailDb;

      if (docUser.exists) {
        final data = docUser.data() as Map<String, dynamic>;
        nomeDb = data['name']?.toString();
        telefoneDb = data['phone']?.toString();
        emailDb = data['email']?.toString();
      }

      _nomeController.text =
          (nomeDb != null && nomeDb.trim().isNotEmpty) ? nomeDb : nomeBase;

      if (telefoneDb != null && telefoneDb.trim().isNotEmpty) {
        _telefoneController.text = telefoneDb;
      }

      if (emailDb != null && emailDb.trim().isNotEmpty) {
        _emailController.text = emailDb;
      } else if (user.email != null) {
        _emailController.text = user.email!;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: const Color(0xFFDC004E),
        ),
      );
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }

      final nome = _nomeController.text.trim();
      final telefone = _telefoneController.text.trim();
      final email = _emailController.text.trim();

      await user.updateDisplayName(nome);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'name': nome,
          'phone': telefone.isEmpty ? null : telefone,
          'email': email.isEmpty ? null : email,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados atualizados com sucesso!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados: $e'),
          backgroundColor: const Color(0xFFDC004E),
        ),
      );
    }
  }

  // 🔐 REDEFINIR SENHA
  Future<void> _redefinirSenha() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }

      // usa o email do campo, se tiver, senão pega do Auth
      final email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : (user.email ?? '');

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível identificar um e-mail para redefinir a senha.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enviamos um e-mail para $email com o link de redefinição de senha.'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar e-mail de redefinição: $e'),
          backgroundColor: const Color(0xFFDC004E),
        ),
      );
    }
  }

  Future<void> _confirmarExcluirConta() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Excluir conta',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Tem certeza que deseja excluir sua conta?\n'
            'Todos os seus anúncios podem deixar de estar disponíveis.\n'
            'Essa ação não pode ser desfeita.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Excluir',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFFDC004E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _excluirConta();
    }
  }

  Future<void> _excluirConta() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado.'),
            backgroundColor: Color(0xFFDC004E),
          ),
        );
        return;
      }

      final uid = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      await user.delete();

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      setState(() => _isSaving = false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao excluir conta. Talvez seja necessário fazer login novamente.\n$e',
          ),
          backgroundColor: const Color(0xFFDC004E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE80052),
        title: const Text(
          'Editar Conta',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFE6EC),
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        _buildTextField(
                          label: 'Nome',
                          controller: _nomeController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe um nome.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildTextField(
                          label: 'Telefone (WhatsApp)',
                          controller: _telefoneController,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 12),

                        _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC004E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isSaving ? null : _salvarAlteracoes,
                            child: const Text(
                              'Salvar alterações',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // BOTÃO REDEFINIR SENHA
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: _isSaving ? null : _redefinirSenha,
                            child: const Text(
                              'Redefinir senha',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF5C00),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        TextButton.icon(
                          onPressed: _isSaving ? null : _confirmarExcluirConta,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFDC004E),
                          ),
                          label: const Text(
                            'Excluir minha conta',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC004E),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                if (_isSaving)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFE6EC),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        counterText: maxLength != null ? '' : null,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFDC004E),
        ),
        filled: true,
        fillColor: const Color(0xFFFFE6EC),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: const TextStyle(fontFamily: 'Poppins'),
    );
  }
}