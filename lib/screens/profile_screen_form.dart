import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_tracker/screens/home_screen.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _estaturaController = TextEditingController();
  final _pesoController = TextEditingController();

  bool _cargando = false;
  String? _mensajeError;

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _mensajeError = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      
      final perfil = UserProfile(
        uid: user.uid,
        nombre: _nombreController.text.trim(),
        edad: int.parse(_edadController.text),
        estatura: double.parse(_estaturaController.text),
        peso: double.parse(_pesoController.text),
      );

      await FirebaseFirestore.instance
          .collection('perfiles')
          .doc(user.uid)
          .set(perfil.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado correctamente')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _mensajeError = 'Error al guardar el perfil: \${e.toString()}';
      });
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _estaturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 40, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'Tu perfil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Configura tus datos personales',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              if (_mensajeError != null) ...[
                Text(
                  _mensajeError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      label: 'Nombre',
                      controller: _nombreController,
                      validator: (value) =>
                          value != null && value.isNotEmpty ? null : 'Campo obligatorio',
                    ),
                    _buildInputField(
                      label: 'Edad',
                      controller: _edadController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final edad = int.tryParse(value ?? '');
                        return (edad != null && edad > 0) ? null : 'Introduce una edad válida';
                      },
                    ),
                    _buildInputField(
                      label: 'Estatura (cm)',
                      controller: _estaturaController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final estatura = double.tryParse(value ?? '');
                        return (estatura != null && estatura > 0) ? null : 'Introduce una estatura válida';
                      },
                    ),
                    _buildInputField(
                      label: 'Peso (kg)',
                      controller: _pesoController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final peso = double.tryParse(value ?? '');
                        return (peso != null && peso > 0) ? null : 'Introduce un peso válido';
                      },
                    ),
                    const SizedBox(height: 30),
                    _cargando
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _guardarPerfil,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3366FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Guardar perfil',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
