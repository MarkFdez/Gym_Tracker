import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_tracker/screens/routine_detail_screen.dart';
import '../models/workout_routine_model.dart';
/// Pantalla que muestra una lista de rutinas creadas por el usuario.
/// Permite visualizar detalles de cada rutina.
class RoutineListScreen extends StatelessWidget {
  const RoutineListScreen({super.key});
  /// Carga las rutinas desde Firestore, ordenadas por fecha.
  Future<List<WorkoutRoutine>> _cargarRutinas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('rutinas')
        .where('uid', isEqualTo: uid)
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WorkoutRoutine.fromMap(doc.id, doc.data()))
        .toList();
  }
 /// Devuelve el nombre del día de la semana a partir del índice.
  String? _nombreDiaSemana(int? dia) {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return (dia != null && dia >= 0 && dia < 7) ? dias[dia] : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Mis rutinas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<WorkoutRoutine>>(
        future: _cargarRutinas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final rutinas = snapshot.data ?? [];

          if (rutinas.isEmpty) {
            return const Center(
              child: Text(
                'No has creado ninguna rutina todavía.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rutinas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final rutina = rutinas[index];
              final diaAsignado = _nombreDiaSemana(rutina.diaSemana);
              final textoDia = diaAsignado != null ? ' • $diaAsignado' : '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoutineDetailScreen(rutina: rutina),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rutina.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ejercicios: ${rutina.ejercicios.length} • ${rutina.fecha.toLocal().toString().substring(0, 10)}$textoDia',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
