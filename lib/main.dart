import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/divulgar_pet/divulgar_pet_start.dart';
import 'screens/divulgar_pet/perdido/criar_anuncio_perdido_02.dart';
import 'screens/divulgar_pet/perdido/criar_anuncio_perdido_03.dart';
import 'screens/divulgar_pet/perdido/criar_anuncio_perdido_04.dart';
import 'screens/divulgar_pet/perdido/criar_anuncio_perdido_05.dart';
import 'screens/divulgar_pet/perdido/criar_anuncio_perdido_06.dart';
import 'screens/divulgar_pet/procurando_tutor/criar_anuncio_tutor_02.dart';
import 'screens/divulgar_pet/procurando_tutor/criar_anuncio_tutor_03.dart';
import 'screens/divulgar_pet/procurando_tutor/criar_anuncio_tutor_04.dart';
import 'screens/divulgar_pet/procurando_tutor/criar_anuncio_tutor_05.dart';
import 'screens/divulgar_pet/procurando_tutor/criar_anuncio_tutor_06.dart';
import 'screens/adotar/adotar_home.dart';
import 'screens/adotar/adotar_detalhes.dart';
import 'screens/adotar/adotar_interesse.dart';
import 'screens/adotar/adotar_success.dart';
import 'screens/success_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adopet',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/start': (context) => const StartScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/divulgar': (context) => const DivulgarPetStart(),
        '/perdido2': (context) => const CriarAnuncioPerdido02(),
        '/perdido3': (context) => const CriarAnuncioPerdido03(),
        '/perdido4': (context) => const CriarAnuncioPerdido04(),
        '/perdido5': (context) => const CriarAnuncioPerdido05(),
        '/perdido6': (context) => const CriarAnuncioPerdido06(),
        '/tutor2': (context) => const CriarAnuncioTutor02(),
        '/tutor3': (context) => const CriarAnuncioTutor03(),
        '/tutor4': (context) => const CriarAnuncioTutor04(),
        '/tutor5': (context) => const CriarAnuncioTutor05(),
        '/tutor6': (context) => const CriarAnuncioTutor06(),
        '/success': (context) => const SuccessScreen(),
        '/adotar_home': (context) => const AdotarHome(),
        '/adotar_detalhes': (context) => const AdotarDetalhes(),
        '/adotar_interesse': (context) => const AdotarInteresse(),
        '/adotar_success': (context) => const AdotarSuccess(),
      },
    );
  }
}
