/// Modelo que representa el perfil de un usuario del sistema.
class UserProfile {
  final String uid;
  final String nombre;
  final int edad;
  final double estatura;
  final double peso;

  UserProfile({
    required this.uid,
    required this.nombre,
    required this.edad,
    required this.estatura,
    required this.peso,
  });

  /// Convierte el perfil en un mapa clave-valor.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'edad': edad,
      'estatura': estatura,
      'peso': peso,
    };
  }

  /// Crea un perfil de usuario a partir de un mapa.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    try {
      return UserProfile(
        uid: map['uid'] ?? '',
        nombre: map['nombre'] ?? '',
        edad: map['edad'] ?? 0,
        estatura: (map['estatura'] is num) ? (map['estatura'] as num).toDouble() : 0.0,
        peso: (map['peso'] is num) ? (map['peso'] as num).toDouble() : 0.0,
      );
    } catch (e) {
      throw FormatException('Error al convertir UserProfile: $e');
    }
  }
}
