import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auth_company/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SucursalService {
  final String baseUrl = sucursalesUrl;

  Future<List<Map<String, dynamic>>> getSucursales() async {
    try {
      final token = await _obtenerToken();
      print("🔑 Token usado en getSucursales: $token");

      if (token.isEmpty) {
        print("⚠️ Token vacío. Debes iniciar sesión primero.");
        return [];
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Status code: ${response.statusCode}");
      print("📦 Raw body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        return decodedData.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        final data = json.decode(response.body);
        print("⚠️ Error: ${data['message']}");
        return [];
      }
    } catch (e) {
      print("❌ Error en getSucursales: $e");
      return [];
    }
  }

  Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }
}
