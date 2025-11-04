import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/spacing.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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

                // 🩷 Título
                Text(
                  'Cadastrar',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC004E),
                  ),
                ),

                const SizedBox(height: 4),

                // 🧡 Subtítulo
                const Text(
                  'Criar uma nova conta',
                  style: TextStyle(
                    color: Color(0xFFFF5C00),
                    fontFamily: 'Inter',
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 40),

                // 👤 Campo nome
                const _StyledInput(
                  label: 'Nome de usuário',
                  hint: 'Digite o nome de usuário',
                ),

                const SizedBox(height: 20),

                // 📧 Campo e-mail
                const _StyledInput(
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                ),

                const SizedBox(height: 20),

                // 🔒 Campo senha
                const _StyledInput(
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  obscure: true,
                ),

                const SizedBox(height: 40),

                // 🔘 Botão CRIAR CONTA com gradiente refinado
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
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
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

                // 🔗 Link “Já tem uma conta? Logar”
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

// 🔹 Input com sombra e estética igual à tela de login
class _StyledInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;

  const _StyledInput({
    required this.label,
    required this.hint,
    this.obscure = false,
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
              ),
            ],
          ),
          child: TextField(
            obscureText: obscure,
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
            ),
          ),
        ),
      ],
    );
  }
}