import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth_company/config.dart';
import 'package:path/path.dart';

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
    print(
      'URL de intento: $_baseUrl/register',
    ); // ✅ Añade esto para verificar la IP
    print('Status code: ${response.statusCode}');
    print('Cuerpo: ${response.body}');
    print('----------------------------');

    // -------------------------------------------------------------
    // ✅ Ejecutar jsonDecode solo si hay cuerpo
    // -------------------------------------------------------------
    if (response.body.isEmpty) {
      // Si el servidor retorna 201 sin contenido, lo tratamos como éxito simple.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': 'Registro exitoso (sin detalles adicionales).',
          'tipo': 'desconocido',
          'hora': 'N/A',
          'estado': 'válido',
        };
      }
      // Si el código es 401/403/500 y está vacío, damos un error genérico.
      throw const FormatException(
        'El servidor devolvió un cuerpo vacío y un código de error.',
      );
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

  /// Metodo para obtener el historial de asistencias
  Future<List<Map<String, dynamic>>> getHistory(token) async {
    final token = await _obtenerToken(); // Obtener token dentro del método

    if (token.isEmpty) {
      print('ALERTA: Token vacío. No se puede obtener historial.');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Token JWT
        },
      );

      print('--- RESPUESTA DEL SERVICIO (HISTORY) ---');
      print('URL de intento: $_baseUrl/history');
      print('Status code: ${response.statusCode}');
      print('----------------------------');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception('Error al cargar historial: ${data['message']}');
      }
    } catch (e) {
      print('Excepción en getHistory: $e');
      return [];
    }
  }

  /// Registro Manual
  Future<Map<String, dynamic>> registrarManual({
    required String fecha,
    required String motivo,
    File? imagen,
  }) async {
    final token = await _obtenerToken();
    if (token.isEmpty) {
      print('DEBUG: [Error] Token vacío en registrarManual');
      return {'success': false, 'message': 'Sin sesión activa'};
    }

    try {
      print('DEBUG: --- Iniciando Registro Manual ---');
      print('DEBUG: Fecha: $fecha');
      print('DEBUG: Motivo: $motivo');

      // 1. Configurar MultipartRequest
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/register-manual'),
      );

      // 2. Headers
      request.headers.addAll({'Authorization': 'Bearer $token'});
      print('DEBUG: Headers configurados (Token presente)');

      // 3. Campos de texto
      request.fields['fecha'] = fecha;
      request.fields['motivo'] = motivo;

      // 4. Adjuntar Imagen con Debug
      if (imagen != null) {
        print('DEBUG: Imagen detectada. Ruta: ${imagen.path}');
        final fileSize = await imagen.length();
        print(
          'DEBUG: Tamaño del archivo: ${(fileSize / 1024).toStringAsFixed(2)} KB',
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // Cambiado a 'file' para que coincida con lo habitual en NestJS
            imagen.path,
            filename: basename(imagen.path),
          ),
        );
        print('DEBUG: Archivo adjuntado al request exitosamente');
      } else {
        print('DEBUG: No se seleccionó ninguna imagen.');
      }

      // 5. Enviar petición
      print('DEBUG: Enviando petición a: $_baseUrl/register-manual...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      // 6. Procesar respuesta
      final response = await http.Response.fromStream(streamedResponse);

      print('DEBUG: --- RESPUESTA DEL SERVIDOR ---');
      print('DEBUG: Status Code: ${response.statusCode}');
      print('DEBUG: Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: Registro exitoso: ${data['message']}');
        return {
          'success': true,
          'tipo': data['tipo'],
          'message': data['message'],
        };
      } else {
        print('DEBUG: Error devuelto por el servidor');
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al registrar',
        };
      }
    } catch (e) {
      print('DEBUG: [Excepción] Error de conexión o proceso: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> registrarAsistenciaHuella({
    required String companyId,
    required String employeeId,
    String? deviceId,
  }) async {
    final token = await _obtenerToken();
    final response = await http.post(
      Uri.parse('$attendanceUrl/register-biometric'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'companyId': companyId,
        'employeeId': employeeId,
        'deviceId': deviceId ?? 'flutter-app',
      }),
    );
    return jsonDecode(response.body);
  }

  Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }
}
