
import 'package:flutter/material.dart';
import '../../models/workout_routine_model.dart';

/// Widget que se muestra cuando no hay rutina asignada para el día.
/// Permite al usuario crear una nueva rutina o asignar una existente.
class NoRoutinePlaceholderWidget extends StatelessWidget {
  final VoidCallback onCreate;
  final Function(WorkoutRoutine) onAsignar;
  final List<WorkoutRoutine> rutinasSinAsignar;

  const NoRoutinePlaceholderWidget({
    super.key,
    required this.onCreate,
    required this.onAsignar,
    required this.rutinasSinAsignar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'No hay rutina asignada para hoy',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        /// Muestra un carrusel de rutinas sin asignar, si existen.
        if (rutinasSinAsignar.isNotEmpty)
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: rutinasSinAsignar.length,
              controller: PageController(viewportFraction: 0.92),
              itemBuilder: (context, index) {
                final rutina = rutinasSinAsignar[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rutina.nombre,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${rutina.ejercicios.length} ejercicios',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// Lista parcial (máx. 3) de ejercicios dentro de la rutina.
                      ...rutina.ejercicios.take(3).map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                e.nombre,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${e.series}x${e.repeticiones} - ${e.peso}kg',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      )),

                      const Spacer(),

                      /// Botón para asignar esta rutina al día actual.
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => onAsignar(rutina),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3366FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text("Asignar a hoy"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}

