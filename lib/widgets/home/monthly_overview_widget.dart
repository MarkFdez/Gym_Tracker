import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/models/workout_session_model.dart';

/// Widget que presenta un resumen visual del entrenamiento mensual del usuario.
/// Muestra estadísticas, gráficos y distribución muscular.
class MonthlyOverviewWidget extends StatefulWidget {
  const MonthlyOverviewWidget({super.key});

  @override
  State<MonthlyOverviewWidget> createState() => _MonthlyOverviewWidgetState();
}

class _MonthlyOverviewWidgetState extends State<MonthlyOverviewWidget> {
  late Future<_EstadisticasMensuales> _estadisticasFuture;

  @override
  void initState() {
    super.initState();
    _estadisticasFuture = _cargarEstadisticasMensuales();
  }

  /// Carga y calcula estadísticas de las sesiones del mes actual.
  Future<_EstadisticasMensuales> _cargarEstadisticasMensuales() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    final finMes = DateTime(ahora.year, ahora.month + 1, 0);

    final snap = await FirebaseFirestore.instance
        .collection('sesiones')
        .where('uid', isEqualTo: user.uid)
        .get();

    List<WorkoutSession> sesiones = snap.docs
        .map((doc) => WorkoutSession.fromMap(doc.id, doc.data()))
        .where((s) => s.fecha.isAfter(inicioMes.subtract(const Duration(days: 1))) &&
                      s.fecha.isBefore(finMes.add(const Duration(days: 1))))
        .toList();

    List<int> sesionesPorDia = List.filled(finMes.day, 0);
    Map<String, int> grupoConteo = {};

    for (var sesion in sesiones) {
      int dia = sesion.fecha.day - 1;
      sesionesPorDia[dia] += 1;
      for (var ejercicio in sesion.ejercicios) {
        grupoConteo[ejercicio.grupoMuscular] = (grupoConteo[ejercicio.grupoMuscular] ?? 0) + 1;
      }
    }

    final diasEntrenados = sesionesPorDia.where((n) => n > 0).length;
    final totalSesiones = sesiones.length;

    int racha = 0;
    int rachaMax = 0;
    for (final sesionesDia in sesionesPorDia) {
      if (sesionesDia > 0) {
        racha++;
        if (racha > rachaMax) rachaMax = racha;
      } else {
        racha = 0;
      }
    }

    final sesionesMesAnterior = 10; // Placeholder
    double comparativa = sesionesMesAnterior > 0
        ? ((totalSesiones - sesionesMesAnterior) / sesionesMesAnterior) * 100
        : 0.0;

    Map<String, double> distribucion = {};
    final totalEjercicios = grupoConteo.values.fold<int>(0, (a, b) => a + b);
    if (totalEjercicios > 0) {
      grupoConteo.forEach((grupo, cantidad) {
        distribucion[grupo] = (cantidad / totalEjercicios) * 100;
      });
    }

    return _EstadisticasMensuales(
      sesionesPorDia,
      totalSesiones,
      diasEntrenados,
      rachaMax,
      comparativa,
      distribucion,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EstadisticasMensuales>(
      future: _estadisticasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("Error al cargar estadísticas");
        }

        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen mensual",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            _buildResumen(context, data),
            const SizedBox(height: 24),
            _buildGrafica(context, data),
            const SizedBox(height: 24),
            _buildDistribucion(context, data),
          ],
        );
      },
    );
  }

  /// Muestra las estadísticas principales: sesiones, días, racha, comparación.
  Widget _buildResumen(BuildContext context, _EstadisticasMensuales data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatLine(context, "Total sesiones", data.totalSesiones.toString()),
          _buildStatLine(context, "Días entrenados", data.diasEntrenados.toString()),
          _buildStatLine(context, "Racha máxima", "${data.rachaMax} días"),
          _buildStatLine(
            context,
            "Comparado al mes anterior",
            "${data.comparativa >= 0 ? "+" : ""}${data.comparativa.toStringAsFixed(1)}%",
            color: data.comparativa >= 0 ? Colors.greenAccent : Colors.redAccent,
          ),
        ],
      ),
    );
  }

  /// Muestra un gráfico de línea con las sesiones por día del mes.
  Widget _buildGrafica(BuildContext context, _EstadisticasMensuales data) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.sesionesPorDia.length,
                (i) => FlSpot(i.toDouble(), data.sesionesPorDia[i].toDouble()),
              ),
              isCurved: true,
              color: const Color(0xFF3366FF),
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: const Color.fromRGBO(51, 102, 255, 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra la distribución porcentual de los grupos musculares trabajados.
  Widget _buildDistribucion(BuildContext context, _EstadisticasMensuales data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Distribución muscular",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.distribucionGrupos.entries.map((entry) {
              return Chip(
                label: Text(
                  "${entry.key}: ${entry.value.toStringAsFixed(1)}%",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                backgroundColor: Colors.white10,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Construye una fila con una estadística etiquetada.
  Widget _buildStatLine(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

/// Estructura auxiliar para guardar las estadísticas procesadas del mes.
class _EstadisticasMensuales {
  final List<int> sesionesPorDia;
  final int totalSesiones;
  final int diasEntrenados;
  final int rachaMax;
  final double comparativa;
  final Map<String, double> distribucionGrupos;

  _EstadisticasMensuales(
    this.sesionesPorDia,
    this.totalSesiones,
    this.diasEntrenados,
    this.rachaMax,
    this.comparativa,
    this.distribucionGrupos,
  );
}
