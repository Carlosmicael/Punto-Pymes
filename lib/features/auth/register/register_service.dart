import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio encargado de manejar la lógica de registro.
/// Se comunica con el backend NestJS en el endpoint /auth/register.
class RegisterService {
  final String baseUrl = "http://192.168.1.7:3000";

  /// Envía los datos de registro al backend y devuelve el UID si es exitoso.
  Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    final url = Uri.parse("$baseUrl/auth/register");

    // Mostrar en consola lo que se envía
    print("Enviando datos de registro: $userData");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    // Mostrar en consola la respuesta
    print("Status code: ${response.statusCode}");
    print("Respuesta: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body); // Ej: { "uid": "...", "usuario": "juanp" }
    } else {
      return null;
    }
  }
}
