import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class DivulgarPetStart extends StatelessWidget {
  const DivulgarPetStart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Divulgar Pet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Pet Perdido',
              onPressed: () => Navigator.pushNamed(context, '/perdido1'),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Procurando Tutor',
              onPressed: () => Navigator.pushNamed(context, '/tutor1'),
            ),
          ],
        ),
      ),
    );
  }
}