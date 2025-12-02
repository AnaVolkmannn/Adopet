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

    // Evita dependOnInheritedWidget no initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _salvarAnuncio();
    });
  }

  Future<void> _salvarAnuncio() async {
    try {
      final route = ModalRoute.of(context);
      final args = route?.settings.arguments;

      if (args == null || args is! Map<String, dynamic>) {
        if (!mounted) return;
        setState(() {
          _errorMessage = "Dados do anúncio não encontrados.";
          _isSaving = false;
        });
        return;
      }

      final finalPetData = Map<String, dynamic>.from(args);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = "Usuário não autenticado.";
          _isSaving = false;
        });
        return;
      }

      // ---------------------------
      // MODO: CREATE x EDIT
      // ---------------------------
      final String mode = (finalPetData['mode'] ?? 'create') as String;
      final bool isEdit = mode == 'edit';
      final String? petIdFromData = finalPetData['petId'] as String?;

      // ---------------------------
      // FOTOS: existingPhotos + newPhotos
      // ---------------------------

      // URLs que sobraram depois da edição (vindas da tela 1)
      List<String> existingPhotos = [];
      final existingDynamic = finalPetData['existingPhotos'];
      if (existingDynamic is List) {
        existingPhotos = existingDynamic.whereType<String>().toList();
      }

      // Novas fotos selecionadas (Files)
      List<File> newPhotos = [];
      final newPhotosDynamic = finalPetData['newPhotos'];
      if (newPhotosDynamic is List) {
        for (final item in newPhotosDynamic) {
          if (item is File) {
            newPhotos.add(item);
          }
        }
      }

      // Lista final que será salva no Firestore
      final List<String> finalPhotoUrls = [...existingPhotos];

      // Faz upload das fotos novas e adiciona as URLs
      for (File file in newPhotos) {
        final String fileName =
            'pets/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_${finalPhotoUrls.length}.jpg';

        final ref = FirebaseStorage.instance.ref().child(fileName);

        final uploadTask = await ref.putFile(file);
        final String downloadUrl = await uploadTask.ref.getDownloadURL();

        finalPhotoUrls.add(downloadUrl);
      }

      // ---------------------------
      // FIRESTORE
      // ---------------------------
      final collection = FirebaseFirestore.instance.collection('pets');

      // Se for edição com petId, reaproveita o mesmo doc
      final docRef =
          (isEdit && petIdFromData != null && petIdFromData.isNotEmpty)
              ? collection.doc(petIdFromData)
              : collection.doc();

      final Map<String, dynamic> dataToSave = {
        "petId": docRef.id,
        "tutorId": user.uid,
        "name": finalPetData["name"],
        "noName": finalPetData["noName"] ?? false,
        "species": finalPetData["species"],
        "gender": finalPetData["gender"],
        "size": finalPetData["size"],
        "ageYears": finalPetData["ageYears"] ?? 0,
        "ageMonths": finalPetData["ageMonths"] ?? 0,

        // ⭐ AGORA VAI SÓ A LISTA FINAL CORRETA
        "photoUrls": finalPhotoUrls,

        "adType": finalPetData["adType"],
        "state": finalPetData["state"],
        "city": finalPetData["city"],
        "description": finalPetData["description"],
        "foundDate": finalPetData["foundDate"],
        "contactPhone": finalPetData["contactPhone"],
        "contactEmail": finalPetData["contactEmail"],
        "status": "ativo",
        "updatedAt": FieldValue.serverTimestamp(),
      };

      // createdAt apenas na criação
      if (!isEdit) {
        dataToSave["createdAt"] = FieldValue.serverTimestamp();
      }

      await docRef.set(
        dataToSave,
        SetOptions(merge: isEdit),
      );

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      if (!mounted) return;
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
                            context,
                            '/home',
                            (route) => false,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}