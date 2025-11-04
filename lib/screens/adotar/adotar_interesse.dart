import 'package:flutter/material.dart';

class AdotarInteresse extends StatelessWidget {
  const AdotarInteresse({super.key});

  @override
  Widget build(BuildContext context) {
    final pet =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    // 🔹 Estilo padrão dos campos de texto
    InputDecoration customInput(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFDC004E),
          fontWeight: FontWeight.w500,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC004E), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC004E), width: 1),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFFFF7E6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Adotar ${pet['nome']}'),
        backgroundColor: const Color(0xFFDC004E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(decoration: customInput('Seu nome')),
            const SizedBox(height: 16),
            TextField(
              decoration: customInput('Telefone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: customInput('Por que quer adotar?'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC004E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/adotar_success');
              },
              child: const Text(
                'Enviar Solicitação',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
