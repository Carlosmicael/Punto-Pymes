import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/horario_service.dart';
import 'package:auth_company/features/registro_asistencia/services/attendance_service.dart';

class Horario extends StatefulWidget {
  const Horario({super.key});

  @override
  State<Horario> createState() => HorarioS();
}

class HorarioS extends State<Horario> {
  // Servicio
  final HorarioService _horarioService = HorarioService();
  final AttendanceService _attendanceService = AttendanceService();

  // Variables de Estado (Donde se guarda la data de Firebase)
  bool isLoading = true;
  String nombreEmpleado = "Cargando...";

  // Data de la Jornada (Entrada, Salida, Tolerancia)
  Map<String, dynamic>? jornadaConfig;

  // Data del Historial (Lista de abajo)
  List<dynamic> registrosDinamicos = [];

  // Etiquetas para los días (0 = Lunes en tu array de Firebase)
  final List<String> etiquetasDias = ["D","L", "M", "Mi", "J", "V", "S"];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // --- LÓGICA PARA CARGAR DESDE FIREBASE ---
  Future<void> _cargarDatos() async {
    try {
      const String empresaId = "qmAKafnmTWLxVqxfom4g";
      const String uid = "ncaJivRc0NSnMw5Gcdy7";

      // 1. Cargamos la configuración de jornada (lo que ya tenías)
      final dataHorario = await _horarioService.fetchHorarios(empresaId, uid);

      // 2. Cargamos el historial real desde tu AttendanceService
      final historialRaw = await _attendanceService.getHistory(
        null,
      ); // El token lo obtiene interno

      if (mounted) {
        setState(() {
          nombreEmpleado = "Juan";
          jornadaConfig = dataHorario['configuracion'];

          // 3. Mapeamos los documentos de la colección 'attendance'
          registrosDinamicos =
              historialRaw.map((res) {
                return {
                  "fecha": res['fecha'] ?? "--/--",
                  "horasLaboradas":
                      res['estado']?.toUpperCase() ?? "REGISTRADO",
                  "horaEntrada":
                      res['tipo'] == 'entrada' ? res['hora'] : "--:--",
                  "horaSalida": res['tipo'] == 'salida' ? res['hora'] : "--:--",
                  // Lógica de iconos: si es entrada usa el sol, si es salida usa la luna
                  "svgPath":
                      res['tipo'] == 'entrada'
                          ? "lib/assets/images/Dia.svg"
                          : "lib/assets/images/Noche.svg",
                  "tipo": res['tipo'],
                };
              }).toList();

          isLoading = false;
        });
      }
    } catch (e) {
      print("ERROR: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final sidePadding = w * 0.06;
    final topPadding = h * 0.06;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE41335)),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          SizedBox.expand(
            child: Image.asset(
              'lib/assets/images/fondo.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
              child: Container(color: const Color.fromARGB(97, 0, 0, 0)),
            ),
          ),

          // Contenido
          SafeArea(
            child: SingleChildScrollView(
              key: const PageStorageKey("Horario"),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sidePadding,
                  vertical: topPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    Row(
                      children: [
                        SvgPicture.asset(
                          'lib/assets/images/Horario.svg',
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Horario",
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            letterSpacing: 5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Saludo y Título
                    Text(
                      "Hola, $nombreEmpleado",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Esta es tu jornada activa:",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const SizedBox(height: 20),

                    // --- TARJETA DE JORNADA ACTIVA (Desde Firebase) ---
                    _buildJornadaCard(),

                    const SizedBox(height: 25),

                    // --- DÍAS LABORALES (Desde Firebase) ---
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(etiquetasDias.length, (
                            index,
                          ) {
                            // Verificamos si este día (0,1,2...) está en el array 'dias' de Firebase
                            List<dynamic> diasLaborales =
                                jornadaConfig?['dias'] ?? [];
                            bool esLaboral = diasLaborales.contains(index);

                            return _buildDiaCircle(
                              w,
                              etiquetasDias[index],
                              esLaboral,
                            );
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Título Historial
                    const Text(
                      "Historial Reciente",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- LISTA DE HISTORIAL (Desde Firebase) ---
                    registrosDinamicos.isEmpty
                        ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "No hay registros recientes.",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                        : Column(
                          children:
                              registrosDinamicos.map((registro) {
                                return _buildRegistroItem(registro, w);
                              }).toList(),
                        ),

                    SizedBox(height: h * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Tarjeta de Jornada (Entrada, Salida, Tolerancia)
  Widget _buildJornadaCard() {
    // Valores por defecto si falla la carga
    String entrada = jornadaConfig?['horaEntrada'] ?? "--:--";
    String salida = jornadaConfig?['horaSalida'] ?? "--:--";
    int tolerancia = jornadaConfig?['tolerancia'] ?? 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoColumn("Entrada", entrada, Icons.login),
              Container(width: 1, height: 40, color: Colors.white24),
              _infoColumn("Salida", salida, Icons.logout),
              Container(width: 1, height: 40, color: Colors.white24),
              _infoColumn("Tolerancia", "$tolerancia min", Icons.timer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE41335), size: 22),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  // Widget: Círculo de día
  Widget _buildDiaCircle(double w, String diaLetra, bool esActivo) {
    return Container(
      width: w * 0.1,
      height: w * 0.1,
      margin: EdgeInsets.symmetric(horizontal: w * 0.01),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradiente ROJO si es activo, transparente si no
        gradient:
            esActivo
                ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE41335), Color(0xFF370B12)],
                )
                : null,
        color: esActivo ? null : Colors.white.withOpacity(0.05),
      ),
      alignment: Alignment.center,
      child: Text(
        diaLetra,
        style: TextStyle(
          color: esActivo ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: w * 0.04,
        ),
      ),
    );
  }

  // Widget: Item de Historial
  Widget _buildRegistroItem(Map<String, dynamic> registro, double w) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // --- PARTE SUPERIOR (FECHA Y ESTADO) ---
                // Esto se mantiene SIEMPRE visible
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      registro["fecha"],
                      style: TextStyle(
                        color: const Color.fromRGBO(237, 108, 126, 1),
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      registro["horasLaboradas"], // Aquí sale "Atraso", "Válido", etc.
                      style: TextStyle(color: Colors.white, fontSize: w * 0.04),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),

                // --- PARTE INFERIOR (HORAS DINÁMICAS) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Si el documento es de entrada, mostramos solo la columna de entrada
                    if (registro["tipo"] == 'entrada')
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Entrada:",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              registro["horaEntrada"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Si el documento es de salida, mostramos solo la columna de salida
                    if (registro["tipo"] == 'salida')
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Salida:",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              registro["horaSalida"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // El icono SVG (Sol o Luna) siempre a la derecha
                    SvgPicture.asset(registro["svgPath"], height: 25),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
