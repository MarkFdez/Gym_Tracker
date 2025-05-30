import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;

  AuthProvider() {
    _firebaseService.auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  Future<void> signOut() async {
    await _firebaseService.signOut();
  }
}


