/// Modelo que representa un ejercicio realizado durante una sesión de entrenamiento.
class ExerciseRecord {
  final String nombre;
  final String grupoMuscular;
  final int series;
  final int repeticiones;
  final double peso;
  final String? nota;

  ExerciseRecord({
    required this.nombre,
    required this.grupoMuscular,
    required this.series,
    required this.repeticiones,
    required this.peso,
    this.nota,
  });

  /// Convierte el ejercicio en un mapa.
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'grupoMuscular': grupoMuscular,
      'series': series,
      'repeticiones': repeticiones,
      'peso': peso,
      'nota': nota,
    };
  }

  /// Crea un ejercicio desde un mapa.
  factory ExerciseRecord.fromMap(Map<String, dynamic> map) {
    return ExerciseRecord(
      nombre: map['nombre'],
      grupoMuscular: map['grupoMuscular'],
      series: map['series'],
      repeticiones: map['repeticiones'],
      peso: (map['peso'] as num).toDouble(),
      nota: map['nota'],
    );
  }
}

/// Modelo que representa una sesión de entrenamiento realizada por un usuario.
class WorkoutSession {
  final String id;
  final String uid;
  final String rutinaId;
  final DateTime fecha;
  final List<ExerciseRecord> ejercicios;

  WorkoutSession({
    required this.id,
    required this.uid,
    required this.rutinaId,
    required this.fecha,
    required this.ejercicios,
  });

  /// Convierte la sesión en un mapa para almacenamiento.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'rutinaId': rutinaId,
      'fecha': fecha.toIso8601String(),
      'ejercicios': ejercicios.map((e) => e.toMap()).toList(),
    };
  }

  /// Crea una sesión desde un mapa y un ID.
  factory WorkoutSession.fromMap(String id, Map<String, dynamic> map) {
    return WorkoutSession(
      id: id,
      uid: map['uid'],
      rutinaId: map['rutinaId'],
      fecha: DateTime.parse(map['fecha']),
      ejercicios: List<Map<String, dynamic>>.from(map['ejercicios'])
          .map((e) => ExerciseRecord.fromMap(e))
          .toList(),
    );
  }
}
