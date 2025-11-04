import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_drawer.dart'; // 👈 importa o menu lateral

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height:
                    110, // 🔹 logo bem maior sem aumentar a altura do AppBar
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFDC004E), size: 32),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      // ✅ Menu lateral reutilizável
      endDrawer: const CustomDrawer(),

      // 🔹 Corpo principal
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 🩷 Título
            const Text(
              'Divulgue pets para adoção',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC004E),
                height: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            // 🧡 Subtexto
            const Text(
              'Ajude um pet a encontrar um lar! 💕\n'
              'Use nossa ferramenta de divulgação, já testada em todo o Brasil,\n'
              'e acompanhe cada passo no Painel de Adoção.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Color(0xFFFF5C00),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 35),

            // 🐾 Botão "Divulgar um pet"
            _buildMainButton(
              context,
              title: 'Divulgar um pet',
              subtitle: 'Encontre um lar para o pet',
              icon: Icons.pets,
              gradient: const [Color(0xFFDC004E), Color(0xFFFF5C00)],
              textColor: Colors.white,
              onTap: () => Navigator.pushNamed(context, '/divulgar'),
            ),

            const SizedBox(height: 20),

            // 🧡 Botão "Adotar um pet"
            _buildMainButton(
              context,
              title: 'Adotar um pet',
              subtitle: 'Veja pets disponíveis para adoção',
              icon: Icons.favorite,
              gradient: const [Color(0xFFFFE6EC), Color(0xFFFFE6EC)],
              textColor: const Color(0xFFDC004E),
              onTap: () => Navigator.pushNamed(context, '/adotar_home'),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 🔸 Função auxiliar para os botões principais
  Widget _buildMainButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(0.25),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: textColor == Colors.white
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFFDC004E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: textColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: textColor == Colors.white
                              ? Colors.white
                              : const Color(0xFFFF5C00),
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ],
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
