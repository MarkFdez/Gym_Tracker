import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/workout_routine_model.dart';
import '../../screens/create_routine_screen.dart';
import '../../screens/start_session_screen.dart';

/// Widget que muestra la rutina asignada para un día específico.
/// Si no hay rutina, ofrece la opción de crear una o usar una no asignada.
class DayRoutineSection extends StatefulWidget {
  final int selectedDayIndex;

  const DayRoutineSection({super.key, required this.selectedDayIndex});

  @override
  State<DayRoutineSection> createState() => _DayRoutineSectionState();
}

class _DayRoutineSectionState extends State<DayRoutineSection> {
  WorkoutRoutine? _routine;
  List<WorkoutRoutine> _unassignedRoutines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutineData();
  }

  @override
  void didUpdateWidget(covariant DayRoutineSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDayIndex != widget.selectedDayIndex) {
      _loadRoutineData();
    }
  }

  /// Carga desde Firestore la rutina asignada al día actual y rutinas no asignadas.
  Future<void> _loadRoutineData() async {
    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final rutinaSnap = await FirebaseFirestore.instance
        .collection('rutinas')
        .where('uid', isEqualTo: uid)
        .where('diaSemana', isEqualTo: widget.selectedDayIndex)
        .limit(1)
        .get();

    final sinAsignarSnap = await FirebaseFirestore.instance
        .collection('rutinas')
        .where('uid', isEqualTo: uid)
        .where('diaSemana', isNull: true)
        .limit(2)
        .get();

    setState(() {
      _routine = rutinaSnap.docs.isNotEmpty
          ? WorkoutRoutine.fromMap(rutinaSnap.docs.first.id, rutinaSnap.docs.first.data())
          : null;

      _unassignedRoutines = sinAsignarSnap.docs
          .map((e) => WorkoutRoutine.fromMap(e.id, e.data()))
          .toList();

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Muestra indicador de carga mientras se obtienen datos.
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    /// Muestra la rutina asignada y permite comenzar la sesión.
    if (_routine != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rutina de hoy: ${_routine!.nombre}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._routine!.ejercicios.map((e) => ListTile(
                title: Text('${e.nombre} (${e.grupoMuscular})'),
                subtitle: Text('${e.series}x${e.repeticiones} - ${e.peso} kg'),
              )),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StartSessionScreen(rutina: _routine!),
                ),
              );
            },
            child: const Text('Comenzar sesión'),
          ),
        ],
      );
    }

    /// Si no hay rutina asignada, ofrece crear o asignar una existente.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('No hay rutina asignada para este día.'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
            );
          },
          child: const Text('Crear y asignar rutina'),
        ),
        if (_unassignedRoutines.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Rutinas sin asignar:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._unassignedRoutines.map((r) => Card(
                child: ListTile(
                  title: Text(r.nombre),
                  subtitle: Text('Ejercicios: ${r.ejercicios.length}'),
                ),
              )),
        ],
      ],
    );
  }
}
