import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final user = FirebaseAuth.instance.currentUser;

    // 🔹 PEGA O NOME DO USUÁRIO
    String nomeUsuario = 'Usuário';

    if (user != null) {
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        nomeUsuario = user.displayName!;
      } else if (user.email != null) {
        nomeUsuario = user.email!.split('@').first;
      } else {
        nomeUsuario = user.uid.substring(0, 6);
      }
    }

    // 🔹 PEGA APENAS O PRIMEIRO NOME
    final primeiroNome = nomeUsuario.split(' ').first;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenWidth * 0.75,
          height: screenHeight,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7E6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 CABEÇALHO
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC004E),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFFDC004E),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 15),

                              Text(
                                'Olá,\n$primeiroNome!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildMenuItem(
                          context,
                          icon: Icons.campaign,
                          label: 'Meus anúncios',
                          onTap: () => Navigator.pushNamed(context, '/meus_anuncios'),
                        ),

                        _buildMenuItem(
                          context,
                          icon: Icons.pets,
                          label: 'Adotar um Pet',
                          onTap: () => Navigator.pushNamed(context, '/adotar_home'),
                        ),

                        _buildMenuItem(
                          context,
                          icon: Icons.add_circle_outline,
                          label: 'Criar anúncio',
                          onTap: () => Navigator.pushNamed(context, '/divulgar1'),
                        ),

                        _buildMenuItem(
                          context,
                          icon: Icons.person_outline,
                          label: 'Minha Conta',
                          onTap: () => Navigator.pushNamed(context, '/minha_conta'),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(
                  thickness: 2,
                  color: Color(0xFFDC004E),
                  indent: 16,
                  endIndent: 16,
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  label: 'Sair',
                  onTap: () async {
                    await _logout(context);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '🐾 Adopet v2.2',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color(0xFFDC004E),
                      fontWeight: FontWeight.w500,
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

  // Função para fazer o logout do Firebase e redirecionar para a tela de login
  Future<void> _logout(BuildContext context) async {
    try {
      print('Iniciando logout...'); // Debug: Verificar se o logout é iniciado
      await FirebaseAuth.instance.signOut(); // Realiza o logout do Firebase
      print('Logout realizado!'); // Debug: Confirmar que o logout foi bem-sucedido

      // Redireciona o usuário para a tela de login
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      print('Redirecionado para a tela de login'); // Debug: Confirmar que foi redirecionado
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sair: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Erro no logout: $e'); // Debug: Mostrar erro no console
    }
  }

  static Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFDC004E)),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFDC004E),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Fecha o drawer
        onTap();
      },
    );
  }
}