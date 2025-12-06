import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auth_company/config.dart';

/// Servicio encargado de manejar la lógica de registro.
/// Se comunica con el backend NestJS en el endpoint /auth/register.
class RegisterService {
  final String baseUrl = baseUrll;

  /// Envía los datos de registro al backend y devuelve el UID si es exitoso.
  Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
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
        return jsonDecode(response.body);
      } else {
        // Intenta leer el mensaje de error del backend
        final errorBody = jsonDecode(response.body);
        String errorMessage =
            errorBody['message'] is List
                ? errorBody['message'].join(
                  ', ',
                ) // NestJS a veces devuelve array de errores
                : errorBody['message'] ?? 'Error desconocido';

        throw Exception(
          errorMessage,
        ); // Lanza el error para capturarlo en la UI
      }
    } catch (e) {
      print("Error de conexión o lógica: $e");
      rethrow; // Reenvía el error a la pantalla
    }
  }
}
