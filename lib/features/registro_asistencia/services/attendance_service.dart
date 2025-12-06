import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth_company/config.dart';

class AttendanceService {
  // Ajusta la IP a la de tu servidor (usa tu IP local si estás en emulador: 10.0.2.2)
  final String _baseUrl = attendanceUrl;

  /// Envía la ubicación al backend para registrar entrada/salida
  Future<Map<String, dynamic>> registrarAsistencia(
    double lat,
    double lng,
  ) async {
    final token = await _obtenerToken();

    print('Token enviado: $token');
    if (token.isEmpty) {
      print('ALERTA: Token vacío. Asegúrate de iniciar sesión primero.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'lat': lat, 'lng': lng}),
    );

    // Imprimir el código de estado y el cuerpo de la respuesta
    print('--- RESPUESTA DEL SERVICIO ---');
    print('URL de intento: $_baseUrl/register'); // ✅ Añade esto para verificar la IP
    print('Status code: ${response.statusCode}');
    print('Cuerpo: ${response.body}');
    print('----------------------------');

    // -------------------------------------------------------------
    // ✅ Ejecutar jsonDecode solo si hay cuerpo
    // -------------------------------------------------------------
    if (response.body.isEmpty) {
      // Si el servidor retorna 201 sin contenido, lo tratamos como éxito simple.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Registro exitoso (sin detalles adicionales).', 'tipo': 'desconocido', 'hora': 'N/A', 'estado': 'válido'};
      }
      // Si el código es 401/403/500 y está vacío, damos un error genérico.
      throw const FormatException('El servidor devolvió un cuerpo vacío y un código de error.');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Manejo de Respuesta Exitosa
      return {
        'success': true,
        'tipo': data['tipo'], // 'entrada' o 'salida'
        'hora': data['hora'], // hora del registro
        'estado': data['estado'], // 'válido', 'atraso', 'salida anticipada'
        'message': 'Registro de ${data['tipo']} exitoso',
      };
    } else {
      // Manejo de Errores (4xx, 5xx)
      // data contendrá { statusCode, message, error } de NestJS/Exceptions
      return {
        'success': false,
        'message':
            data['message'] ??
            'Error desconocido en el servidor.', // Captura el mensaje de la excepción (ej. "Fuera de rango")
        'errorType': data['error'] ?? 'Error de Servidor',
      };
    }
  }

  /// (Opcional) Obtener historial para la pantalla 'register.dart'
  Future<List<dynamic>> obtenerHistorial() async {
    final token = await _obtenerToken();
    // Asumiendo que crearás un endpoint GET en NestJS
    final response = await http.get(
      Uri.parse('$_baseUrl/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }
}
