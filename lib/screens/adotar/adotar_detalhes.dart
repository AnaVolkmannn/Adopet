import 'package:flutter/material.dart';
import '../../../widgets/custom_drawer.dart'; // 👈 importa seu drawer customizado

class AdotarDetalhes extends StatelessWidget {
  const AdotarDetalhes({super.key});

  @override
  Widget build(BuildContext context) {
    final pet =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final List<String> imagens = pet['imagens'] != null
        ? List<String>.from(pet['imagens']!)
        : [pet['imagem'] ?? 'https://via.placeholder.com/400'];

    final nomePet = (pet['sem_nome'] == true || pet['sem_nome'] == 'true')
        ? 'Sem nome'
        : (pet['nome'] ?? 'Sem nome');

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),

      // 🚫 remove o endDrawer padrão (não usado mais)
      // endDrawer: const CustomDrawer(),

      // ✅ Cabeçalho igual ao AnuncioBaseScreen
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

                  // ☰ Botão do menu que abre o Drawer customizado
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFFDC004E)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent, // 💖 sem fundo cinza
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

      // 📄 Corpo
      body: SafeArea(
        child: SingleChildScrollView(
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
                // 📸 Galeria
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 250,
                    child: PageView.builder(
                      itemCount: imagens.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          imagens[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 80),
                        );
                      },
                    ),
                  ),
                ),

                if (imagens.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${imagens.length} fotos',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // 🐶 Nome
                Text(
                  nomePet,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC004E),
                  ),
                ),

                const SizedBox(height: 6),

                // 👶 Idade e gênero
                Text(
                  '${pet['idade'] ?? 'Idade não informada'} • ${pet['genero'] ?? 'Gênero não informado'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 Informações gerais
                _infoRow('Espécie', pet['especie'] ?? 'Não informada'),
                _infoRow('Porte', pet['porte'] ?? 'Não informado'),
                _infoRow('Tipo de anúncio', pet['tipo'] ?? 'Não informado'),
                _infoRow('Localização', pet['localizacao'] ?? 'Não informada'),

                const SizedBox(height: 25),

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
                const Divider(color: Color(0xFFDC004E), thickness: 1),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pet['descricao'] ?? 'Sem descrição disponível.',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ❤️ Botão "Quero Adotar"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC004E),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/adotar_interesse',
                      arguments: pet,
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
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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