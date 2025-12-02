import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MinhaContaScreen extends StatelessWidget {
  const MinhaContaScreen({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>?> _buscarDadosUsuarioFirestore(
      User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc;
      }
    } catch (_) {}
    return null;
  }

  String _extrairNome(User user, Map<String, dynamic>? userData) {
    String nome = 'Usuário';

    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      nome = user.displayName!;
    } else if (userData != null &&
        userData['name'] != null &&
        userData['name'].toString().trim().isNotEmpty) {
      nome = userData['name'].toString();
    } else if (user.email != null) {
      nome = user.email!.split('@').first;
    } else {
      nome = user.uid.substring(0, 6);
    }

    // Só o primeiro nome
    return nome.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFD70054),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF7E6),
          title: const Text(
            'Minha Conta',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Você não está logado.\nFaça login para ver os dados da sua conta.',
            textAlign: TextAlign.center,
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
      backgroundColor: const Color(0xFFFFF7E6),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(232, 0, 82, 100),
        title: const Text(
          'Minha Conta',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: _buscarDadosUsuarioFirestore(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color.fromRGBO(215, 0, 84, 10)),
            );
          }

          Map<String, dynamic>? userData;
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            userData = snapshot.data!.data();
          }

          final primeiroNome = _extrairNome(user, userData);

          final email = user.email ?? 'Não informado';
          final phoneAuth = user.phoneNumber;
          final phoneFromDb = userData != null ? userData['phone'] : null;

          final telefone = (phoneAuth != null && phoneAuth.trim().isNotEmpty)
              ? phoneAuth
              : (phoneFromDb != null && phoneFromDb.toString().trim().isNotEmpty)
                  ? phoneFromDb.toString()
                  : 'Não informado';

          final cidade = (userData != null
                  ? (userData['city'] ?? userData['cidade'])
                  : null)
              ?.toString();
          final estado = (userData != null
                  ? (userData['state'] ?? userData['estado'])
                  : null)
              ?.toString();

          String local = 'Não informado';
          if (cidade != null && cidade.trim().isNotEmpty) {
            if (estado != null && estado.trim().isNotEmpty) {
              local = '$cidade • $estado';
            } else {
              local = cidade;
            }
          } else if (estado != null && estado.trim().isNotEmpty) {
            local = estado;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar + nome
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFB6C1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0xFFFFE6EC),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFFDC004E),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primeiroNome,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC004E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Infos detalhadas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFB6C1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalhes da conta',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC004E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFDC004E)),

                      const SizedBox(height: 12),
                      _infoRow('E-mail', email),

                      _infoRow('Telefone', telefone),

                      _infoRow('Localização', local),

                      const SizedBox(height: 8),

                      if (user.metadata.creationTime != null)
                        _infoRow(
                          'Conta criada em',
                          '${user.metadata.creationTime!.day.toString().padLeft(2, '0')}/'
                          '${user.metadata.creationTime!.month.toString().padLeft(2, '0')}/'
                          '${user.metadata.creationTime!.year}',
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Botões de ação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC004E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      // TODO: você pode criar uma tela de edição e trocar essa rota
                      Navigator.pushNamed(context, '/editar_conta');
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Editar meus dados',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Color(0xFFDC004E)),
                  label: const Text(
                    'Sair da conta',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC004E),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Linha de informação reutilizável
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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