import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 Import do Firebase Auth
import 'firebase_options.dart';

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
import 'screens/divulgar_pet/divulgar_pet_03.dart';

// Adotar Pet
import 'screens/adotar/adotar_home.dart';
import 'screens/adotar/adotar_detalhes.dart';
import 'screens/adotar/adotar_interesse.dart';

// Meus Anúncios
import 'screens/meus_anuncios/meus_anuncios_screen.dart';

// 🚀 main assíncrona para inicializar o Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

      // 🔑 Em vez de initialRoute, usamos um "portão" de autenticação
      home: const AuthGate(),

      routes: {
        // Se quiser ainda usar a splash em algum lugar:
        '/splash': (context) => const SplashScreen(),

        '/start': (context) => const StartScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/divulgar1': (context) => const DivulgarPet01(),
        '/divulgar2': (context) => const DivulgarPet02(),
        '/divulgar3': (context) => const DivulgarPet03(),
        '/adotar_home': (context) => const AdotarHome(),
        '/adotar_detalhes': (context) => const AdotarDetalhes(),
        '/adotar_interesse': (context) => const AdotarInteresse(),
        '/meus_anuncios': (context) => const MeusAnunciosScreen(),
        '/success': (context) => const SuccessScreen(),
      },

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

/// 🛡 Widget que decide pra onde o usuário vai:
/// - Splash enquanto carrega
/// - Home se já estiver logado
/// - Start se não estiver logado
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Enquanto o Firebase está verificando sessão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // ✅ Usuário logado: vai direto pra Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // 🚪 Ninguém logado: vai pra tela inicial (start)
        return const StartScreen();
      },
    );
  }
}