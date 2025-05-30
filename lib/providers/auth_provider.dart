import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/firebase_service.dart';

/// Proveedor de autenticación que expone el usuario actual y gestiona cambios en su estado.
class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;

  /// Inicializa el proveedor escuchando los cambios de autenticación.
  AuthProvider() {
    _firebaseService.auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Retorna el usuario autenticado actualmente, si lo hay.
  User? get user => _user;

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }
}
