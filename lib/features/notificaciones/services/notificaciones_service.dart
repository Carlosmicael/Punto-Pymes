import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';

class NotificacionesService {

  /// Obtiene las notificaciones del backend
  Future<List<Map<String, dynamic>>> getNotificaciones(String token) async {
    debugPrint('📡 [NotificacionesService] Iniciando getNotificaciones');
    debugPrint('🔑 Token recibido: ${token.isNotEmpty ? 'OK' : 'VACÍO'}');
    debugPrint('🌐 URL: $notificacionesUrl');

    try {
      final response = await http.get(
        Uri.parse(notificacionesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '📥 Response status: ${response.statusCode}',
      );
      debugPrint(
        '📦 Response body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        debugPrint(
          '✅ Notificaciones recibidas: ${data.length}',
        );

        return List<Map<String, dynamic>>.from(data);
      } else {
        debugPrint(
          '❌ Error HTTP ${response.statusCode}',
        );
        throw Exception(
          'Error al cargar notificaciones: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('🔥 Excepción en getNotificaciones');
      debugPrint('🔥 Error: $e');
      debugPrint('🧵 StackTrace: $stackTrace');

      throw Exception('Error de conexión: $e');
    }
  }
}
