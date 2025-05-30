import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/models/workout_routine_model.dart';

void main() {
  group('WorkoutRoutine', () {
    test('fromMap y toMap funcionan correctamente', () {
      final map = {
        'uid': 'user123',
        'fecha': Timestamp.fromDate(DateTime(2024, 5, 28)),
        'nombre': 'Rutina A',
        'diaSemana': 2,
        'ejercicios': [
          {
            'nombre': 'Press banca',
            'grupoMuscular': 'Pecho',
            'series': 4,
            'repeticiones': 10,
            'peso': 60.0
          }
        ]
      };

      final rutina = WorkoutRoutine.fromMap('rutinaXYZ', map);
      final resultMap = rutina.toMap();

      expect(rutina.id, 'rutinaXYZ');
      expect(rutina.uid, 'user123');
      expect(rutina.nombre, 'Rutina A');
      expect(rutina.diaSemana, 2);
      expect(rutina.ejercicios.length, 1);
      expect(rutina.ejercicios.first.nombre, 'Press banca');
      expect(rutina.ejercicios.first.peso, 60.0);
      expect(resultMap['nombre'], 'Rutina A');
      expect(resultMap['ejercicios'][0]['peso'], 60.0);
    });
  });
}
