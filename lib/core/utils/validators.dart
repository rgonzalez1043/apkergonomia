class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Correo electrónico inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.isEmpty) return 'El nombre es requerido';
    if (value.length < 2) return 'Nombre muy corto';
    if (value.length > 50) return 'Nombre muy largo';
    return null;
  }
}
