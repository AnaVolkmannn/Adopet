import 'package:flutter/material.dart';
import '../../core/theme.dart';

class MeusAnunciosScreen extends StatelessWidget {
  const MeusAnunciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final anuncios = [
      {
        'nome': 'Pituco',
        'status': 'ATIVO',
        'imagem': 'assets/images/cachorro.jpg',
      },
      {
        'nome': 'Mia',
        'status': 'ADOTADO',
        'imagem': 'assets/images/mia.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Meus Anúncios',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: anuncios.length,
          itemBuilder: (context, index) {
            final anuncio = anuncios[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFFFB6C1), // 💖 sombra rosa suave
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Meus Anúncios',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      anuncio['imagem']!,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    anuncio['nome']!,
                    style: const TextStyle(
                      color: Color(0xFFDC004E),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    anuncio['status']!,
                    style: const TextStyle(
                      color: Color(0xFFDC004E),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: lógica de exclusão
                        },
                        child: const Text(
                          'Excluir',
                          style: TextStyle(
                            color: Color(0xFFDC004E),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: lógica de edição
                        },
                        child: const Text(
                          'Editar',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
