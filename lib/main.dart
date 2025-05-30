import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/screens/auth/auth_gate.dart';
import 'package:gym_tracker/screens/auth/login_screen.dart';
import 'package:gym_tracker/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/auth_provider.dart' as local;

/// Punto de entrada principal de la aplicación.
/// Inicializa Firebase, configuración regional y gestiona errores durante el arranque.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('es_ES', null);
    await Firebase.initializeApp();
    runApp(
      ChangeNotifierProvider(
        create: (_) => local.AuthProvider(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    runApp(const InitializationErrorApp());
  }
}

/// Muestra un mensaje de error si la inicialización de la app falla.
class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Error al iniciar la aplicación.\nVerifica tu conexión o intenta más tarde.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget principal de la aplicación Gym Tracker.
/// Configura el tema, la ruta inicial y las rutas de autenticación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Tracker',
      theme: AppTheme.dark,
      initialRoute: '/auth',
      routes: {
        '/auth': (_) => const AuthGate(),
        '/login': (_) => LoginScreen(),
      },
    );
  }
}
