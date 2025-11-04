import 'package:flutter/material.dart';
import 'core/theme.dart';

// Telas principais
import 'screens/home/splash_screen.dart';
import 'screens/home/start_screen.dart';
import 'screens/home/signup_screen.dart';
import 'screens/home/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'widgets/success_screen.dart';

// Divulgar Pet
import 'screens/divulgar_pet/divulgar_pet_01.dart';
import 'screens/divulgar_pet/divulgar_pet_02.dart';

// Adotar Pet
import 'screens/adotar/adotar_home.dart';
import 'screens/adotar/adotar_detalhes.dart';
import 'screens/adotar/adotar_interesse.dart';

// Meus Anúncios
import 'screens/meus_anuncios/meus_anuncios_screen.dart';

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
        '/divulgar1': (context) => const DivulgarPet01(),
        '/divulgar2': (context) => const DivulgarPet02(),
        '/adotar_home': (context) => const AdotarHome(),
        '/adotar_detalhes': (context) => const AdotarDetalhes(),
        '/adotar_interesse': (context) => const AdotarInteresse(),
        '/meus_anuncios': (context) => const MeusAnunciosScreen(),
        '/success': (context) => const SuccessScreen(),
      },

      // 🔒 Previne duplicação de Scaffold ao voltar de telas com menu
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
