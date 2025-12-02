import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/custom_drawer.dart';

class AdotarDetalhes extends StatefulWidget {
  const AdotarDetalhes({super.key});

  @override
  State<AdotarDetalhes> createState() => _AdotarDetalhesState();
}

class _AdotarDetalhesState extends State<AdotarDetalhes> {
  // ----------------------------------------------------------
  // CONTROLADOR DO CARROSSEL
  // ----------------------------------------------------------
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // FUNÇÕES DE FORMATAÇÃO
  // ----------------------------------------------------------

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

  // 🔒 Mascara telefone: (48) 9****-1234
  String mascararTelefone(String telefone) {
    final digits = telefone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length < 10) return "*****";

    final ddd = digits.substring(0, 2);
    final first = digits.substring(2, 3);
    final last4 = digits.substring(digits.length - 4);

    return "($ddd) $first****-$last4";
  }

  String _primeiroNome(String? nome) {
    if (nome == null) return 'Nome não informado';
    final trimmed = nome.trim();
    if (trimmed.isEmpty) return 'Nome não informado';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  void _abrirImagemFull(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _irParaPagina(int index, int total) {
    if (total == 0) return;

    final clamped = index.clamp(0, total - 1);

    setState(() => _currentPage = clamped);

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        clamped,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final petId = args['id'] ?? args['petId'];

    if (petId == null) {
      return const Scaffold(
        body: Center(child: Text('ID do pet não informado.')),
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
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFFDC004E)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Column(
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

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pets')
            .doc(petId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFDC004E)),
            );
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Pet não encontrado."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // ----------------------------------------------------------
          // DADOS DO PET
          // ----------------------------------------------------------
          final noName = data['noName'] == true;
          final nome = noName ? "Pet sem nome" : (data['name'] ?? '');

          final idade =
              _formatarIdade(data['ageYears'], data['ageMonths']);

          final cidade = data['city'] ?? 'Cidade não informada';
          final estado = data['state'] ?? '';
          final localizacao =
              estado.isNotEmpty ? "$cidade • $estado" : cidade;

          final descricao =
              data['description'] ?? 'Sem descrição disponível.';

          final telefoneTutor =
              data['contactPhone'] ?? 'Informado na solicitação';

          final tutorId = data['tutorId'] ?? '';
          final fallbackTutorName = data['tutorName'] ?? "Tutor";

          // ----------------------------------------------------------
          // IMAGENS
          // ----------------------------------------------------------
          List<String> fotos = [];
          if (data['photoUrls'] is List) {
            fotos = (data['photoUrls'] as List)
                .whereType<String>()
                .toList();
          }

          const placeholder =
              "https://cdn-icons-png.flaticon.com/512/194/194279.png";

          // ----------------------------------------------------------
          // WIDGET
          // ----------------------------------------------------------
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 6,
                    color: Color(0x20000000),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ------------------------------------------------------
                  // CARROSSEL
                  // ------------------------------------------------------
                  SizedBox(
                    height: 260,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: fotos.isNotEmpty ? fotos.length : 1,
                          onPageChanged: (i) {
                            setState(() => _currentPage = i);
                          },
                          itemBuilder: (_, i) {
                            final url =
                                fotos.isNotEmpty ? fotos[i] : placeholder;
                            return GestureDetector(
                              onTap: () => _abrirImagemFull(context, url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            );
                          },
                        ),

                        if (fotos.length > 1)
                          Positioned(
                            left: 8,
                            top: 0,
                            bottom: 0,
                            child: _arrowButton(
                                Icons.chevron_left,
                                () => _irParaPagina(
                                    _currentPage - 1, fotos.length)),
                          ),

                        if (fotos.length > 1)
                          Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: _arrowButton(
                                Icons.chevron_right,
                                () => _irParaPagina(
                                    _currentPage + 1, fotos.length)),
                          ),

                        if (fotos.length > 1)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: _indicator(
                                _currentPage + 1, fotos.length),
                          ),
                      ],
                    ),
                  ),

                  if (fotos.length > 1) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: fotos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final url = fotos[i];
                          final ativo = i == _currentPage;
                          return GestureDetector(
                            onTap: () => _irParaPagina(i, fotos.length),
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ativo
                                      ? const Color(0xFFDC004E)
                                      : Colors.grey.shade300,
                                  width: ativo ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ------------------------------------------------------
                  // NOME + IDADE
                  // ------------------------------------------------------
                  Text(
                    nome,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC004E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$idade • $localizacao",
                    style:
                        const TextStyle(fontFamily: 'Poppins', fontSize: 15),
                  ),

                  const SizedBox(height: 24),
                  _sectionTitle("Informações Gerais"),

                  _infoRow("Espécie", data['species'] ?? '—'),
                  _infoRow("Sexo", data['gender'] ?? '—'),
                  _infoRow("Porte", data['size'] ?? '—'),
                  _infoRow("Tipo de anúncio", data['adType'] ?? '—'),

                  const SizedBox(height: 24),

                  _sectionTitle("Anunciante"),

                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(tutorId)
                        .get(),
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return _infoRow("Nome", _primeiroNome(fallbackTutorName));
                      }
                      final user = snap.data!.data() as Map<String, dynamic>?; 
                      final nomeTutor =
                          user?['name'] ?? fallbackTutorName;
                      return _infoRow("Nome", _primeiroNome(nomeTutor));
                    },
                  ),

                  _infoRow("Telefone", mascararTelefone(telefoneTutor)),

                  const SizedBox(height: 24),

                  _sectionTitle("Descrição"),
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
                        arguments: {
                          'id': petId,
                          'nome': nome,
                          'cidade': cidade,
                          'estado': estado,
                          'descricao': descricao,
                          'imagem': fotos.isNotEmpty ? fotos.first : placeholder,
                          'tutorId': tutorId,
                          'tutorName': fallbackTutorName,
                        },
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

                  // Respiro final de 50px
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // COMPONENTES DE UI
  // ----------------------------------------------------------

  Widget _arrowButton(IconData icon, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _indicator(int current, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$current/$total",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDC004E),
          ),
        ),
        const SizedBox(height: 4),
        const Divider(color: Color(0xFFDC004E)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
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
