import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auth_company/features/auth/login/login_service.dart';
import 'package:auth_company/config.dart';
import 'package:auth_company/features/registro_asistencia/services/attendance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio encargado de manejar la lógica de perfil (Lectura y Actualización).
class UserService {
  // Usa la misma IP de RegisterService
  final String baseUrl = baseUrll;

  // --- 1. Método para obtener datos del perfil (GET) ---
  /// Llama al endpoint GET /users/:uid
  Future<Map<String, dynamic>?> getProfile(String uid, String token) async {
    try {
      final url = Uri.parse("$baseUrl/users/$uid");
      print("➡️ [DEBUG] URL de la petición: $url");
      print("➡️ [DEBUG] Token enviado: $token");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("➡️ [DEBUG] Código de respuesta: ${response.statusCode}");
      print("➡️ [DEBUG] Headers de respuesta: ${response.headers}");
      print("➡️ [DEBUG] Body crudo: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print("✅ [DEBUG] JSON decodificado: $decoded");
        return decoded;
      } else {
        print("❌ [DEBUG] Error al obtener perfil: ${response.statusCode}");
        return null;
      }
    } catch (e, stacktrace) {
      print("⚠️ [DEBUG] Error de conexión al obtener perfil: $e");
      print("⚠️ [DEBUG] Stacktrace: $stacktrace");
      return null;
    }
  }

  // --- 2. Método para actualizar datos del perfil (PATCH) ---
  /// Llama al endpoint PATCH /users/:uid
  Future<bool> updateProfile(
    String uid,
    Map<String, dynamic> userData,
    String token,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/users/$uid");

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(userData),
      );

      // El backend devuelve 200 o 204 si la actualización fue exitosa
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print("Error al actualizar perfil: ${response.statusCode}");
        final errorBody = jsonDecode(response.body);
        print("Detalle: ${errorBody['message']}");
        return false;
      }
    } catch (e) {
      print("Error de conexión al actualizar perfil: $e");
      return false;
    }
  }

  Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<String> _obtenerUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid') ?? '';
  }

  Future<Map<String, dynamic>?> getProfileRegistroManual() async {
    final uid = await _obtenerUid();
    final token = await _obtenerToken();

    if (uid.isEmpty || token.isEmpty) {
      print('DEBUG: UID o Token vacíos. Retornando null.');
      return null;
    }

    try {
      final url = Uri.parse("$baseUrl/users/$uid");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // ✅ La respuesta ahora contiene 'branchName'
        return jsonDecode(response.body);
      } else {
        print("Error al obtener perfil: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error de conexión al obtener perfil: $e");
      return null;
    }
  }

  // --- MÉTODO ESPECÍFICO PARA REGISTRO MANUAL ---
  /// Retorna un mapa con Nombre, Apellido y Sucursal listos para la UI.
  Future<Map<String, String>?> getEmployeeDataForManualRegistration() async {
    final profileData = await getProfileRegistroManual();

    if (profileData != null) {
      return {
        'nombre': profileData['nombre'] as String? ?? 'N/A',
        'apellido': profileData['apellido'] as String? ?? 'N/A',
        // ✅ Campo que trae el nombre de la sucursal del backend
        'sucursal': profileData['branchName'] as String? ?? 'Sin asignar',
      };
    }

    return null;
  }

  Future<Map<String, String>?> getIdsForAttendance() async {
    final uid = await _obtenerUid();
    final token = await _obtenerToken();

    if (uid.isEmpty || token.isEmpty) {
      print('DEBUG: UID o Token vacíos. Retornando null.');
      return null;
    }

    try {
      final url = Uri.parse("$baseUrl/users/$uid");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'companyId': data['empresaId'] as String? ?? '',
          'employeeId': data['uid'] as String? ?? '',
        };
      } else {
        print("Error al obtener perfil: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error de conexión al obtener perfil: $e");
      return null;
    }
  }
}
