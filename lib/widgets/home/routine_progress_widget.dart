
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/workout_session_model.dart';

class RoutineProgressWidget extends StatefulWidget {
  final String rutinaId;
  final String nombreRutina;

  const RoutineProgressWidget({
    super.key,
    required this.rutinaId,
    required this.nombreRutina,
  });

  @override
  State<RoutineProgressWidget> createState() => _RoutineProgressWidgetState();
}

class _RoutineProgressWidgetState extends State<RoutineProgressWidget> {
  late Future<_ResumenRutina> _resumenFuture;

  @override
  void initState() {
    super.initState();
    _resumenFuture = _cargarResumenRutina();
  }

  Future<_ResumenRutina> _cargarResumenRutina() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final snap = await FirebaseFirestore.instance
        .collection('sesiones')
        .where('uid', isEqualTo: user.uid)
        .where('rutinaId', isEqualTo: widget.rutinaId)
        .get();

    List<WorkoutSession> sesiones = snap.docs
        .map((doc) => WorkoutSession.fromMap(doc.id, doc.data()))
        .toList();

    Map<String, List<double>> pesosPorEjercicio = {};
    Map<String, double> mejoraPorEjercicio = {};

    for (var sesion in sesiones) {
      for (var ejercicio in sesion.ejercicios) {
        final nombre = ejercicio.nombre;
        pesosPorEjercicio[nombre] = (pesosPorEjercicio[nombre] ?? [])..add(ejercicio.peso);
      }
    }

    pesosPorEjercicio.forEach((nombre, lista) {
      if (lista.length > 1) {
        final mejora = ((lista.last - lista.first) / lista.first) * 100;
        mejoraPorEjercicio[nombre] = mejora;
      } else {
        mejoraPorEjercicio[nombre] = 0;
      }
    });

    final totalSesiones = sesiones.length;
    final sesionesEsperadas = 4;
    final double adherencia = sesionesEsperadas > 0 ? totalSesiones / sesionesEsperadas : 0;
    final String consistencia = (totalSesiones >= 4)
        ? "Alta"
        : (totalSesiones >= 2)
            ? "Media"
            : "Baja";

    return _ResumenRutina(
      pesosPorEjercicio,
      mejoraPorEjercicio,
      totalSesiones,
      adherencia.clamp(0.0, 1.0),
      consistencia,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ResumenRutina>(
      future: _resumenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("Error al cargar progreso de rutina");
        }

        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nombreRutina,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            _buildResumen(context, data),
            const SizedBox(height: 24),
            ...data.progresoPorEjercicio.entries.map((entry) {
              final pesos = entry.value;
              final nombre = entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                    )),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                pesos.length,
                                (i) => FlSpot(i.toDouble(), pesos[i]),
                              ),
                              isCurved: true,
                              color: const Color(0xFF3366FF),
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color.fromRGBO(51, 102, 255, 0.2),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mejora: ${data.mejoraPorEjercicio[nombre]!.toStringAsFixed(1)}%",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: data.mejoraPorEjercicio[nombre]! >= 0
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildResumen(BuildContext context, _ResumenRutina data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Resumen de rutina", style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white
          )),
          const SizedBox(height: 8),
          _statLine(context, "Total sesiones", data.totalSesiones.toString()),
          _statLine(context, "Adherencia", "${(data.adherencia * 100).toStringAsFixed(1)}%"),
          _statLine(context, "Consistencia", data.consistencia),
        ],
      ),
    );
  }

  Widget _statLine(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white
          )),
        ],
      ),
    );
  }
}

class _ResumenRutina {
  final Map<String, List<double>> progresoPorEjercicio;
  final Map<String, double> mejoraPorEjercicio;
  final int totalSesiones;
  final double adherencia;
  final String consistencia;

  _ResumenRutina(
    this.progresoPorEjercicio,
    this.mejoraPorEjercicio,
    this.totalSesiones,
    this.adherencia,
    this.consistencia,
  );
}
