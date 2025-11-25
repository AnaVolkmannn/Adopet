import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _isSaving = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // 🔥 IMPORTANTE: resolver erro de dependOnInheritedWidget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _salvarAnuncio();
    });
  }

  Future<void> _salvarAnuncio() async {
    try {
      final finalPetData =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "Usuário não autenticado.";
          _isSaving = false;
        });
        return;
      }

      // -------- UPLOAD DAS FOTOS --------
      List<String> fotoUrls = [];

      final photos = finalPetData['photos'];

      if (photos != null && photos is List<File>) {
        for (File file in photos) {
          final String fileName =
              'pets/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final ref = FirebaseStorage.instance.ref().child(fileName);

          await ref.putFile(file);

          String downloadUrl = await ref.getDownloadURL();
          fotoUrls.add(downloadUrl);
        }
      }

      // -------- FIRESTORE --------
      final docRef =
          FirebaseFirestore.instance.collection('pets').doc(); // gera ID

      await docRef.set({
        "petId": docRef.id,
        "tutorId": user.uid,
        "name": finalPetData["name"],
        "noName": finalPetData["noName"],
        "species": finalPetData["species"],
        "gender": finalPetData["gender"],
        "size": finalPetData["size"],
        "ageYears": finalPetData["ageYears"],
        "ageMonths": finalPetData["ageMonths"],
        "photoUrls": fotoUrls,
        "adType": finalPetData["adType"],
        "state": finalPetData["state"],
        "city": finalPetData["city"],
        "description": finalPetData["description"],
        "foundDate": finalPetData["foundDate"],
        "contactPhone": finalPetData["contactPhone"],
        "contactEmail": finalPetData["contactEmail"],
        "status": "ativo",
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao salvar anúncio: $e";
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isSaving
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Salvando anúncio...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              )
            : _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error,
                            size: 100, color: Colors.redAccent),
                        const SizedBox(height: 30),
                        const Text(
                          'Erro ao salvar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: 'Voltar',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 100, color: AppColors.primary),
                        const SizedBox(height: 30),
                        const Text(
                          'Salvo com sucesso!',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'O que deseja fazer agora?',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: 'Voltar ao início',
                          onPressed: () =>
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
