import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/custom_drawer.dart';

class AdotarDetalhes extends StatelessWidget {
  const AdotarDetalhes({super.key});

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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // ⚠️ ID do pet vindo da lista
    final petId = args['id'] ?? args['petId'];

    if (petId == null) {
      return const Scaffold(
        body: Center(
          child: Text('ID do pet não informado.'),
        ),
      );
    }

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFDC004E)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalhes do Pet',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC004E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Informações sobre o pet para adoção',
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pets')
              .doc(petId)
              .snapshots(),
          builder: (context, snapshot) {
            // ⏳ Carregando...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFDC004E)),
              );
            }

            // ❌ Erro
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar pet: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            // ❌ Não existe
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'Pet não encontrado.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            // 🐶 Nome
            final bool noName = data['noName'] == true;
            final String nome = noName
                ? 'Pet sem nome'
                : (data['name'] ?? 'Pet sem nome').toString();

            // 👶 Idade
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
            final idade = _formatarIdade(ageYears, ageMonths);

            // 🌍 Localização
            final cidade = (data['city'] ?? 'Cidade não informada').toString();
            final estado = (data['state'] ?? '').toString();
            final localizacao =
                estado.isNotEmpty ? '$cidade • $estado' : cidade;

            // 🐾 Outros campos
            final especie = (data['species'] ?? 'Não informada').toString();
            final genero = (data['gender'] ?? 'Não informado').toString();
            final porte = (data['size'] ?? 'Não informado').toString();
            final tipo = (data['adType'] ?? 'Não informado').toString();
            final descricao =
                (data['description'] ?? 'Sem descrição disponível.').toString();
            final telefoneTutor =
                (data['contactPhone'] ?? 'Não informado').toString();
            final emailTutor =
                (data['contactEmail'] ?? 'Não informado').toString();

            // 📸 Imagem
            String? imagem;
            final photos = data['photoUrls'];
            if (photos != null &&
                photos is List &&
                photos.isNotEmpty &&
                photos.first != null &&
                photos.first is String &&
                (photos.first as String).trim().isNotEmpty) {
              imagem = photos.first as String;
            } else {
              imagem =
                  'https://cdn-icons-png.flaticon.com/512/194/194279.png'; // placeholder
            }

            // 🔁 Monta o map completo para passar pra tela de interesse
            final petArgs = <String, dynamic>{
              'id': petId,
              'nome': nome,
              'idade': idade,
              'cidade': cidade,
              'estado': estado,
              'imagem': imagem,
              'descricao': descricao,
              'adType': tipo,
              'especie': especie,
              'genero': genero,
              'porte': porte,
              'telefoneTutor': telefoneTutor,
              'emailTutor': emailTutor,
              'tutorId': data['tutorId'],
            };

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFD9D9D9),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 📸 FOTO PRINCIPAL
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imagem,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.pets,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🐶 NOME
                    Text(
                      nome,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC004E),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // 👶 Idade + cidade
                    Text(
                      '$idade • $localizacao',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Informações Gerais
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Informações Gerais',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFDC004E),
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFFDC004E)),
                    const SizedBox(height: 8),

                    _infoRow('Espécie', especie),
                    _infoRow('Sexo', genero),
                    _infoRow('Porte', porte),
                    _infoRow('Tipo de anúncio', tipo),
                    _infoRow('Localização', localizacao),

                    const SizedBox(height: 20),

                    // 📞 Contato do tutor
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contato do Tutor',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFDC004E),
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFFDC004E)),
                    const SizedBox(height: 8),

                    _infoRow('Telefone', telefoneTutor),
                    _infoRow('E-mail', emailTutor),

                    const SizedBox(height: 20),

                    // 📝 Descrição
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Descrição',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFDC004E),
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFFDC004E)),
                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        descricao,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ❤️ BOTÃO "QUERO ADOTAR"
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC004E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/adotar_interesse',
                          arguments: petArgs,
                        );
                      },
                      child: const Text(
                        'Quero Adotar',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC004E),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
