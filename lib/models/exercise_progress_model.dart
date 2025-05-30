/// Representa el progreso registrado por un usuario en un ejercicio específico.
class ExerciseProgress {
  final String uid;
  final String ejercicio;
  final DateTime fecha;
  final int series;
  final int repeticiones;
  final double peso;

  ExerciseProgress({
    required this.uid,
    required this.ejercicio,
    required this.fecha,
    required this.series,
    required this.repeticiones,
    required this.peso,
  });

  /// Serializa el objeto a un mapa.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'ejercicio': ejercicio,
      'fecha': fecha.toIso8601String(),
      'series': series,
      'repeticiones': repeticiones,
      'peso': peso,
    };
  }

  /// Crea una instancia desde un mapa, con manejo básico de errores.
  factory ExerciseProgress.fromMap(Map<String, dynamic> map) {
    try {
      return ExerciseProgress(
        uid: map['uid'] ?? '',
        ejercicio: map['ejercicio'] ?? '',
        fecha: DateTime.tryParse(map['fecha'] ?? '') ?? DateTime.now(),
        series: map['series'] ?? 0,
        repeticiones: map['repeticiones'] ?? 0,
        peso: (map['peso'] is num) ? (map['peso'] as num).toDouble() : 0.0,
      );
    } catch (e) {
      throw FormatException('Error al convertir ExerciseProgress: $e');
    }
  }
}
