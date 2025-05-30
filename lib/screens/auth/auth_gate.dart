import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/screens/auth/login_screen.dart';
import 'package:gym_tracker/screens/home_screen.dart';
import 'package:gym_tracker/screens/profile_screen_form.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/auth_provider.dart' as local; 

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<local.AuthProvider>(context).user; 

    if (user == null) {
      return LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('perfiles')
          .doc(user.uid)
          .get(),
      builder: (context, perfilSnapshot) {
        if (perfilSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (perfilSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error al cargar perfil')),
          );
        }

        final data = perfilSnapshot.data;
        if (data == null || !data.exists) {
          return const ProfileScreen(); // formulario para nuevo usuario
        }

        return const HomeScreen(); // todo correcto → ir a home
      },
    );
  }
}
