import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Pet')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.pets, size: 100, color: Color(0xFF3A86FF)),
            ),
            const SizedBox(height: 20),
            const Text('Nome: Luna', style: TextStyle(fontSize: 20)),
            const Text('Raça: Labrador', style: TextStyle(fontSize: 18)),
            const Text('Idade: 3 anos', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Adotar',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adoção registrada (simulação)!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
