import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Import Firebase Auth
import '../../../core/theme.dart';
import '../../../core/spacing.dart';

// Change LoginScreen to a StatefulWidget to manage state
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Create TextEditingControllers for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // To show loading state
  String? _errorMessage; // To display error messages

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle the login attempt
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      // 2. Call Firebase Authentication to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), // trim() to remove leading/trailing spaces
        password: _passwordController.text,
      );
      // If successful, navigate to home. Firebase AuthStateChanges will handle this.
      // We'll rely on the StreamBuilder in main.dart or a wrapper for navigation.
      // For now, let's just push and replace to home.
      if (mounted) { // Check if the widget is still in the tree
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      // 3. Handle Firebase-specific errors
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
      // 4. Handle other potential errors
      setState(() {
        _errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';
      });
      print(e); // Log the full error for debugging
    } finally {
      setState(() {
        _isLoading = false; // Stop loading regardless of success or failure
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

                const SizedBox(height: 20),

                // 🩷 Título
                const Text( // Made const if not using dynamic text
                  'Seja Bem Vindo!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC004E),
                  ),
                ),

                const SizedBox(height: 4),

                // 🧡 Subtítulo
                const Text( // Made const
                  'Faça login com sua conta',
                  style: TextStyle(
                    color: Color(0xFFFF5C00),
                    fontFamily: 'Inter',
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 40),

                // 📧 Campo e-mail
                _StyledInput( // Pass controller to _StyledInput
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress, // Added for better UX
                ),

                const SizedBox(height: 20),

                // 🔒 Campo senha
                _StyledInput( // Pass controller to _StyledInput
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  obscure: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done, // Better for last input
                ),

                // Display error message if any
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

                // 🔘 Botão LOGIN com gradiente refinado
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
                    onPressed: _isLoading ? null : _handleLogin, // Disable button while loading
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading // Show loading indicator or text
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

                // 🔗 Link “Criar conta”
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

// 🔹 Input personalizado com sombra mais fiel ao Figma
class _StyledInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller; // <--- Add controller parameter
  final TextInputType keyboardType; // <--- Add keyboardType
  final TextInputAction textInputAction; // <--- Add textInputAction

  const _StyledInput({
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller, // Initialize controller
    this.keyboardType = TextInputType.text, // Default
    this.textInputAction = TextInputAction.next, // Default
    super.key, // Add key
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
            controller: controller, // <--- Assign the controller
            obscureText: obscure,
            keyboardType: keyboardType, // Use keyboardType
            textInputAction: textInputAction, // Use textInputAction
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