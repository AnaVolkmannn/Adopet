import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdotarHome extends StatefulWidget {
  const AdotarHome({super.key});

  @override
  State<AdotarHome> createState() => _AdotarHomeState();
}

class _AdotarHomeState extends State<AdotarHome> {
  final TextEditingController _cidadeController = TextEditingController();
  List<String> _sugestoes = [];
  String? _cidadeSelecionada;

  final List<Map<String, String>> pets = const [
    {
      'nome': 'CACIQUE',
      'idade': '2 meses',
      'cidade': 'Jaraguá do Sul',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'BOLT',
      'idade': '1 ano',
      'cidade': 'Joinville',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
    {
      'nome': 'MEL',
      'idade': '3 anos',
      'cidade': 'Guaramirim',
      'imagem': 'https://placedog.net/400/400',
    },
  ];

  Future<void> _buscarCidades(String query) async {
    if (query.isEmpty) {
      setState(() => _sugestoes = []);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://servicodados.ibge.gov.br/api/v1/localidades/municipios'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final results = data
            .map((c) => c['nome'].toString())
            .where((nome) =>
                nome.toLowerCase().startsWith(query.toLowerCase()))
            .take(8)
            .toList();

        setState(() => _sugestoes = results);
      }
    } catch (e) {
      debugPrint('Erro ao buscar cidades: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final petsFiltrados = _cidadeSelecionada == null
        ? pets
        : pets
            .where((pet) => pet['cidade']!
                .toLowerCase()
                .contains(_cidadeSelecionada!.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adotar um Pet'),
        backgroundColor: const Color(0xFFDC004E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Campo de busca de cidade
            TextField(
              controller: _cidadeController,
              decoration: InputDecoration(
                hintText: 'Insira sua cidade',
                prefixIcon:
                    const Icon(Icons.location_on, color: Color(0xFFDC004E)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFDC004E), width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFDC004E), width: 1.2),
                ),
              ),
              onChanged: _buscarCidades,
            ),

            // Sugestões automáticas
            if (_sugestoes.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDC004E), width: 1),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sugestoes.length,
                  itemBuilder: (context, index) {
                    final cidade = _sugestoes[index];
                    return ListTile(
                      title: Text(
                        cidade,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      onTap: () {
                        setState(() {
                          _cidadeController.text = cidade;
                          _cidadeSelecionada = cidade;
                          _sugestoes = [];
                        });
                      },
                    );
                  },
                ),
              )
            else
              const SizedBox(height: 10),

            // Lista de pets
            Expanded(
              child: ListView.builder(
                itemCount: petsFiltrados.length,
                itemBuilder: (context, index) {
                  final pet = petsFiltrados[index];
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
                                    pet['idade']!,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    pet['cidade']!,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFFDC004E)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}