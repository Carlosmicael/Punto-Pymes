import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio encargado de manejar la lógica de perfil (Lectura y Actualización).
class UserService {
  // Usa la misma IP de RegisterService
  final String baseUrl = "http://192.168.1.7:3000"; 

  // --- 1. Método para obtener datos del perfil (GET) ---
  /// Llama al endpoint GET /users/:uid
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final url = Uri.parse("$baseUrl/users/$uid");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Manejo básico de error si el usuario no existe o hay un problema
        print("Error al obtener perfil: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error de conexión al obtener perfil: $e");
      return null;
    }
  }

  // --- 2. Método para actualizar datos del perfil (PATCH) ---
  /// Llama al endpoint PATCH /users/:uid
  Future<bool> updateProfile(String uid, Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse("$baseUrl/users/$uid");

      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
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
}