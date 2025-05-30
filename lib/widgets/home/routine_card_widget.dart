
import 'package:flutter/material.dart';
import '../../models/workout_routine_model.dart';

/// Widget que muestra una tarjeta con los detalles de una rutina.
/// Incluye nombre, cantidad de ejercicios y botón para iniciar la sesión.
class RoutineCardWidget extends StatelessWidget {
  final WorkoutRoutine rutina;
  final VoidCallback? onStart;

  const RoutineCardWidget({
    super.key,
    required this.rutina,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Nombre de la rutina
          Text(
            rutina.nombre,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 6),

          /// Cantidad de ejercicios
          Text(
            '${rutina.ejercicios.length} ejercicios',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 16),

          /// Lista de ejercicios con sus datos básicos
          ...rutina.ejercicios.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.nombre,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${e.series}x${e.repeticiones}  ${e.peso}kg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Botón para comenzar sesión, si se provee `onStart`
          if (onStart != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Iniciar sesión",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
