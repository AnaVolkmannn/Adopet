import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Certifique-se de que esse arquivo é gerado corretamente

// Telas principais
import 'screens/home/splash_screen.dart';
import 'screens/home/start_screen.dart';
import 'screens/home/signup_screen.dart';
import 'screens/home/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'widgets/success_screen.dart';
import 'screens/home/minha_conta.dart';
import 'screens/home/editar_conta.dart';

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

void main() async {
  // Garantir que os Widgets sejam inicializados primeiro.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar o Firebase antes de qualquer outra coisa
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Certifique-se que este arquivo exista
  );
  
  // Rodar o app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remover a banner de debug
      title: 'Adopet',

      // O AuthGate será o primeiro widget que controla a navegação
      home: const AuthGate(),

      // Definição de rotas no app
      routes: {
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
        '/minha_conta': (context) => const MinhaContaScreen(),
        '/editar_conta': (context) => const EditarContaScreen(),
      },
    );
  }
}

/// AuthGate decide a tela que o usuário verá baseado no estado de autenticação
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Verifica o estado da autenticação
      builder: (context, snapshot) {
        // Se o Firebase está verificando o estado de autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // Tela de splash enquanto verifica
        }

        // Se o usuário está autenticado, leva para a tela inicial (Home)
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Se não estiver logado, leva para a tela inicial (Start)
        return const StartScreen();
      },
    );
  }
}
