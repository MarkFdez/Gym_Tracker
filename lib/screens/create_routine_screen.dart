import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_routine_model.dart';
import '../service/firebase_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _firebaseService = FirebaseService();

  final _nombreRutinaController = TextEditingController();
  final List<String> _gruposSeleccionados = [];
  final Map<String, bool> _ejerciciosSeleccionados = {};
  final Map<String, TextEditingController> _seriesControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _pesoControllers = {};
  int? _diaSemana;

  final List<String> _nombresDias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  final gruposMusculares = [
    'Pecho', 'Espalda', 'Piernas', 'Hombros',
    'Bíceps', 'Tríceps', 'Abdominales', 'Cardio',
  ];

  final Map<String, List<String>> ejerciciosPorGrupo = {
    'Pecho': ['Press banca', 'Aperturas', 'Press inclinado'],
    'Espalda': ['Dominadas', 'Remo', 'Peso muerto'],
    'Piernas': ['Sentadillas', 'Prensa', 'Zancadas'],
    'Hombros': ['Press militar', 'Elevaciones laterales'],
    'Bíceps': ['Curl con barra', 'Curl martillo'],
    'Tríceps': ['Fondos', 'Press francés'],
    'Abdominales': ['Crunch', 'Plancha'],
    'Cardio': ['Cinta', 'Bicicleta', 'Remo'],
  };

  List<String> get _ejerciciosFiltrados {
    final Set<String> ejercicios = {};
    for (final grupo in _gruposSeleccionados) {
      try {
        ejercicios.addAll(ejerciciosPorGrupo[grupo] ?? []);
      } catch (e) {
        debugPrint('Error al agregar ejercicios del grupo $grupo: $e');
      }
    }
    return ejercicios.toList();
  }

  Future<void> _guardarRutina() async {
    final localContext = context; 
    final uid = _firebaseService.currentUser?.uid;
    if (uid == null) return;

    final nombreRutina = _nombreRutinaController.text.trim();
    if (nombreRutina.isEmpty || _ejerciciosSeleccionados.values.every((v) => !v)) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(content: Text('Completa el nombre y selecciona ejercicios')),
      );
      return;
    }

    final List<Exercise> ejerciciosFinales = [];
    for (final entry in _ejerciciosSeleccionados.entries) {
      if (entry.value) {
        final nombre = entry.key;
        final grupo = _grupoDeEjercicio(nombre);
        final series = int.tryParse(_seriesControllers[nombre]?.text ?? '');
        final reps = int.tryParse(_repsControllers[nombre]?.text ?? '');
        final peso = double.tryParse(_pesoControllers[nombre]?.text ?? '');

        if (series != null && reps != null && peso != null) {
          ejerciciosFinales.add(
            Exercise(
              nombre: nombre,
              grupoMuscular: grupo,
              series: series,
              repeticiones: reps,
              peso: peso,
            ),
          );
        }
      }
    }

    if (_diaSemana != null) {
      final existingSnapshot = await _firebaseService.existeRutinaParaDia(uid, _diaSemana!);

      if (existingSnapshot.docs.isNotEmpty) {
        final confirmed = await showDialog<bool>(
          context: localContext, 
          builder: (context) => AlertDialog(
            title: const Text('Ya hay una rutina asignada'),
            content: Text(
              'Ya tienes una rutina asignada para ${_nombresDias[_diaSemana!]}. ¿Quieres reemplazarla?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sobrescribir'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        if (confirmed != true) return;

        for (var doc in existingSnapshot.docs) {
          await doc.reference.update({'diaSemana': null});
        }
      }
    }

    final rutina = WorkoutRoutine(
      id: '',
      uid: uid,
      fecha: DateTime.now(),
      nombre: nombreRutina,
      ejercicios: ejerciciosFinales,
      diaSemana: _diaSemana,
    );

    await _firebaseService.createRoutine(uid, rutina.toMap());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rutina guardada')),
    );

    Navigator.pop(context);
  }

  String _grupoDeEjercicio(String ejercicio) {
    for (final grupo in ejerciciosPorGrupo.entries) {
      if (grupo.value.contains(ejercicio)) return grupo.key;
    }
    return 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crear nueva rutina',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreRutinaController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre de la rutina',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                dropdownColor: const Color(0xFF1E1E1E),
                value: _diaSemana,
                decoration: const InputDecoration(
                  labelText: 'Día de la semana (opcional)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('Sin asignar')),
                  ...List.generate(7, (i) => DropdownMenuItem(value: i, child: Text(_nombresDias[i]))),
                ],
                onChanged: (val) => setState(() => _diaSemana = val),
              ),
              const SizedBox(height: 24),
              Text('Grupos musculares',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: gruposMusculares.map((grupo) {
                  final seleccionado = _gruposSeleccionados.contains(grupo);
                  return FilterChip(
                    label: Text(grupo),
                    selected: seleccionado,
                    labelStyle: TextStyle(color: seleccionado ? Colors.white : Colors.white70),
                    selectedColor: const Color(0xFF3366FF),
                    backgroundColor: const Color(0xFF1E1E1E),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _gruposSeleccionados.add(grupo);
                        } else {
                          _gruposSeleccionados.remove(grupo);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ..._ejerciciosFiltrados.map((ejercicio) {
                _ejerciciosSeleccionados.putIfAbsent(ejercicio, () => false);
                _seriesControllers.putIfAbsent(ejercicio, () => TextEditingController());
                _repsControllers.putIfAbsent(ejercicio, () => TextEditingController());
                _pesoControllers.putIfAbsent(ejercicio, () => TextEditingController());

                return Card(
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(ejercicio, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          value: _ejerciciosSeleccionados[ejercicio],
                          onChanged: (val) => setState(() {
                            _ejerciciosSeleccionados[ejercicio] = val ?? false;
                          }),
                        ),
                        if (_ejerciciosSeleccionados[ejercicio] == true)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _seriesControllers[ejercicio],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: 'Series', labelStyle: TextStyle(color: Colors.white70)),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _repsControllers[ejercicio],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: 'Reps', labelStyle: TextStyle(color: Colors.white70)),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _pesoControllers[ejercicio],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: 'Peso (kg)', labelStyle: TextStyle(color: Colors.white70)),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarRutina,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Center(child: Text('Guardar rutina')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
