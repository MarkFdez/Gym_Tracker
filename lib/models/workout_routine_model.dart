import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String nombre;
  final String grupoMuscular;
  final int series;
  final int repeticiones;
  final double peso;
  final String? nota;

  Exercise({
    required this.nombre,
    required this.grupoMuscular,
    required this.series,
    required this.repeticiones,
    required this.peso,
    this.nota,
  });

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

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      nombre: map['nombre'],
      grupoMuscular: map['grupoMuscular'],
      series: map['series'],
      repeticiones: map['repeticiones'],
      peso: (map['peso'] as num).toDouble(),
      nota: map['nota'],
    );
  }
}

class WorkoutRoutine {
  final String id;
  final String uid;
  final DateTime fecha;
  final String nombre;
  final List<Exercise> ejercicios;
  final int? diaSemana; // 0=Lunes … 6=Domingo

  WorkoutRoutine({
    required this.id,
    required this.uid,
    required this.fecha,
    required this.nombre,
    required this.ejercicios,
    this.diaSemana,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fecha': fecha,
      'nombre': nombre,
      'ejercicios': ejercicios.map((e) => e.toMap()).toList(),
      'diaSemana': diaSemana,
    };
  }

  factory WorkoutRoutine.fromMap(String id, Map<String, dynamic> map) {
    return WorkoutRoutine(
      id: id,
      uid: map['uid'],
      fecha: (map['fecha'] as Timestamp).toDate(),
      nombre: map['nombre'],
      ejercicios: List<Map<String, dynamic>>.from(map['ejercicios'])
          .map((e) => Exercise.fromMap(e))
          .toList(),
      diaSemana: map['diaSemana'] as int?,
    );
  }
}

