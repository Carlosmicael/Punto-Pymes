import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config.dart'; // Importamos serverIp, kpisUrl, etc.

class KpiService {
  // 1. Evaluar automático (Trigger al entrar a la pantalla)
  Future<void> evaluateAutomaticKpi(String companyId, String employeeId) async {
    try {
      final url = Uri.parse('$kpisUrl/evaluate-auto');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'companyId': companyId, 'employeeId': employeeId}),
      );
      // No necesitamos esperar el resultado visualmente, solo que se ejecute
    } catch (e) {
      print("Error evaluando KPI automático: $e");
    }
  }

  // 2. Marcar KPI Manual
  Future<bool> markManualKpi({
    required String kpiId,
    required String nombre,
    required double notaInicial,
    required String companyId,
    required String employeeId,
  }) async {
    try {
      final url = Uri.parse('$kpisUrl/manual');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'kpiId': kpiId,
          'nombre': nombre,
          'notaInicialEmpleado': notaInicial,
          'companyId': companyId,
          'employeeId': employeeId,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error marcando KPI: $e");
      return false;
    }
  }

  // 3. Obtener lista de KPIs pendientes desde el backend
  Future<List<Map<String, dynamic>>> getPendingKpis(
    String companyId,
    String employeeId,
  ) async {
    try {
      final url = Uri.parse(
        '$kpisUrl/pending?companyId=$companyId&employeeId=$employeeId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo KPIs pendientes: $e");
      return [];
    }
  }


  // 4. Obtener lista de KPIs COMPLETADOS (Historial de hoy)
  Future<List<Map<String, dynamic>>> getCompletedKpis(
    String companyId,
    String employeeId,
  ) async {
    try {
      // Asegúrate que esta URL coincida con tu backend
      final url = Uri.parse(
        '$kpisUrl/completed?companyId=$companyId&employeeId=$employeeId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo KPIs completados: $e");
      return [];
    }
  }
}
