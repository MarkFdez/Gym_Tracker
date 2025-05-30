import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

import 'package:gym_tracker/models/user_profile.dart';
import 'package:gym_tracker/models/workout_session_model.dart';
/// Servicio centralizado para operaciones con Firebase Authentication y Firestore.
class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;
  /// Usuario actualmente autenticado.
  User? get currentUser => _auth.currentUser;
  FirebaseAuth get auth => _auth;
 /// Obtiene el documento del perfil del usuario desde Firestore.
  Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('perfiles').doc(uid).get();
    } catch (e) {
      dev.log('Error al obtener perfil de usuario: $e');
      return null;
    }
  }
 /// Obtiene todas las rutinas del usuario autenticado.
  Future<QuerySnapshot?> getUserRoutines(String uid) async {
    try {
      return await _firestore.collection('rutinas').where('uid', isEqualTo: uid).get();
    } catch (e) {
      dev.log('Error al obtener rutinas del usuario: $e');
      return null;
    }
  }
 /// Asigna un día de la semana a una rutina existente.
  Future<bool> assignRoutineToDay(String routineId, int day) async {
    try {
      await _firestore.collection('rutinas').doc(routineId).update({'diaSemana': day});
      return true;
    } catch (e) {
      dev.log('Error al asignar rutina al día: $e');
      return false;
    }
  }
 /// Crea una nueva rutina en Firestore para el usuario especificado.
  Future<bool> createRoutine(String uid, Map<String, dynamic> routineData) async {
    try {
      await _firestore.collection('rutinas').add({...routineData, 'uid': uid});
      return true;
    } catch (e) {
      dev.log('Error al crear rutina: $e');
      return false;
    }
  }
  /// Cierra la sesión actual del usuario.
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      dev.log('Error al cerrar sesión: $e');
      return false;
    }
  }
 /// Verifica si ya existe una rutina asignada a un día específico.
  Future<QuerySnapshot> existeRutinaParaDia(String uid, int diaSemana) async {
  try {
    return await _firestore
        .collection('rutinas')
        .where('uid', isEqualTo: uid)
        .where('diaSemana', isEqualTo: diaSemana)
        .get();
  } catch (e) {
    rethrow; 
  }
}
/// Obtiene y convierte el perfil del usuario desde Firestore a un objeto [UserProfile].
 Future<UserProfile?> getUserProfileData(String uid) async {
    try {
      final doc = await _firestore.collection('perfiles').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }
 /// Guarda el perfil del usuario en Firestore.
  Future<bool> setUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('perfiles').doc(profile.uid).set(profile.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }
  /// Registra una sesión de entrenamiento en Firestore.
    Future<bool> saveWorkoutSession(WorkoutSession session) async {
    try {
      await _firestore.collection('sesiones').add(session.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

}
