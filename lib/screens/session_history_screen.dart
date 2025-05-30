import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_tracker/models/workout_routine_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionHistoryScreen extends StatelessWidget {
  final WorkoutRoutine rutina;

  const SessionHistoryScreen({super.key, required this.rutina});

  Future<List<Map<String, dynamic>>> _cargarSesiones() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('sesiones')
        .where('uid', isEqualTo: uid)
        .where('rutinaId', isEqualTo: rutina.id)
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Historial: ${rutina.nombre}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarSesiones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final sesiones = snapshot.data ?? [];

          if (sesiones.isEmpty) {
            return const Center(
              child: Text(
                'No hay sesiones registradas aún.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sesiones.length,
            itemBuilder: (context, index) {
              final sesion = sesiones[index];
              final fecha = DateTime.parse(sesion['fecha']);
              final ejercicios = List<Map<String, dynamic>>.from(sesion['ejercicios']);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  title: Text(
                    'Sesión del ${fecha.day}/${fecha.month}/${fecha.year} - ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  children: ejercicios.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              e['nombre'],
                              style: const TextStyle(fontSize: 14, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${e['series']}x${e['repeticiones']} - ${e['peso']}kg',
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
