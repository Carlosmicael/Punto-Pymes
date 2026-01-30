/// Valores predeterminados para campos faltantes en el registro
class DefaultValues {
  // --- DATOS PERSONALES ---
  static const String nombre = 'Sin nombre';
  static const String apellido = 'Sin apellido';
  static const String correo = 'sin.correo@ejemplo.com';
  static const String telefono = '0000000000';
  static const String genero = 'masculino';
  static const String cargo = 'Empleado';
  
  // --- EMPRESA/SUCURSAL ---
  static const String empresaNombre = 'Empresa no asignada';
  static const String sucursalNombre = 'Sucursal no asignada';
  static const String empresaId = '';
  static const String branchId = '';
  static const String managerId = '';
  
  // --- COORDENADAS POR DEFECTO (Ecuador) ---
  static const double latitudDefecto = -0.180653;  // Centro de Ecuador
  static const double longitudDefecto = -78.467838; // Centro de Ecuador
  
  // --- ESTADOS ---
  static const String estadoRegistro = 'pendiente';
  static const String uid = '';
  
  // --- FECHAS ---
  static DateTime get fechaNacimientoDefecto => DateTime(1990, 1, 1);
  
  // --- MÉTODO AUXILIAR PARA OBTENER VALOR SEGURO ---
  static T getValue<T>(Map<String, dynamic>? data, String key, T defaultValue) {
    if (data == null) return defaultValue;
    
    final value = data[key];
    if (value == null) return defaultValue;
    
    // Para strings: verificar si está vacío
    if (value is String && (value).trim().isEmpty) {
      return defaultValue;
    }
    
    return value;
  }
}
