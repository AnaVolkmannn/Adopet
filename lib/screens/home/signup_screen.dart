import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme.dart';
import '../../../core/spacing.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 🔎 Validação básica de senha
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "As senhas não coincidem.";
        _isLoading = false;
      });
      return;
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await userCredential.user?.updateDisplayName(
        _nameController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Já existe uma conta com este e-mail.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do e-mail é inválido.';
      } else {
        message = 'Erro ao criar conta. Verifique os dados.';
      }

      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';
      });
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🐾 Logo
                Image.asset(
                  'assets/images/logov3.png',
                  width: 250,
                  height: 250,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Cadastrar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC004E),
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Criar uma nova conta',
                  style: TextStyle(
                    color: Color(0xFFFF5C00),
                    fontFamily: 'Inter',
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 40),

                // 👤 Nome
                _StyledInput(
                  label: 'Nome de usuário',
                  hint: 'Digite o nome de usuário',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 20),

                // 📧 E-mail
                _StyledInput(
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // 🔒 Senha
                _StyledInput(
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  isPassword: true,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // 🔒 Confirmar senha
                _StyledInput(
                  label: 'Confirme a senha',
                  hint: 'Repita sua senha',
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  isPassword: true,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  textInputAction: TextInputAction.done,
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 40),

                // 🔘 Botão CRIAR CONTA
                Container(
                  width: 225,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC004E), Color(0xFFFF5C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC004E).withOpacity(0.4),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CRIAR CONTA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 🔹 Input reutilizável (com olhinho opcional)
// ------------------------------------------------------------
class _StyledInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;             // nunca nulo
  final bool isPassword;          // nunca nulo
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onToggleVisibility;

  const _StyledInput({
    required this.label,
    required this.hint,
    this.obscure = false,                       // default garante bool
    this.isPassword = false,                    // default garante bool
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
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC004E).withOpacity(0.2),
                offset: const Offset(0, 6),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,                // 👈 aqui NUNCA é null
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
          ),
        ),
      ],
    );
  }
}