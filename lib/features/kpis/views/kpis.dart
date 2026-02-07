import 'dart:async';
import 'package:auth_company/features/kpis/services/kpi_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class KpisScreen extends StatefulWidget {
  // Estos datos deberían venir del login/provider
  final String companyId;
  final String employeeId;

  // Constructor actualizado para recibir IDs
  const KpisScreen({
    super.key,
    required this.companyId,
    required this.employeeId,
  });

  @override
  State<KpisScreen> createState() => _KpisScreenState();
}

class _KpisScreenState extends State<KpisScreen> {
  final KpiService _kpiService = KpiService();
  // Lista de tareas (Ahora se llenará desde el backend)
  List<Map<String, dynamic>> tareas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 1. Al iniciar, evaluamos KPI automático y cargamos manuales
    _initKpiProcess();
  }

  Future<void> _initKpiProcess() async {
    // A. Disparar evaluación automática (silencioso)
    _evaluateAutomaticKpi();

    // B. Cargar lista de tareas pendientes
    await _fetchAllDailyKpis();
  }

  // --- SERVICIOS HTTP INTEGRADOS ---

  Future<void> _evaluateAutomaticKpi() async {
    await _kpiService.evaluateAutomaticKpi(widget.companyId, widget.employeeId);
  }

  Future<void> _fetchAllDailyKpis() async {
    setState(() => isLoading = true);
    DateFormat inputFormat = DateFormat("dd/MM/yyyy, h:mm:ss a");

    try {
      // Hacemos las dos peticiones en paralelo para mayor velocidad
      final results = await Future.wait([
        _kpiService.getPendingKpis(widget.companyId, widget.employeeId),
        _kpiService.getCompletedKpis(widget.companyId, widget.employeeId),
      ]);

      debugPrint("DEBUG: Pendientes recibidos: ${results[0].length}");
      debugPrint("DEBUG: Completados recibidos: ${results[1].length}");
      if (results[1].isNotEmpty) {
        debugPrint("DEBUG: Primer completado ID: ${results[1][0]['id']}");
      }

      final pendientes = results[0];
      final completadas = results[1];

      debugPrint("DEBUG FULL DATA: $completadas");

      List<Map<String, dynamic>> listaUnificada = [];

      // A. Procesar Pendientes
      listaUnificada.addAll(
        pendientes.map((item) {
          DateTime fechaParseada;
          try {
            // Los pendientes suelen venir en formato ISO: 2025-12-31...
            fechaParseada = DateTime.parse(item["fecha"]).toLocal();
          } catch (e) {
            fechaParseada = DateTime.now();
          }

          return {
            "id": item["id"],
            "titulo": item["nombre"],
            "categoria": item["categoria"] ?? "General",
            "fecha": fechaParseada,
            "isCompleted": false,
          };
        }),
      );

      // B. Procesar Completadas
      listaUnificada.addAll(
        completadas.map((item) {
          DateTime fechaParseada;
          try {
            // Intentar formato humano: 30/12/2025, 9:09:49 p. m.
            String rawFecha = item["fecha"]
                .replaceAll('p. m.', 'PM')
                .replaceAll('a. m.', 'AM')
                .replaceAll('p.m.', 'PM')
                .replaceAll('a.m.', 'AM');

            fechaParseada = DateFormat("dd/MM/yyyy, h:mm:ss a").parse(rawFecha);
          } catch (e) {
            // Si falla, intentar como ISO por si acaso
            try {
              fechaParseada = DateTime.parse(item["fecha"]).toLocal();
            } catch (e2) {
              fechaParseada = DateTime.now();
            }
          }

          return {
            "id": item["id"],
            "titulo": item["nombre"],
            "categoria": item["categoria"] ?? "Finalizado",
            "fecha": fechaParseada,
            "isCompleted": true,
          };
        }),
      );

      setState(() {
        tareas = listaUnificada;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error cargando KPIs: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _markKpiAsDone(Map<String, dynamic> tarea) async {
    debugPrint(
      "DEBUG: Intentando marcar KPI: ${tarea['titulo']} con ID: ${tarea['id']}",
    );

    final success = await _kpiService.markManualKpi(
      kpiId: tarea['id'],
      nombre: tarea['titulo'],
      notaInicial: 10.0, // O el valor que desees
      companyId: widget.companyId,
      employeeId: widget.employeeId,
    );

    if (success) {
      debugPrint("DEBUG: Éxito al marcar KPI en el servidor.");
    } else {
      debugPrint("DEBUG: Fallo al marcar KPI.");
    }
  }

  // --- UI ORIGINAL (CON PEQUEÑOS AJUSTES) ---

  // 🔹 Formateo manual en español
  String _formatFecha(DateTime f) {
    const dias = ["lun", "mar", "mié", "jue", "vie", "sáb", "dom"];
    const meses = [
      "ene",
      "feb",
      "mar",
      "abr",
      "may",
      "jun",
      "jul",
      "ago",
      "sep",
      "oct",
      "nov",
      "dic",
    ];
    return "${dias[f.weekday - 1]}, ${f.day} ${meses[f.month - 1]} ${f.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          tareas.sort((a, b) {
            bool aDone = a["isCompleted"] == true;
            bool bDone = b["isCompleted"] == true;
            if (aDone == bDone) return 0;
            return aDone ? 1 : -1;
          });

          // 🔹 Agrupar tareas por fecha
          Map<String, List<Map<String, dynamic>>> tareasPorFecha = {};
          for (var t in tareas) {
            String clave = DateFormat("yyyy-MM-dd").format(t["fecha"]);
            tareasPorFecha.putIfAbsent(clave, () => []);
            tareasPorFecha[clave]!.add(t);
          }
          List<String> fechasOrdenadas =
              tareasPorFecha.keys.toList()..sort((a, b) => a.compareTo(b));

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE81236), Color(0xFFEB4335)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.12),

                // Cabecera Vacaciones (Estática según tu diseño)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                  child: Row(
                    children: [
                      // Nota: Asegúrate de tener el asset o usa un Icon temporal si falla
                      SvgPicture.asset(
                        "lib/assets/images/Homework.svg",
                        width: width * 0.05,
                        height: width * 0.05,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      SizedBox(width: width * 0.02),
                      Text(
                        "KPIs Diarios", // Cambié el texto para contexto
                        style: TextStyle(
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.07),

                // 🔹 CONTENEDOR OSCURO
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(width * 0.07),
                    decoration: const BoxDecoration(
                      color: Color(0xFF111918),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(150, 0, 0, 0),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child:
                        isLoading
                            ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            )
                            : tareas.isEmpty
                            ? Center(
                              child: Text(
                                "¡Todo listo por hoy!",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                            : ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                for (String fechaString in fechasOrdenadas) ...[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: height * 0.015,
                                    ),
                                    child: Text(
                                      _esHoy(
                                            tareasPorFecha[fechaString]!
                                                .first["fecha"],
                                          )
                                          ? "Hoy"
                                          : _formatFecha(
                                            tareasPorFecha[fechaString]!
                                                .first["fecha"],
                                          ),
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ...tareasPorFecha[fechaString]!
                                      .map(
                                        (tarea) =>
                                            _cardTarea(tarea, width, height),
                                      )
                                      ,
                                  SizedBox(height: height * 0.03),
                                ],
                                SizedBox(height: height * 0.07),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 🔹 CARD DE TAREA (Con lógica de marcado)
  // ============================================================
  Widget _cardTarea(Map<String, dynamic> tarea, double width, double height) {
    final DateTime fecha = tarea["fecha"];
    final bool isCompleted = tarea["isCompleted"] == true;

    return StatefulBuilder(
      builder: (context, setStateSB) {
        return AnimatedOpacity(
          // NUEVO: Reduce opacidad si está completada para dar efecto "deshabilitado"
          duration: const Duration(milliseconds: 500),
          opacity: isCompleted ? 0.5 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(bottom: height * 0.015),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.03,
              vertical: height * 0.02,
            ),
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? const Color.fromARGB(90, 255, 255, 255)
                      : const Color(0xFF303030),
              borderRadius: BorderRadius.circular(width * 0.05),
              boxShadow: [
                BoxShadow(
                  color:
                      isCompleted
                          ? Colors.white.withOpacity(0.4)
                          : Colors.black.withOpacity(0.25),
                  blurRadius: isCompleted ? width * 0.045 : width * 0.03,
                  offset: Offset(0, height * 0.005),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============= CHECKBOX =============
                GestureDetector(
                  onTap:
                      isCompleted
                          ? null // <--- PASO 1: Si ya está completada, el tap es nulo (bloqueado)
                          : () {
                            setStateSB(() {
                              // Esto es solo para disparar la animación interna del checkbox
                              // antes de que el padre reconstruya la lista.
                            });

                            // Llamada al Backend
                            _markKpiAsDone(tarea);

                            Future.delayed(const Duration(milliseconds: 400), () {
                              if (mounted) {
                                setState(() {
                                  // MARCADO COMO COMPLETADO EN LA LISTA PRINCIPAL
                                  tarea["isCompleted"] = true;
                                  // Al hacer setState, el build() correrá de nuevo y
                                  // el sort() moverá esta tarea al final.
                                });
                              }
                            });
                          },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: width * 0.08,
                    height: width * 0.08,
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? const Color.fromARGB(255, 252, 171, 171)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(width * 0.018),
                      border: Border.all(
                        color: Colors.white,
                        width: width * 0.006,
                      ),
                      boxShadow:
                          isCompleted
                              ? [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    143,
                                    176,
                                  ).withOpacity(0.8),
                                  blurRadius: width * 0.035,
                                  spreadRadius: width * 0.008,
                                ),
                              ]
                              : [],
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isCompleted ? 1 : 0,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: isCompleted ? 1 : 0.6,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: width * 0.045,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.045),
                // ================= TEXTOS =================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarea["titulo"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w700,
                          // Opcional: tachado si está completo
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: height * 0.006),
                      Text(
                        "${_formatFecha(fecha)}  ${DateFormat("HH:mm").format(fecha)}",
                        style: TextStyle(
                          color: const Color(0xFFFF9BA9),
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: height * 0.006),
                      Text(
                        tarea["categoria"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _esHoy(DateTime fecha) {
    final hoy = DateTime.now();
    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }
}
