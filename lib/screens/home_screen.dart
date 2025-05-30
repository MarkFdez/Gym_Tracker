import 'package:flutter/material.dart';
import 'package:gym_tracker/screens/user_profile_screen.dart';
import 'package:gym_tracker/service/firebase_service.dart';
import 'package:gym_tracker/widgets/home/monthly_overview_widget.dart';
import 'package:gym_tracker/widgets/home/no_routine_placeholder_widget.dart';
import 'package:gym_tracker/widgets/home/routine_card_widget.dart';
import 'package:gym_tracker/widgets/home/routine_progress_widget.dart';
import 'package:gym_tracker/widgets/home/weekly_calendar_widget.dart';
import 'package:gym_tracker/screens/start_session_screen.dart';
import '../models/workout_routine_model.dart';
import 'create_routine_screen.dart';
import 'routine_list_screen.dart';
/// Pantalla principal que muestra la rutina del día, calendario semanal,
/// accesos a creación/listado de rutinas y progreso mensual.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  bool _cargando = true;
  int _diaActual = DateTime.now().weekday - 1;
  String _nombreUsuario = '';
  List<WorkoutRoutine> _rutinas = [];
  WorkoutRoutine? _rutinaDelDia;

  @override
  void initState() {
    super.initState();
    _verificarPerfilYRutinas();
  }

   /// Obtiene el perfil del usuario y sus rutinas desde Firebase.
Future<void> _verificarPerfilYRutinas() async {
  final user = _firebaseService.currentUser;
  if (user == null || !mounted) return;

  final perfilDoc = await _firebaseService.getUserProfile(user.uid);
  if (!mounted || perfilDoc == null || perfilDoc.data() == null || !(perfilDoc.exists)) return;

  final data = perfilDoc.data() as Map<String, dynamic>?;

  _nombreUsuario = data?['nombre'] ?? 'Usuario';

  final rutinaSnap = await _firebaseService.getUserRoutines(user.uid);
  if (!mounted || rutinaSnap == null) return;

  setState(() {
    _rutinas = rutinaSnap.docs
        .map((doc) => WorkoutRoutine.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    _cargando = false;
  });

  _actualizarRutinaDelDia();
}


   /// Determina cuál es la rutina asignada para el día seleccionado.
  void _actualizarRutinaDelDia() {
    final rutinaDelDiaList = _rutinas.where((r) => r.diaSemana == _diaActual).toList();
    setState(() {
      _rutinaDelDia = rutinaDelDiaList.isNotEmpty ? rutinaDelDiaList.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final rutinasSinAsignar = _rutinas.where((r) => r.diaSemana == null).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCalendar(),
              const SizedBox(height: 24),
              _buildRoutineSection(_rutinaDelDia, rutinasSinAsignar),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildProgressSection(_rutinaDelDia),
            ],
          ),
        ),
      ),
    );
  }

    /// Muestra el encabezado con saludo al usuario y acceso a su perfil.
  Widget _buildHeader() {
    final now = DateTime.now();
    final fecha = "${now.day}/${now.month}/${now.year}";
    final inicial = _nombreUsuario.isNotEmpty ? _nombreUsuario[0].toUpperCase() : '?';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $_nombreUsuario',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              fecha,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white12,
            child: Text(
              inicial,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }
 /// Muestra el calendario semanal para seleccionar el día de entrenamiento.
  
  Widget _buildCalendar() {
    return WeeklyCalendarWidget(
      selectedDayIndex: _diaActual,
      onDaySelected: (index) {
        setState(() {
          _diaActual = index;
          _actualizarRutinaDelDia();
        });
      },
    );
  }

   /// Muestra la rutina asignada para el día o un placeholder si no hay ninguna.
  Widget _buildRoutineSection(WorkoutRoutine? rutinaDelDia, List<WorkoutRoutine> rutinasSinAsignar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rutina de hoy', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
        const SizedBox(height: 12),
        if (rutinaDelDia != null)
          RoutineCardWidget(
            rutina: rutinaDelDia,
            onStart: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StartSessionScreen(rutina: rutinaDelDia),
                ),
              ).then((_) => _verificarPerfilYRutinas());
            },
          )
        else
          NoRoutinePlaceholderWidget(
            rutinasSinAsignar: rutinasSinAsignar,
            onCreate: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
              );
              _verificarPerfilYRutinas();
            },
            onAsignar: (rutina) async {
              final uid = _firebaseService.currentUser?.uid;
              if (uid != null) {
                await _firebaseService.assignRoutineToDay(rutina.id, _diaActual);
                _verificarPerfilYRutinas();
              }
            },
          ),
      ],
    );
  }

  /// Muestra los botones de acción para crear o ver rutinas.
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
            );
            _verificarPerfilYRutinas();
          },
          child: const Text(
            '+ Crear rutina',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF3366FF),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoutineListScreen()),
            );
          },
          child: const Text(
            'Ver rutinas',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF3366FF),
            ),
          ),
        ),
      ],
    );
  }

   /// Muestra el progreso de la rutina del día o el resumen mensual.
  Widget _buildProgressSection(WorkoutRoutine? rutinaDelDia) {
    return rutinaDelDia != null
        ? RoutineProgressWidget(
            key: ValueKey(rutinaDelDia.id),
            rutinaId: rutinaDelDia.id,
            nombreRutina: rutinaDelDia.nombre,
          )
        : const MonthlyOverviewWidget();
  }
}
