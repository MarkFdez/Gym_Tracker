import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_tracker/models/workout_session_model.dart';
import 'package:gym_tracker/service/firebase_service.dart';
import '../models/workout_routine_model.dart';
/// Pantalla para registrar una nueva sesión de entrenamiento basada en una rutina.
/// Permite modificar valores de series, repeticiones, peso y añadir notas por ejercicio.
class StartSessionScreen extends StatefulWidget {
  final WorkoutRoutine rutina;

  const StartSessionScreen({super.key, required this.rutina});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  final Map<String, TextEditingController> _pesoControllers = {};
  final Map<String, TextEditingController> _seriesControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _notaControllers = {};
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    for (var ejercicio in widget.rutina.ejercicios) {
      _pesoControllers[ejercicio.nombre] =
          TextEditingController(text: ejercicio.peso.toString());
      _seriesControllers[ejercicio.nombre] =
          TextEditingController(text: ejercicio.series.toString());
      _repsControllers[ejercicio.nombre] =
          TextEditingController(text: ejercicio.repeticiones.toString());
      _notaControllers[ejercicio.nombre] = TextEditingController();
    }
  }

  bool _validarCampos() {
    for (var ejercicio in widget.rutina.ejercicios) {
      final series = int.tryParse(_seriesControllers[ejercicio.nombre]?.text ?? '');
      final reps = int.tryParse(_repsControllers[ejercicio.nombre]?.text ?? '');
      final peso = double.tryParse(_pesoControllers[ejercicio.nombre]?.text ?? '');

      if (series == null || series <= 0 ||
          reps == null || reps <= 0 ||
          peso == null || peso < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Verifica que todos los campos tengan valores válidos.')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _guardarSesion() async {
    if (!_validarCampos()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ejercicios = widget.rutina.ejercicios.map((ejercicio) {
      return ExerciseRecord(
        nombre: ejercicio.nombre,
        grupoMuscular: ejercicio.grupoMuscular,
        peso: double.tryParse(_pesoControllers[ejercicio.nombre]?.text ?? '') ?? 0,
        series: int.tryParse(_seriesControllers[ejercicio.nombre]?.text ?? '') ?? 0,
        repeticiones: int.tryParse(_repsControllers[ejercicio.nombre]?.text ?? '') ?? 0,
        nota: _notaControllers[ejercicio.nombre]?.text,
      );
    }).toList();

    final sesion = WorkoutSession(
      id: '',
      uid: uid,
      rutinaId: widget.rutina.id,
      fecha: DateTime.now(),
      ejercicios: ejercicios,
    );

    final ok = await _firebaseService.saveWorkoutSession(sesion);

    if (mounted && ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión registrada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Sesión: ${widget.rutina.nombre}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...widget.rutina.ejercicios.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Series',
                            controller: _seriesControllers[e.nombre]!,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInputField(
                            label: 'Reps',
                            controller: _repsControllers[e.nombre]!,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInputField(
                            label: 'Peso (kg)',
                            controller: _pesoControllers[e.nombre]!,
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      label: 'Notas (opcional)',
                      controller: _notaControllers[e.nombre]!,
                      isFullWidth: true,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardarSesion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3366FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar sesión',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isFullWidth = false,
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      inputFormatters: decimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
