import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme.dart';
import '../../../core/spacing.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 🔹 NOVO — checkbox para consentimento
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    _cepController.addListener(_maskCepAndSearch);
  }

  void _maskCepAndSearch() {
    String numeric = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numeric.length > 8) numeric = numeric.substring(0, 8);

    String formatted = numeric.length >= 5
        ? "${numeric.substring(0, 5)}-${numeric.substring(5)}"
        : numeric;

    if (formatted != _cepController.text) {
      _cepController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    if (numeric.length == 8) {
      _fetchViaCep(formatted);
    }
  }

  Future<void> _fetchViaCep(String cep) async {
    final cleanedCep = cep.replaceAll('-', '');

    try {
      final response = await http
          .get(Uri.parse("https://viacep.com.br/ws/$cleanedCep/json/"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["erro"] == true) {
          _showCepError("CEP não encontrado.");
          return;
        }

        setState(() {
          _stateController.text = data["uf"] ?? "";
          _cityController.text = data["localidade"] ?? "";
          _streetController.text = data["logradouro"] ?? "";
        });
      } else {
        _showCepError("Erro ao consultar CEP.");
      }
    } catch (e) {
      _showCepError("Não foi possível conectar ao ViaCEP.");
    }
  }

  void _showCepError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );

    setState(() {
      _stateController.clear();
      _cityController.clear();
      _streetController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _cepController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

    // ⚠️ NOVO — Validação do checkbox
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

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': user.email,

        'cep': _cepController.text.trim(),
        'state': _stateController.text.trim(),
        'city': _cityController.text.trim(),
        'street': _streetController.text.trim(),
        'number': _numberController.text.trim(),

        // 🔥 NOVO — salva o consentimento
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
                      // 🐾 Logo 2
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

                _StyledInput(
                  label: 'Nome',
                  hint: 'Digite o seu primeiro nome',
                  controller: _nameController,
                ),
                const SizedBox(height: 18),

                _StyledInput(
                  label: 'Sobrenome',
                  hint: 'Digite seu sobrenome',
                  controller: _surnameController,
                ),
                const SizedBox(height: 18),

                _StyledInput(
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 35),
                _sectionTitle("Endereço"),

                _StyledInput(
                  label: 'CEP',
                  hint: '00000-000',
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 18),

                _StyledInput(
                  label: 'Estado',
                  hint: 'UF',
                  controller: _stateController,
                ),
                const SizedBox(height: 18),

                _StyledInput(
                  label: 'Cidade',
                  hint: 'Cidade',
                  controller: _cityController,
                ),
                const SizedBox(height: 18),

                _StyledInput(
                  label: 'Rua',
                  hint: 'Rua',
                  controller: _streetController,
                ),
                const SizedBox(height: 18),

                _StyledInput(
                  label: 'Número',
                  hint: 'Número',
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 35),
                _sectionTitle("Segurança"),

                _StyledInput(
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  isPassword: true,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                const SizedBox(height: 18),

                _StyledInput(
                  label: 'Confirmar senha',
                  hint: 'Repita sua senha',
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  isPassword: true,
                  onToggleVisibility: () {
                    setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),

                // 🔥 NOVO — Checkbox
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
                        onTap: () =>
                            Navigator.pushNamed(context, '/login'),
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
}

// ─────────────────────────────
// 🔹 Input reutilizável
// ─────────────────────────────

class _StyledInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onToggleVisibility;

  const _StyledInput({
    required this.label,
    required this.hint,
    this.obscure = false,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onToggleVisibility,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(fontFamily: 'Poppins', color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC004E).withOpacity(0.2),
                offset: const Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            decoration: InputDecoration(
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
                  horizontal: 16, vertical: 14),
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
          ),
        ),
      ],
    );
  }
}
