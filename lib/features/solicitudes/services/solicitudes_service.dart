import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth_company/config.dart';
import 'package:file_picker/file_picker.dart';

class SolicitudesService {
  final String _baseUrl = "$baseUrll/solicitudes";

  // ============================
  // Helpers privados (auth)
  // ============================
  Future<String> _getToken() async {
    print("[DEBUG] _getToken -> obteniendo token desde SharedPreferences...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    print(
      "[DEBUG] _getToken -> token obtenido: ${token.isNotEmpty ? 'OK' : 'VACÍO'}",
    );
    return token;
  }

  // ============================
  // GET: Obtener solicitudes
  // ============================
  Future<List<Map<String, dynamic>>> getSolicitudes() async {
    print("[DEBUG] getSolicitudes -> iniciando petición GET a $_baseUrl");
    final token = await _getToken();

    if (token.isEmpty) {
      print("[ERROR] getSolicitudes -> token no encontrado");
      throw Exception("Token no encontrado");
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("[DEBUG] getSolicitudes -> statusCode: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      print("[DEBUG] getSolicitudes -> solicitudes recibidas: ${body.length}");
      return body.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print(
        "[ERROR] getSolicitudes -> fallo con código ${response.statusCode}, body: ${response.body}",
      );
      throw Exception("Error al obtener solicitudes (${response.statusCode})");
    }
  }

  // ============================
  // POST: Crear solicitud (MULTIPART)
  // ============================
  Future<void> createSolicitud({
    required String tipoSolicitud,
    required String fechaInicio,
    required String fechaFin,
    required String motivo,
    List<PlatformFile>? adjuntos,
  }) async {
    print("[DEBUG] createSolicitud -> iniciando POST MULTIPART a $_baseUrl");

    final token = await _getToken();

    if (token.isEmpty) {
      print("[ERROR] createSolicitud -> token no encontrado");
      throw Exception("Token no encontrado");
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      /// Headers (NO setear Content-Type)
      request.headers['Authorization'] = 'Bearer $token';

      /// Fields (Body)
      request.fields['tipoSolicitud'] = tipoSolicitud;
      request.fields['fechaInicio'] = fechaInicio;
      request.fields['fechaFin'] = fechaFin;
      request.fields['motivo'] = motivo;

      print("[DEBUG] createSolicitud -> fields agregados");

      /// Archivos adjuntos
      if (adjuntos != null && adjuntos.isNotEmpty) {
        print(
          "[DEBUG] createSolicitud -> adjuntos a subir: ${adjuntos.length}",
        );

        for (final file in adjuntos) {
          if (file.path == null) continue;

          print("[DEBUG] createSolicitud -> adjuntando archivo: ${file.name}");

          request.files.add(
            await http.MultipartFile.fromPath(
              'adjuntos',
              file.path!,
              filename: file.name,
            ),
          );
        }
      }

      /// Enviar request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("[DEBUG] createSolicitud -> statusCode: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("[DEBUG] createSolicitud -> solicitud creada correctamente");
      } else {
        print(
          "[ERROR] createSolicitud -> fallo (${response.statusCode}): ${response.body}",
        );
        throw Exception("Error al crear solicitud (${response.statusCode})");
      }
    } catch (e) {
      print("[ERROR] createSolicitud -> excepción: $e");
      rethrow;
    }
  }

  // Metodo Borrar Solicitud con debug prints
  Future<void> deleteSolicitud(String solicitudId) async {
    print("🔹 Iniciando eliminación de solicitud con ID: $solicitudId");

    final token = await _getToken();
    print("🔹 Token obtenido: $token");

    final url = Uri.parse("$_baseUrl/$solicitudId");
    print("🔹 URL construida: $url");

    try {
      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("🔹 Código de respuesta: ${response.statusCode}");
      print("🔹 Cuerpo de respuesta: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        print(
          "❌ Error al eliminar la solicitud. Código: ${response.statusCode}",
        );
        throw Exception("No se pudo eliminar la solicitud");
      } else {
        print("✅ Solicitud eliminada correctamente");
      }
    } catch (e) {
      print("❌ Excepción atrapada: $e");
      rethrow; // vuelve a lanzar la excepción para manejarla fuera
    }
  }
}
