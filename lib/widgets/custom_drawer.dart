import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFF7E6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do usuário
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFDC004E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFFDC004E), size: 30),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Olá, Ana!',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

            const Divider(
              thickness: 1,
              color: Color(0xFFDC004E),
              indent: 16,
              endIndent: 16,
            ),

            _buildMenuItem(
              context,
              icon: Icons.logout,
              label: 'Sair',
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '🐾 Adopet v1.0',
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
    );
  }

  // 🔹 Função auxiliar para gerar cada item do menu
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
        Navigator.pop(context); // Fecha o menu antes de navegar
        onTap();
      },
    );
  }
}