import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:auth_company/features/registro_asistencia/services/attendance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistroEmpleados extends StatefulWidget {
  const RegistroEmpleados({super.key});

  @override
  State<RegistroEmpleados> createState() => _RegistroState();
}

class _RegistroState extends State<RegistroEmpleados> {
  bool showGradient = false;
  // Variables para datos
  bool isLoading = true;
  List<Map<String, dynamic>> registrosProcesados = [];
  int totalRegistros = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void toggleGradient(bool value) {
    setState(() => showGradient = value);
  }

  Future<void> _cargarDatos() async {
    final token = await _obtenerToken();
    if (token.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    final rawData = await _attendanceService.getHistory(token);

    // Mapa para agrupar
    Map<String, Map<String, dynamic>> agrupados = {};

    for (var registro in rawData) {
      final fecha = registro['fecha'] as String;
      final tipo = registro['tipo'] as String;
      final horaFull = registro['hora'] as String;

      // Inicializar el día si no existe
      if (!agrupados.containsKey(fecha)) {
        agrupados[fecha] = {
          'fecha': fecha,
          'entrada': '--:--',
          'salida': '--:--',
          'entradaDetail': null, // AQUÍ guardaremos todo el objeto de entrada
          'salidaDetail': null, // AQUÍ guardaremos todo el objeto de salida
        };
      }

      String horaCorta =
          horaFull.length >= 5 ? horaFull.substring(0, 5) : horaFull;

      if (tipo == 'entrada') {
        agrupados[fecha]!['entrada'] = horaCorta;
        agrupados[fecha]!['entradaDetail'] =
            registro; // ¡Guardamos todo el registro!
      } else if (tipo == 'salida') {
        agrupados[fecha]!['salida'] = horaCorta;
        agrupados[fecha]!['salidaDetail'] =
            registro; // ¡Guardamos todo el registro!
      }
    }

    setState(() {
      registrosProcesados = agrupados.values.toList();
      // Ordenar por fecha descendente
      registrosProcesados.sort((a, b) => b['fecha'].compareTo(a['fecha']));
      totalRegistros = rawData.length;
      isLoading = false;
    });
  }

  Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  final AttendanceService _attendanceService = AttendanceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: CustomRegisterAppBar(showGradient: showGradient),
      // Pasamos los datos al Body
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE41335)),
              )
              : RegisterBody(
                onScroll: toggleGradient,
                registros: registrosProcesados,
                total: totalRegistros,
              ),
    );
  }
}

