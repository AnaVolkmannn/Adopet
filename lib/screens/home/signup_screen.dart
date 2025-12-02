// ignore_for_file: unused_element_parameter, duplicate_ignore

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;

import '../../../core/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Máscaras
  final telefoneMask = MaskTextInputFormatter(
    mask: "(##) #####-####",
    filter: {"#": RegExp(r'[0-9]')},
  );

  final cepMask = MaskTextInputFormatter(
    mask: "#####-###",
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Checkbox para consentimento
  bool _privacyAccepted = false;

  // Controle de busca de CEP pra evitar múltiplas chamadas
  bool _isFetchingCep = false;

  @override
  void initState() {
    super.initState();
  }

  // ============================================================== 
  // ===================== 🔥 CRIAR CONTA =========================
  // ==============================================================

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "As senhas não coincidem.";
        _isLoading = false;
      });
      return;
    }

    // Validação do checkbox
    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Você deve concordar em compartilhar suas informações."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Erro inesperado.");

      await user.updateDisplayName(_nameController.text.trim());

      // Criando os dados no Firestore
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': user.email,
        'phone': _telefoneController.text.trim(),
        'cep': _cepController.text.trim(),
        'state': _stateController.text.trim(),
        'city': _cityController.text.trim(),
        'bairro': _bairroController.text.trim(),
        'street': _streetController.text.trim(),
        'number': _numberController.text.trim(),

        // Consentimento
        'privacyConsent': true,

        'favorites': <String>[],
        'myPets': <String>[],
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.code == "email-already-in-use"
            ? "E-mail já em uso."
            : e.code == "weak-password"
                ? "Senha muito fraca."
                : "Erro ao criar conta.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================== 
  // ==================== 🔍 CEP -> VIACEP ========================
  // ==============================================================

  Future<void> _buscarEnderecoPorCep(String cepDigitado) async {
    final cep = cepDigitado.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) return; // só busca CEP completo

    setState(() {
      _isFetchingCep = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['erro'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CEP não encontrado. Verifique e tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _stateController.text = (data['uf'] ?? '').toString();
          _cityController.text = (data['localidade'] ?? '').toString();
          _bairroController.text = (data['bairro'] ?? '').toString();
          _streetController.text = (data['logradouro'] ?? '').toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao buscar o endereço. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar CEP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingCep = false;
        });
      }
    }
  }

  void _onCepChanged(String value) {
    final cep = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8 && !_isFetchingCep) {
      _buscarEnderecoPorCep(value);
    }
  }

  // ============================================================== 
  // ========================== WIDGET =============================
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Criar conta',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC004E),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),
                _sectionTitle("Dados pessoais"),

                _buildTextField(
                  label: 'Nome Completo',
                  hintText: 'Digite o seu nome completo',
                  controller: _nameController,
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  label: 'E-mail',
                  hintText: 'Digite seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  label: 'Telefone',
                  hintText: '(xx) xxxxx-xxxx',
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatter: telefoneMask,
                ),
                const SizedBox(height: 18),

                const SizedBox(height: 35),
                _sectionTitle("Endereço"),
                const Text(
                      '(preenchimento automático)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFFDC004E),
                        ),
                      ),

                const SizedBox(height: 18),

                _buildTextField(
                  label: 'CEP',
                  hintText: '00000-000',
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  inputFormatter: cepMask,
                  onChanged: _onCepChanged,
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  label: 'Estado',
                  hintText: 'UF',
                  controller: _stateController,
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  label: 'Cidade',
                  hintText: 'Cidade',
                  controller: _cityController,
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  label: 'Bairro',
                  hintText: 'Bairro',
                  controller: _bairroController,
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  label: 'Rua',
                  hintText: 'Rua',
                  controller: _streetController,
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  label: 'Número',
                  hintText: 'Número',
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 35),
                _sectionTitle("Segurança"),

                _buildTextField(
                  label: 'Senha',
                  hintText: 'Crie sua senha',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  isPassword: true,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  label: 'Confirmar senha',
                  hintText: 'Repita sua senha',
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  isPassword: true,
                  onToggleVisibility: () {
                    setState(
                      () =>
                          _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                ),

                const SizedBox(height: 25),
                Row(
                  children: [
                    Checkbox(
                      value: _privacyAccepted,
                      activeColor: const Color(0xFFDC004E),
                      onChanged: (v) {
                        setState(() => _privacyAccepted = v ?? false);
                      },
                    ),
                    Expanded(
                      child: Text(
                        "Concordo em compartilhar minhas informações pessoais",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 40),

                Center(
                  child: Container(
                    width: 240,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDC004E), Color(0xFFFF5C00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC004E).withOpacity(0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'CRIAR CONTA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Já tem uma conta? ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: const Text(
                          'Logar',
                          style: TextStyle(
                            color: Color(0xFFFF5C00),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF5C00),
        ),
      ),
    );
  }

  // ─────────────────────────────
  // 🔹 Campo reutilizável no estilo EditarConta
  // ─────────────────────────────
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscure = false,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    TextInputFormatter? inputFormatter,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      obscureText: obscure,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      inputFormatters: inputFormatter != null ? [inputFormatter] : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        counterText: maxLength != null ? '' : null,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFDC004E),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black38,
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
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFFF5C00),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      style: const TextStyle(fontFamily: 'Poppins'),
    );
  }
}