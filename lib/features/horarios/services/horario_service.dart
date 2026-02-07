import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config.dart';
// Donde tengas tu BASE_URL

class HorarioService {
  final String baseUrl = baseUrll;

  Future<Map<String, dynamic>> fetchHorarios(
    String empresaId,
    String uid,
  ) async {
    final response = await http.get(
      Uri.parse('$horariosUrl?companyId=$empresaId&employeeId=$uid'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error servidor: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> getProfile(String uid, String token) async {
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
}