// 🔹 APPBAR SEPARADO
class CustomRegisterAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showGradient;
  final double? heightFactor; // Factor para ajustar la altura según pantalla

  const CustomRegisterAppBar({
    super.key,
    required this.showGradient,
    this.heightFactor = 0.15, // Por defecto 8% de la altura de la pantalla
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height * heightFactor!; // Altura responsiva

    final iconSize = width * 0.05; // Icono responsivo
    final fontSize = width * 0.03; // Texto responsivo
    final topPadding = height * 0.0; // Ajusta este valor según necesites

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
      decoration: BoxDecoration(
        gradient:
            showGradient
                ? const LinearGradient(
                  colors: [Color(0xFF370B12), Color(0xFFE41335)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: topPadding), // Espacio desde arriba
          child: Row(
            children: [
              SvgPicture.asset(
                'lib/assets/images/Registro.svg',
                width: iconSize,
                height: iconSize,
              ),
              SizedBox(width: width * 0.02), // Espacio entre SVG y texto
              Text(
                "Registro",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 BODY SEPARADO
class RegisterBody extends StatelessWidget {
  final void Function(bool) onScroll;
  final List<Map<String, dynamic>> registros; // ✅ Nueva prop
  final int total; // ✅ Nueva prop

  const RegisterBody({
    super.key,
    required this.onScroll,
    required this.registros,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    // ... Variables de tamaño iguales ...
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // ... Dias y numeros (puedes hacerlos dinámicos después) ...
    final dias = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
    final numeros = ['1', '2', '3', '4', '5', '6', '7'];

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        onScroll(scroll.metrics.pixels > 50);
        return true;
      },
      child: SingleChildScrollView(
        key: const PageStorageKey("Register"),
        child: Column(
          children: [
            // 🔸 Cabecera (Gradient)
            ClipPath(
              clipper:
                  _CurvedBottomClipper(), // Asumiendo que esta clase existe abajo en tu archivo
              child: Container(
                width: width,
                height: height * 0.55,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF370B12), Color(0xFFE41335)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: height * 0.13,
                      right: 0,
                      child: SvgPicture.asset(
                        'lib/assets/images/huella2.svg',
                        width: width * 0.45,
                        height: width * 0.45,
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: height * 0.08),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:
                                dias
                                    .map(
                                      (d) => Text(
                                        d,
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          SizedBox(height: height * 0.01),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:
                                numeros
                                    .map(
                                      (n) => Text(
                                        n,
                                        style: TextStyle(
                                          fontSize: width * 0.045,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          SizedBox(height: height * 0.04),
                          Text(
                            'Total de Registros',
                            style: TextStyle(
                              fontSize: width * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.01),
                          // ✅ VALOR DINÁMICO
                          Text(
                            '$total',
                            style: TextStyle(
                              fontSize: width * 0.15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔸 Cuerpo inferior (Lista de Tarjetas)
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.07,
                right: width * 0.07,
                top: height * 0,
                bottom: height * 0.02,
              ),
              child: Column(
                children:
                    registros.isEmpty
                        ? [
                          // Mensaje si no hay registros
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "No hay registros recientes",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ]
                        : registros.map((registro) {
                          final entrada = registro['entrada'];
                          final salida = registro['salida'];
                          final fecha = registro['fecha'];
                          final bool tieneSalida = salida != '--:--';

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: height * 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height * 0.01),
                                // Título dinámico con la fecha
                                Text(
                                  'Fecha: $fecha',
                                  style: TextStyle(
                                    fontSize: width * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: height * 0.02),

                                // TARJETA BLANCA
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(width * 0.04),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromARGB(64, 0, 0, 0),
                                        blurRadius: 20,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // CAJA NEGRA (Horas)
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          vertical: height * 0.018,
                                          horizontal: width * 0.03,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Columna Entrada
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Hora de entrada',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: width * 0.035,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                  Text(
                                                    entrada,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: width * 0.06,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: width * 0.01),
                                            // Columna Salida
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Hora de salida',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: width * 0.035,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                  Text(
                                                    salida,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: width * 0.06,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  'lib/assets/images/Dia.svg',
                                                  width: width * 0.07,
                                                  height: width * 0.07,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: height * 0.02),

                                      // ESTADOS (Registrado / Sin registrar)
                                      Row(
                                        children: [
                                          Text(
                                            'Entrada: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                          Text(
                                            'Registrado',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Row(
                                        children: [
                                          Text(
                                            'Salida: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                          Text(
                                            tieneSalida
                                                ? 'Registrado'
                                                : 'Sin registrar',
                                            style: TextStyle(
                                              color:
                                                  tieneSalida
                                                      ? Colors.green
                                                      : Colors.redAccent,
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // BOTÓN DETALLES (Reemplaza el antiguo botón Registrar)
                                      SizedBox(height: height * 0.03),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          elevation: 8,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.06,
                                            vertical: height * 0.02,
                                          ),
                                        ),
                                        onPressed: () {
                                          // ABRIR MODAL CON DATOS REALES
                                          showGeneralDialog(
                                            context: context,
                                            barrierColor: Colors.transparent,
                                            barrierDismissible:
                                                true, // Permitir cerrar tocando fuera si quieres
                                            barrierLabel: "Detalle",
                                            transitionDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            pageBuilder: (
                                              context,
                                              anim1,
                                              anim2,
                                            ) {
                                              return RegistroModal(
                                                fecha:
                                                    registro['fecha'], // Pasamos fecha
                                                dataEntrada:
                                                    registro['entradaDetail'],
                                                dataSalida:
                                                    registro['salidaDetail'], // Pasamos hora salida
                                              );
                                            },
                                            transitionBuilder: (
                                              context,
                                              anim1,
                                              anim2,
                                              child,
                                            ) {
                                              return Transform.scale(
                                                scale: anim1.value,
                                                child: Opacity(
                                                  opacity: anim1.value,
                                                  child: child,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Ver Detalles', // Cambio de texto
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * 0.04,
                                              ),
                                            ),
                                            SizedBox(width: width * 0.05),
                                            Container(
                                              width: width * 0.07,
                                              height: width * 0.07,
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                  133,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  'lib/assets/images/Siguiente.svg',
                                                  width: width * 0.03,
                                                  height: width * 0.03,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
              ),
            ),
            SizedBox(height: height * 0.12),
          ],
        ),
      ),
    );
  }
}

// 🔹 CLIPPER DEL SEMICÍRCULO
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 120);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 120,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class RegistroModal extends StatelessWidget {
  final String fecha;
  final Map<String, dynamic>? dataEntrada; // Ahora recibimos el objeto completo
  final Map<String, dynamic>? dataSalida;

  const RegistroModal({
    super.key,
    required this.fecha,
    this.dataEntrada,
    this.dataSalida,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Helper para obtener hora segura
    String getHora(Map<String, dynamic>? data) {
      if (data == null) return "--:--";
      String h = data['hora'].toString();
      return h.length >= 5 ? h.substring(0, 5) : h;
    }

    return Stack(
      children: [
        // Fondo Blur
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.12)),
          ),
        ),

        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width * 0.90,
              // Aumentamos un poco el padding vertical si hay mucha info
              constraints: BoxConstraints(maxHeight: height * 0.8),
              padding: EdgeInsets.all(width * 0.05),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [Color(0xFFE81236), Color(0xFF7B1522)],
                    ),
                  ),
                  padding: EdgeInsets.all(width * 0.06),
                  child: SingleChildScrollView(
                    // Scroll por si hay mucha info
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // CABECERA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Detalle: $fecha",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: width * 0.065,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.white.withOpacity(0.4),
                          height: 20,
                        ),

                        // ---------------------------------------------
                        // SECCIÓN ENTRADA
                        // ---------------------------------------------
                        _buildDetailCard(
                          context,
                          title: "ENTRADA",
                          data: dataEntrada,
                          iconPath:
                              "assets/icons/check.svg", // Tu icono de entrada
                        ),

                        SizedBox(height: height * 0.02),

                        // ---------------------------------------------
                        // SECCIÓN SALIDA
                        // ---------------------------------------------
                        _buildDetailCard(
                          context,
                          title: "SALIDA",
                          data: dataSalida,
                          iconPath:
                              "assets/icons/arrow.svg", // Tu icono de salida
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget constructor de la tarjeta de detalle mejorada
  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required Map<String, dynamic>? data,
    required String iconPath,
  }) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    bool existe = data != null;

    // Extraer datos o poner defaults
    String hora = existe ? (data['hora'] as String).substring(0, 5) : "--:--";
    String estado = existe ? (data['estado'] ?? 'N/A') : "Sin registro";
    bool enRango = existe ? (data['dentroDelRango'] ?? false) : false;
    String device = existe ? (data['deviceInfo'] ?? 'N/A') : "-";

    // Color del estado (Ej: Atraso = Rojo/Naranja, Válido = Verde)
    Color statusColor =
        (estado.toLowerCase() == 'atraso')
            ? Colors.orangeAccent
            : Colors.greenAccent;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6), // Fondo semitransparente oscuro
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila Superior: Icono y Hora Grande
          Row(
            children: [
              // Icono circular (Mismo estilo que tenías)
              /*Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(iconPath, color: Colors.white),
              ),*/
              SizedBox(width: width * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    hora,
                    style: TextStyle(
                      color: existe ? Colors.white : Colors.white38,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Chip de Estado (Atraso / Valido)
              if (existe)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          if (existe) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),

            // Detalles extra: Ubicación y Dispositivo
            Row(
              children: [
                // Icono Rango
                Icon(
                  enRango
                      ? Icons.location_on_outlined
                      : Icons.location_off_outlined,
                  color: enRango ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  enRango ? "En oficina" : "Fuera de rango",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.phone_android,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Disp: $device",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Mostrar Lat/Lng discreto si quieres
            const SizedBox(height: 4),
            Text(
              "Lat: ${data['latitud'].toStringAsFixed(4)}, Lng: ${data['longitud'].toStringAsFixed(4)}",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
