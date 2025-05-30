import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/models/workout_session_model.dart';

void main() {
  group('WorkoutSession', () {
    test('fromMap y toMap funcionan correctamente', () {
      final map = {
        'uid': 'user123',
        'rutinaId': 'rutinaABC',
        'fecha': DateTime(2024, 5, 28).toIso8601String(),
        'ejercicios': [
          {
            'nombre': 'Press militar',
            'grupoMuscular': 'Hombros',
            'series': 3,
            'repeticiones': 8,
            'peso': 40.0
          }
        ]
      };

      final sesion = WorkoutSession.fromMap('sesion001', map);
      final resultMap = sesion.toMap();

      expect(sesion.id, 'sesion001');
      expect(sesion.uid, 'user123');
      expect(sesion.rutinaId, 'rutinaABC');
      expect(sesion.ejercicios.length, 1);
      expect(sesion.ejercicios.first.nombre, 'Press militar');
      expect(sesion.ejercicios.first.peso, 40.0);
      expect(resultMap['uid'], 'user123');
      expect(resultMap['ejercicios'][0]['repeticiones'], 8);
    });
  });
}
