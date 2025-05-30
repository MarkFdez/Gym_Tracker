/// Clase utilitaria que contiene validadores de formularios para campos comunes.
class Validators {
  /// Valida que el formato del correo electrónico sea correcto.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  /// Verifica que la contraseña tenga al menos 6 caracteres.
  static bool isStrongPassword(String password) {
    return password.length >= 6;
  }

  /// Validador de formulario para correos electrónicos.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Campo obligatorio';
    if (!isValidEmail(value)) return 'Correo inválido';
    return null;
  }

  /// Validador de formulario para contraseñas.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Campo obligatorio';
    if (!isStrongPassword(value)) return 'Mínimo 6 caracteres';
    return null;
  }

  /// Validador para confirmar contraseñas iguales.
  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  /// Valida que un campo obligatorio no esté vacío.
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  /// Validador para edad (debe ser un entero válido y dentro del rango 1–120).
  static String? validateEdad(String? value) {
    final edad = int.tryParse(value ?? '');
    if (edad == null) return 'Edad no válida';
    if (edad <= 0 || edad > 120) return 'Edad fuera de rango';
    return null;
  }

  /// Validador para estatura (debe estar entre 50 y 250 cm).
  static String? validateEstatura(String? value) {
    final estatura = double.tryParse(value ?? '');
    if (estatura == null) return 'Estatura no válida';
    if (estatura < 50 || estatura > 250) return 'Estatura fuera de rango';
    return null;
  }

  /// Validador para peso (debe estar entre 30 y 300 kg).
  static String? validatePeso(String? value) {
    final peso = double.tryParse(value ?? '');
    if (peso == null) return 'Peso no válido';
    if (peso < 30 || peso > 300) return 'Peso fuera de rango';
    return null;
  }

  /// Validador para repeticiones (debe ser mayor a 0).
  static String? validateRepeticiones(String? value) {
    final reps = int.tryParse(value ?? '');
    if (reps == null || reps <= 0) return 'Debe ser mayor a 0';
    return null;
  }

  /// Validador para series (debe ser mayor a 0).
  static String? validateSeries(String? value) {
    final series = int.tryParse(value ?? '');
    if (series == null || series <= 0) return 'Debe ser mayor a 0';
    return null;
  }
}
