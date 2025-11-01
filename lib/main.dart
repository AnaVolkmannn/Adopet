import 'package:flutter/material.dart';
import 'core/theme.dart';

// Telas principais
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// Divulgar Pet
import 'screens/divulgar_pet/divulgar_pet_start.dart';
import 'screens/divulgar_pet/perdido/criar_anuncio_perdido_06.dart';

// Adotar Pet
import 'screens/adotar/adotar_home.dart';
import 'screens/adotar/adotar_detalhes.dart';
import 'screens/adotar/adotar_interesse.dart';
import 'screens/adotar/adotar_success.dart';

// Outras
import 'screens/success_screen.dart';

// Meus Anúncios
import 'screens/meus_anuncios_screen.dart';

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

        // ✅ Corrigido: sem Scaffold extra
        '/divulgar': (context) => const DivulgarPetStart(),
        '/perdido6': (context) => const CriarAnuncioPerdido06(),

        '/success': (context) => const SuccessScreen(),

        '/adotar_home': (context) => const AdotarHome(),
        '/adotar_detalhes': (context) => const AdotarDetalhes(),
        '/adotar_interesse': (context) => const AdotarInteresse(),
        '/adotar_success': (context) => const AdotarSuccess(),

        '/meus_anuncios': (context) => const MeusAnunciosScreen(),
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
