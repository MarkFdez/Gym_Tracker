
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget que muestra un calendario horizontal de la semana actual.
/// Permite seleccionar un día y destaca el seleccionado.
class WeeklyCalendarWidget extends StatelessWidget {
  final int selectedDayIndex;
  final Function(int) onDaySelected;

  const WeeklyCalendarWidget({
    super.key,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = startOfWeek.add(Duration(days: index));
        final isSelected = index == selectedDayIndex;

        return GestureDetector(
          onTap: () => onDaySelected(index),
          child: Container(
            width: 42,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3366FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                /// Día de la semana (ej. "Lu", "Ma", etc.)
                Text(
                  DateFormat.E('es_ES').format(day).substring(0, 2),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),

                /// Número del día (ej. 28, 29, etc.)
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

