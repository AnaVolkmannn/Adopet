import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme.dart';

class MeusAnunciosScreen extends StatelessWidget {
  const MeusAnunciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 1) Se não tiver usuário logado, já avisa
    if (user == null) {
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
        body: const Center(
          child: Text(
            'Faça login para ver seus anúncios.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pets')
            .where('tutorId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro ao carregar seus anúncios:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Você ainda não criou nenhum anúncio.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            );
          }

          final anuncios = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: anuncios.length,
            itemBuilder: (context, index) {
              final doc = anuncios[index];
              final data = doc.data() as Map<String, dynamic>;

              // -------- TRATAR IMAGEM COM SEGURANÇA --------
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

              return Container(
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFFFB6C1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // FOTO OU PLACEHOLDER
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 240,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.pets,
                                    size: 80,
                                    color: Colors.white70,
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 240,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.pets,
                                size: 80,
                                color: Colors.white70,
                              ),
                            ),
                    ),

                    const SizedBox(height: 12),

                    // NOME
                    Text(
                      (data['name'] ?? 'Pet sem nome') as String,
                      style: const TextStyle(
                        color: Color(0xFFDC004E),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    // STATUS
                    Text(
                      (data['status'] ?? 'ativo').toString().toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFDC004E),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // BOTÕES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () async {
                            // 🔹 Diálogo de confirmação
                            final bool? confirmar = await showDialog<bool>(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text(
                                    'Confirmar exclusão',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  content: const Text(
                                    'Deseja realmente excluir este anúncio?\n'
                                    'Essa ação não pode ser desfeita.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop(false);
                                      },
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop(true);
                                      },
                                      child: const Text(
                                        'Excluir',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Color(0xFFDC004E),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            // Se o usuário cancelou ou fechou o diálogo
                            if (confirmar != true) return;

                            // 🔥 Exclui de fato
                            await FirebaseFirestore.instance
                                .collection('pets')
                                .doc(doc.id)
                                .delete();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Anúncio excluído.'),
                                  backgroundColor: Color(0xFFDC004E),
                                ),
                              );
                            }
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
                            final petData = {
                              'mode': 'edit',
                              'petId': doc.id,
                              'name': data['name'],
                              'noName': data['noName'],
                              'species': data['species'],
                              'gender': data['gender'],
                              'size': data['size'],
                              'ageYears': data['ageYears'],
                              'ageMonths': data['ageMonths'],
                              'adType': data['adType'],
                              'state': data['state'],
                              'city': data['city'],
                              'description': data['description'],
                              'foundDate': data['foundDate'],
                              'contactPhone': data['contactPhone'],
                              'contactEmail': data['contactEmail'],

                              // 🔥 CORREÇÃO IMPORTANTE!
                              'photoUrls': (data['photoUrls'] is List)
                                  ? List<String>.from(data['photoUrls'])
                                  : <String>[],
                            };

                            Navigator.pushNamed(
                              context,
                              '/divulgar1',
                              arguments: petData,
                            );
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
          );
        },
      ),
    );
  }
}