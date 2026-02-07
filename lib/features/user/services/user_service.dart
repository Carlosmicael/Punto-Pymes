import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Agrega esto
import 'package:auth_company/config.dart';
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

  // --- 2. Método para actualizar datos del perfil (PATCH con multipart/form-data) ---
  /// Llama al endpoint PATCH /users/:uid con soporte para imagen
  Future<bool> updateProfile(
    String uid,
    Map<String, String> fields,
    String token, {
    File? imageFile,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/users/$uid");
      print("➡️ [DEBUG] URL de la petición: $url");
      print("➡️ [DEBUG] Token enviado: $token");
      print("➡️ [DEBUG] Campos a enviar: $fields");
      if (imageFile != null) {
        print("➡️ [DEBUG] Imagen a subir: ${imageFile.path}");
      }

      // Crear la petición multipart
      final request = http.MultipartRequest('PATCH', url);

      // Agregar headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // Agregar campos de texto
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Agregar archivo de imagen si existe
      if (imageFile != null) {
        print("➡️ [DEBUG] Imagen a subir: ${imageFile.path}");
        
        // 1. Extraer la extensión del archivo
        final String extension = imageFile.path.split('.').last.toLowerCase();
        
        // 2. Determinar el tipo de contenido (MimeType)
        String subType = 'jpeg'; // por defecto
        if (extension == 'png') subType = 'png';
        if (extension == 'gif') subType = 'gif';
        if (extension == 'webp') subType = 'webp';

        // 3. Crear el MultipartFile especificando explícitamente el contentType
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // Debe coincidir con @UseInterceptors(FileInterceptor('file'))
            imageFile.path,
            contentType: MediaType('image', subType), // ESTA ES LA CLAVE
          ),
        );
      }

      print("➡️ [DEBUG] Enviando petición PATCH multipart...");
      
      // 1. Envías la petición y obtienes el StreamedResponse
      final streamedResponse = await request.send();

      // 2. ¡AQUÍ ESTÁ LA SOLUCIÓN!
      // Convertimos el StreamedResponse a un Response normal para poder leer el body
      final response = await http.Response.fromStream(streamedResponse);

      // 3. Ahora ya puedes usar response.body y response.statusCode sin errores
      print("➡️ [DEBUG] Código de respuesta: ${response.statusCode}");
      print("➡️ [DEBUG] Headers de respuesta: ${response.headers}");
      print("➡️ [DEBUG] Body crudo: ${response.body}"); // ¡Ahora sí funciona!

      // El backend devuelve 200 o 201 si la actualización fue exitosa
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ [DEBUG] Perfil actualizado exitosamente");
        return true;
      } else {
        print("❌ [DEBUG] Error al actualizar perfil: ${response.statusCode}");
        
        try {
           final errorBody = jsonDecode(response.body);
           print("❌ [DEBUG] Detalle del error: ${errorBody['message']}");
        } catch (_) {
           print("❌ [DEBUG] No se pudo decodificar el error JSON");
        }
        return false;
      }
    } catch (e, stacktrace) {
      print("⚠️ [DEBUG] Error de conexión al actualizar perfil: $e");
      print("⚠️ [DEBUG] Stacktrace: $stacktrace");
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
