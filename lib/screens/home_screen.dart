import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                height: 45,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFDC004E), size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🐱 Gato local no rodapé
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/gatinho.png',
                  height: screenHeight * 0.42, // proporção ajustada
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // leve gradiente pra integrar o gato ao fundo
                Container(
                  height: screenHeight * 0.42,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF7E6),
                        Color(0xFFFFF7E6),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.25, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo principal
          SingleChildScrollView(
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/divulgar'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC004E), Color(0xFFFF5C00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5C00).withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(
                                Icons.pets,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Divulgar um pet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Encontre um lar para o pet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🧡 Botão "Adotar um pet"
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/adotar_home'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE6EC),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC004E).withOpacity(0.15),
                              offset: const Offset(0, 3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC004E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(
                                Icons.favorite,
                                color: Color(0xFFDC004E),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adotar um pet',
                                  style: TextStyle(
                                    color: Color(0xFFDC004E),
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Veja pets disponíveis para adoção',
                                  style: TextStyle(
                                    color: Color(0xFFFF5C00),
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
