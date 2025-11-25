import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/custom_drawer.dart';

class AdotarHome extends StatefulWidget {
  const AdotarHome({super.key});

  @override
  State<AdotarHome> createState() => _AdotarHomeState();
}

class _AdotarHomeState extends State<AdotarHome> {
  final TextEditingController _cidadeController = TextEditingController();
  List<String> _sugestoes = [];
  String? _cidadeSelecionada;

  // 🔍 Busca cidades no IBGE
  Future<void> _buscarCidades(String query) async {
    if (query.isEmpty) {
      setState(() => _sugestoes = []);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/municipios'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final results = data
            .map((c) => c['nome'].toString())
            .where((nome) => nome.toLowerCase().startsWith(query.toLowerCase()))
            .take(8)
            .toList();

        setState(() => _sugestoes = results);
      }
    } catch (e) {
      debugPrint('Erro ao buscar cidades: $e');
    }
  }

  String _formatarIdade(int? anos, int? meses) {
    if ((anos == null || anos == 0) && (meses == null || meses == 0)) {
      return 'Idade não informada';
    }

    final partes = <String>[];

    if (anos != null && anos > 0) {
      partes.add('$anos ${anos == 1 ? "ano" : "anos"}');
    }

    if (meses != null && meses > 0) {
      partes.add('$meses ${meses == 1 ? "mês" : "meses"}');
    }

    return partes.join(' e ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(115),
        child: AppBar(
          backgroundColor: const Color(0xFFFFF7E6),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔙 Botão de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFDC004E)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),

                  // 🩷 Título e subtítulo
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adotar um Pet',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC004E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Encontre pets disponíveis para adoção na sua cidade',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFFFF5C00),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ☰ Botão de menu — abre o Drawer customizado
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFFDC004E)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (_) => const CustomDrawer(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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

              // 🔹 Sugestões de cidade
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

              // 🐶 Lista vindo do Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pets')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFFDC004E)),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar pets.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum pet disponível no momento.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    // Filtra por status e cidade (se selecionada)
                    final docs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final status =
                          (data['status'] ?? '').toString().toLowerCase();
                      if (status != 'ativo') return false;

                      if (_cidadeSelecionada == null ||
                          _cidadeSelecionada!.isEmpty) {
                        return true;
                      }

                      final city =
                          (data['city'] ?? '').toString().toLowerCase();
                      return city
                          .contains(_cidadeSelecionada!.toLowerCase());
                    }).toList();

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum pet encontrado para essa cidade.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        // Nome
                        final nome = (data['name'] ?? 'Pet sem nome') as String;

                        // Idade
                        int? ageYears;
                        int? ageMonths;
                        final ay = data['ageYears'];
                        final am = data['ageMonths'];
                        if (ay is int) {
                          ageYears = ay;
                        } else if (ay is num) {
                          ageYears = ay.toInt();
                        }
                        if (am is int) {
                          ageMonths = am;
                        } else if (am is num) {
                          ageMonths = am.toInt();
                        }
                        final idadeTexto = _formatarIdade(ageYears, ageMonths);

                        // Cidade
                        final cidade = (data['city'] ?? 'Cidade não informada')
                            .toString();

                        // Data do anúncio
                        String dataTexto = 'Data não informada';
                        final createdAt = data['createdAt'];
                        if (createdAt != null) {
                          DateTime? dt;
                          if (createdAt is Timestamp) {
                            dt = createdAt.toDate();
                          } else if (createdAt is DateTime) {
                            dt = createdAt;
                          }
                          if (dt != null) {
                            dataTexto =
                                DateFormat('dd/MM/yyyy • HH:mm').format(dt);
                          }
                        }

                        // Imagem (photoUrls[0] ou placeholder)
                        String? imageUrl;
                        final photos = data['photoUrls'];
                        if (photos != null &&
                            photos is List &&
                            photos.isNotEmpty &&
                            photos.first != null &&
                            photos.first is String &&
                            (photos.first as String).trim().isNotEmpty) {
                          imageUrl = photos.first as String;
                        } else {
                          imageUrl = null;
                        }

                        // Mapa de argumentos para a tela de detalhes
                        final petArgs = <String, dynamic>{
                          'id': doc.id,
                          'nome': nome,
                          'idade': idadeTexto,
                          'cidade': cidade,
                          'imagem': imageUrl,
                          'descricao': data['description'] ?? '',
                          'adType': data['adType'] ?? '',
                        };

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/adotar_detalhes',
                              arguments: petArgs,
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
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.pets,
                                              size: 50,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.pets,
                                            size: 50,
                                            color: Colors.white70,
                                          ),
                                        ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nome,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFDC004E),
                                          ),
                                        ),
                                        Text(
                                          idadeTexto,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          cidade,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            dataTexto,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}