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

  // 🔠 Pega apenas o primeiro nome
  String _primeiroNome(String? nome) {
    if (nome == null) return 'Nome não informado';
    final trimmed = nome.trim();
    if (trimmed.isEmpty) return 'Nome não informado';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  // 🔍 Abre imagem em tela cheia com zoom
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

  // 👉 Sempre que mudar de página via seta / thumb
  // atualiza o controller E o _currentPage.
void _irParaPagina(int index, int total) {
  if (total == 0) return;

  final int clamped = index.clamp(0, total - 1);

  setState(() {
    _currentPage = clamped;
  });

  if (_pageController.hasClients) {
    _pageController.animateToPage(
      clamped,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(clamped);
      }
    });
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
        body: Center(
          child: Text('ID do pet não informado.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),

      // ----------------------------------------------------------
      // APPBAR
      // ----------------------------------------------------------
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

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pets')
            .doc(petId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFDC004E)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Pet não encontrado."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // ----------------------------------------------------------
          // DADOS DO PET
          // ----------------------------------------------------------

          final noName = data['noName'] == true;
          final nome = noName ? "Pet sem nome" : (data['name'] ?? '');

          int? ageYears =
              data['ageYears'] is num ? data['ageYears'].toInt() : null;
          int? ageMonths =
              data['ageMonths'] is num ? data['ageMonths'].toInt() : null;
          final idade = _formatarIdade(ageYears, ageMonths);

          final cidade = data['city'] ?? 'Cidade não informada';
          final estado = data['state'] ?? '';
          final localizacao =
              estado.isNotEmpty ? "$cidade • $estado" : cidade;

          final especie = data['species'] ?? 'Não informada';
          final genero = data['gender'] ?? 'Não informado';
          final porte = data['size'] ?? 'Não informado';
          final tipo = data['adType'] ?? 'Não informado';
          final descricao =
              data['description'] ?? 'Sem descrição disponível.';

          final telefoneTutor = data['contactPhone'] ?? "*****";

          // Tutor
          final String tutorId = (data['tutorId'] ?? '').toString();
          final String fallbackTutorName =
              (data['tutorName'] ?? 'Nome não informado').toString();

          // ----------- Imagens -------------------
          List<String> fotos = [];
          final rawPhotos = data['photoUrls'];

          if (rawPhotos is List) {
            fotos = rawPhotos.whereType<String>().toList();
          }

          // 🔄 Sempre recria o PageController se o número de fotos mudar
          _pageController = PageController(initialPage: _currentPage);

          const placeholderUrl =
              'https://cdn-icons-png.flaticon.com/512/194/194279.png';

          final String imagemPrincipal =
              fotos.isNotEmpty ? fotos.first : placeholderUrl;

          // Garante que o index atual nunca passe o total
          if (fotos.isNotEmpty && _currentPage >= fotos.length) {
            _currentPage = fotos.length - 1;
          }
          if (fotos.isEmpty && _currentPage != 0) {
            _currentPage = 0;
          }

          // Dados para a próxima tela
          final petArgs = {
            'id': petId,
            'nome': nome,
            'cidade': cidade,
            'estado': estado,
            'imagem': imagemPrincipal,
            'descricao': descricao,
            'adType': tipo,
            'especie': especie,
            'genero': genero,
            'porte': porte,
            'idade': idade,
            'tutorId': tutorId,
            'tutorName': fallbackTutorName,
          };

          // Widget que mostra o anunciante puxando do usuário
          Widget anuncianteWidget;
          if (tutorId.isEmpty) {
            anuncianteWidget =
                _infoRow("Anunciante", _primeiroNome(fallbackTutorName));
          } else {
            anuncianteWidget = FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(tutorId)
                  .get(),
              builder: (context, snapTutor) {
                if (snapTutor.connectionState == ConnectionState.waiting) {
                  return _infoRow("Anunciante", "Carregando...");
                }

                if (!snapTutor.hasData ||
                    !snapTutor.data!.exists ||
                    snapTutor.hasError) {
                  return _infoRow(
                    "Anunciante",
                    _primeiroNome(fallbackTutorName),
                  );
                }

                final userData =
                    snapTutor.data!.data() as Map<String, dynamic>?;

                // usa só 'name' mesmo, igual está no Firestore
                final rawName =
                    (userData?['name'] ?? fallbackTutorName).toString();

                final primeiroNome = _primeiroNome(rawName);

                return _infoRow("Anunciante", primeiroNome);
              },
            );
          }

          // ----------------------------------------------------------
          // UI
          // ----------------------------------------------------------
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
                  // 🖼️ CARROSSEL DE IMAGENS COM SETAS + CONTADOR
                  SizedBox(
                    height: 250,
                    child: fotos.isNotEmpty
                        ? Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: fotos.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final url = fotos[index];
                                  return GestureDetector(
                                    onTap: () =>
                                        _abrirImagemFull(context, url),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 70,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // ◀️ Seta esquerda
                              if (fotos.length > 1)
                                Positioned(
                                  left: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () => _irParaPagina(
                                        _currentPage - 1,
                                        fotos.length,
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black45,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.chevron_left,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // ▶️ Seta direita
                              if (fotos.length > 1)
                                Positioned(
                                  right: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () => _irParaPagina(
                                        _currentPage + 1,
                                        fotos.length,
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black45,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // 📍 Indicador "1/3" no canto inferior direito
                              if (fotos.length > 1)
                                Positioned(
                                  bottom: 10,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_currentPage + 1}/${fotos.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              placeholderUrl,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),

                  // 🖼️ THUMBNAILS ABAIXO DO CARROSSEL
                  if (fotos.length > 1) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: fotos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final thumbUrl = fotos[index];
                          final bool isActive = index == _currentPage;

                          return GestureDetector(
                            onTap: () {
                              _irParaPagina(index, fotos.length);
                            },
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xFFDC004E)
                                      : Colors.grey.shade300,
                                  width: isActive ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  thumbUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

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

                  Text(
                    "$idade • $localizacao",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Informações Gerais",
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

                  _infoRow("Espécie", especie),
                  _infoRow("Sexo", genero),
                  _infoRow("Porte", porte),
                  _infoRow("Tipo de anúncio", tipo),
                  _infoRow("Localização", localizacao),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Informações do Anunciante",
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

                  // 👤 Nome do anunciante (primeiro nome do usuário)
                  anuncianteWidget,

                  // 📱 Telefone
                  _infoRow("Telefone", mascararTelefone(telefoneTutor)),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Descrição",
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
    );
  }

  // Widget auxiliar de linha informativa
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
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
