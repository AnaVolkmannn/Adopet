import 'package:flutter/material.dart';

class AdotarHome extends StatelessWidget {
  const AdotarHome({super.key});

  final List<Map<String, String>> pets = const [
    {
      'nome': 'Luna',
      'idade': '2 anos',
      'especie': 'Gato',
      'imagem': 'https://placekitten.com/300/300',
    },
    {
      'nome': 'Bolt',
      'idade': '1 ano',
      'especie': 'Cachorro',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'Mingau',
      'idade': '3 anos',
      'especie': 'Gato',
      'imagem': 'https://placekitten.com/301/301',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adotar um Pet'),
        backgroundColor: const Color(0xFFDC004E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/adotar_detalhes',
                  arguments: pet,
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.network(
                        pet['imagem']!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet['nome']!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC004E),
                              ),
                            ),
                            Text(
                              pet['especie']!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              pet['idade']!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFDC004E)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
