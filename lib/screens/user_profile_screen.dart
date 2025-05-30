import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_tracker/screens/auth/login_screen.dart';
import '../models/user_profile.dart';
import '../service/firebase_service.dart';
import '../utils/validators.dart'; // NUEVO

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // NUEVO

  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _estaturaController = TextEditingController();
  final _pesoController = TextEditingController();
  bool _cargando = false;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final perfil = await _firebaseService.getUserProfileData(uid);
    if (perfil != null) {
      _nombreController.text = perfil.nombre;
      _edadController.text = perfil.edad.toString();
      _estaturaController.text = perfil.estatura.toString();
      _pesoController.text = perfil.peso.toString();
    }
  }

  Future<void> _guardarDatos() async {
    if (!_formKey.currentState!.validate()) return; // NUEVO

    setState(() => _cargando = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final perfil = UserProfile(
      uid: uid,
      nombre: _nombreController.text.trim(),
      edad: int.tryParse(_edadController.text) ?? 0,
      estatura: double.tryParse(_estaturaController.text) ?? 0,
      peso: double.tryParse(_pesoController.text) ?? 0,
    );

    final ok = await _firebaseService.setUserProfile(perfil);

    setState(() => _cargando = false);

    if (mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados')),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) =>  LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Mi perfil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Spacer(),
                  _cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : IconButton(
                          onPressed: _guardarDatos,
                          icon: const Icon(Icons.save_alt, color: Colors.white),
                          tooltip: 'Guardar cambios',
                        ),
                ],
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF3366FF),
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Form(
                  key: _formKey, // NUEVO
                  child: ListView(
                    children: [
                      _buildField("Nombre", _nombreController,
                          validator: Validators.validateRequired),
                      _buildField("Edad", _edadController,
                          keyboardType: TextInputType.number,
                          validator: Validators.validateEdad),
                      _buildField("Estatura (cm)", _estaturaController,
                          keyboardType: TextInputType.number,
                          validator: Validators.validateEstatura),
                      _buildField("Peso (kg)", _pesoController,
                          keyboardType: TextInputType.number,
                          validator: Validators.validatePeso),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar sesión"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
