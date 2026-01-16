import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:auth_company/config.dart';

/// Servicio encargado de manejar la lógica de registro.
/// Se comunica con el backend NestJS en el endpoint /users/register.
class RegisterService {
  final String baseUrl = baseUrll;

  /// Verifica si una cédula existe en listausers y su estado
  Future<Map<String, dynamic>?> checkCedula(String cedula) async {
    try {
      final url = Uri.parse("$baseUrl/users/check-list/$cedula");
      print("🔍 Verificando cédula: $cedula");
      
      final response = await http.get(url);
      print("🔍 Status code verificación: ${response.statusCode}");
      print("🔍 Respuesta verificación: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Error al verificar cédula: $e");
      return null;
    }
  }

  /// Envía los datos de registro al backend y devuelve el UID si es exitoso.
  Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse("$baseUrl/users/register");

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
                ? errorBody['message'].join(',')
                : errorBody['message'] ?? 'Error desconocido';

        throw Exception(errorMessage); // Lanza el error para capturarlo en la UI
      }
    } catch (e) {
      print("Error de conexión o lógica: $e");
      rethrow; // Reenvía el error a la pantalla
    }
  }

  /// Envía los datos de registro con imagen usando multipart/form-data
  Future<Map<String, dynamic>?> registerWithImage(
    Map<String, dynamic> userData, 
    File? imageFile
  ) async {
    try {
      final url = Uri.parse("$baseUrl/users/register");
      
      // Crear petición multipart
      final request = http.MultipartRequest('POST', url);
      
      // Agregar headers
      request.headers.addAll({
        "Content-Type": "multipart/form-data",
      });
      
      // Agregar campos de texto
      userData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Agregar archivo de imagen si existe
      if (imageFile != null) {
        print("📸 Imagen a subir: ${imageFile.path}");
        
        // Extraer extensión y determinar contentType
        final String extension = imageFile.path.split('.').last.toLowerCase();
        String subType = 'jpeg';
        if (extension == 'png') subType = 'png';
        if (extension == 'gif') subType = 'gif';
        if (extension == 'webp') subType = 'webp';
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // Campo esperado por backend
            imageFile.path,
            contentType: MediaType('image', subType),
          ),
        );
      }
      
      print("📤 Enviando registro multipart...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("📤 Status code: ${response.statusCode}");
      print("📤 Respuesta: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        String errorMessage = errorBody['message'] ?? 'Error desconocido';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("❌ Error de conexión: $e");
      rethrow;
    }
  }
}
