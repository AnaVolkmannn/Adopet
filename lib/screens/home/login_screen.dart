import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme.dart';
import '../../../core/spacing.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Estados
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // 👈 controla ver/desver senha

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado com este e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta. Por favor, tente novamente.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do e-mail é inválido.';
      } else {
        message = 'Erro ao fazer login. Verifique suas credenciais.';
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

  // Esqueceu a senha
  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    String? emailAddress = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        TextEditingController emailController =
            TextEditingController(text: _emailController.text.trim());

        return AlertDialog(
          title: const Text('Redefinir Senha'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Digite seu e-mail',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(emailController.text.trim());
              },
            ),
          ],
        );
      },
    );

    if (emailAddress != null && emailAddress.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailAddress,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('E-mail de redefinição enviado para $emailAddress'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'invalid-email') {
          message = 'O formato do e-mail é inválido.';
        } else if (e.code == 'user-not-found') {
          message = 'E-mail não encontrado. Verifique e tente novamente.';
        } else {
          message = 'Erro ao enviar e-mail de redefinição: ${e.message}';
        }
        setState(() {
          _errorMessage = message;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Ocorreu um erro inesperado ao enviar o e-mail.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
                const SizedBox(height: 30),
                 // 🐾 Logo 2
                Image.asset(
                  'assets/images/logo.png',
                  width: 500,
                ),

               const SizedBox(height: 10),

                const Text(
                  'Seja Bem Vindo!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC004E),
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Faça login com sua conta',
                  style: TextStyle(
                    color: Color(0xFFFF5C00),
                    fontFamily: 'Inter',
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 40),

                // 📧 Campo e-mail
                _StyledInput(
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // não passa obscure -> usa false por padrão
                ),

                const SizedBox(height: 20),

                // 🔒 Campo senha com ver/desver
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
                  textInputAction: TextInputAction.done,
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      _errorMessage!,
                      style:
                          const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 40),

                // 🔘 Botão LOGIN
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
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'LOGIN',
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

                // Esqueceu senha
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () => _showForgotPasswordDialog(context),
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      color: Color(0xFFFF5C00),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Criar conta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black54,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        'Criar',
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
// 🔹 Widget de input com suporte a senha (ver/desver)
// ------------------------------------------------------------

class _StyledInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure; // 👈 nunca será nulo, tem default no construtor
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  final bool isPassword; // 👈 idem, nunca nulo
  final VoidCallback? onToggleVisibility;

  const _StyledInput({
    required this.label,
    required this.hint,
    this.obscure = false,                    // 👈 default garante que não vem null
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,                 // 👈 default também
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
            obscureText: obscure,              // 👈 sempre bool (true/false)
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