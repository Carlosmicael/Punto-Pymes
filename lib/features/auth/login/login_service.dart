import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio encargado de manejar la lógica de login.
/// Se comunica con el backend NestJS en el endpoint /auth/login.
class LoginService {
  final String baseUrl = "http://192.168.1.7:3000";

  /// Envía usuario y contraseña al backend y devuelve el token JWT si es válido.
  Future<String?> login(String usuario, String contrasena) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"usuario": usuario, "contrasena": contrasena}),
    );

    // Imprimir la respuesta del backend
    print("Status code: ${response.statusCode}");
    print("Respuesta: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data["access_token"];
      final uid = data["uid"]; 

      // Guardar token y UID en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", token);
      await prefs.setString("user_uid", uid); 

      return token;
    } else {
      print("Error en login: ${response.statusCode}");
      return null;
    }
  }

  /// Recupera el token guardado en SharedPreferences
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  /// Elimina el token (ej. logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
  }

  /// Recupera el UID guardado en SharedPreferences
  Future<String?> getSavedUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_uid");
  }
}
