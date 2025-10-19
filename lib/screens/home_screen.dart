import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Divulgue Pets para Adoção 🐾',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Divulgar um Pet',
              onPressed: () => Navigator.pushNamed(context, '/divulgar'),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Adotar um Pet',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}