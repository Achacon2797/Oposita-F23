import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appoposiciones/home.dart';
import 'package:appoposiciones/login.dart';
import 'firebase_options.dart';//dfgdf g
import 'theme.dart';//jghsadjygdyusft s

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa Firebase con las opciones predeterminadas para la plataforma actual
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ignore: avoid_print
    print(
        "Firebase Initialized"); // Confirmar que Firebase se inicializó correctamente

    // Configura la persistencia de la sesión de Firebase Authentication
    if (kIsWeb) {
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        // ignore: avoid_print
        print("Firebase Persistence Set to LOCAL for Web");
      } catch (e) {
        // ignore: avoid_print
        print("Error setting persistence for Web: $e");
      }
    }
    // ignore: avoid_print
    print("Firebase Persistence Set to LOCAL");
    FirebaseAuth
        .instance; // Aquí garantizamos que FirebaseAuth también se haya inicializado
  } catch (e, stacktrace) {
    // ignore: avoid_print
    print('Error al inicializar Firebase: $e');
    // ignore: avoid_print
    print('Stacktrace: $stacktrace');
  }

  runApp(const MyApp()); // Ejecuta la aplicación principal
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: const AuthGate(), // Redirige a la pantalla correspondiente
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthGateState createState() => _AuthGateState();
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Configura la persistencia para la web si es necesario
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus(); // Comprobar el estado de usuario al iniciar la app
  }

  Future<void> _checkUserStatus() async {
    try {
      // Asegúrate de que FirebaseAuth ha sido inicializado correctamente
      if (FirebaseAuth.instance.currentUser == null) {
        // ignore: avoid_print
        print("FirebaseAuth.instance is not initialized yet.");
      } else {
        // ignore: avoid_print
        print("FirebaseAuth instance initialized.");
      }

      // Verifica si ya hay un usuario autenticado en Firebase
      User? user = FirebaseAuth.instance.currentUser;
      // ignore: avoid_print
      print("Checking current user...");

      if (user != null) {
        // Si hay usuario, redirige a HomeScreen
        // ignore: avoid_print
        print("User is logged in: $user");
        _navigateToHome();
      } else {
        // Si no hay usuario, redirige a PantallaLogin
        // ignore: avoid_print
        print("No user found, redirecting to login.");
        _navigateToLogin();
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error al verificar el estado de autenticación: $e");
    }
  }

  void _navigateToHome() {
    // Redirige a la pantalla principal (HomeScreen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false, // Elimina todas las pantallas anteriores
      );
    });
  }

  void _navigateToLogin() {
    // Redirige a la pantalla de login (PantallaLogin)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const PantallaLogin(title: 'Login')),
        (route) => false, // Elimina todas las pantallas anteriores
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargando...')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _initializeFirebase(),
    builder: (context, snapshot) {
      // Muestra un indicador de progreso mientras espera
      if (snapshot.connectionState != ConnectionState.done) {
        return Scaffold(
          appBar: AppBar(title: const Text('Cargando...')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      // Una vez inicializado, verificar si el usuario está autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Si el usuario está autenticado, redirige a HomeScreen
        return const HomeScreen();
      } else {
        // Si no está autenticado, redirige a PantallaLogin
        return const PantallaLogin(title: 'Login');
      }
    },
  );
}
