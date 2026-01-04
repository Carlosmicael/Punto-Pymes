import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auth_company/routes/app_routes.dart';
import 'package:intl/intl.dart';
import '../services/solicitudes_service.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  final SolicitudesService _service = SolicitudesService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFE81236), Color(0xFF370B12)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.list_alt, color: Colors.white),
            label: const Text("Detalle", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.solicitudes2);
            },
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFE81236), Color(0xFF370B12)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 🔺 HEADER SUPERIOR
            Positioned(
              top: height * 0.07,
              left: 50,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'lib/assets/images/Calendar.svg',
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Solicitudes",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          letterSpacing: 5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    'lib/assets/images/TalentTrack.svg',
                    height: 150,
                  ),
                ],
              ),
            ),

            /// 🔹 CUADRO BLANCO INFERIOR
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height * 0.70,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, -4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _service.getSolicitudes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "No hay solicitudes recientes",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    final solicitudes = snapshot.data!;
                    final visibles =
                        solicitudes.length > 5
                            ? solicitudes.sublist(0, 5)
                            : solicitudes;

                    return SingleChildScrollView(
                      key: const PageStorageKey("Calendario"),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tus 5 Solicitudes mas Recientes:",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: visibles.length,
                              itemBuilder: (context, index) {
                                final item = visibles[index];
                                final bool isLast =
                                    index == visibles.length - 1;

                                String fechaShow = '';

                                final fechaRaw = item['fechaCreacion'];

                                if (fechaRaw != null) {
                                  DateTime fecha;

                                  if (fechaRaw is Map) {
                                    // Firebase Timestamp
                                    final seconds = fechaRaw['_seconds'] as int;
                                    fecha = DateTime.fromMillisecondsSinceEpoch(
                                      seconds * 1000,
                                    );
                                  } else if (fechaRaw is String) {
                                    // ISO String
                                    fecha = DateTime.parse(fechaRaw);
                                  } else {
                                    fecha = DateTime.now();
                                  }

                                  fechaShow = DateFormat(
                                    'd MMM HH:mm',
                                    'es',
                                  ).format(fecha);
                                }

                                Color estadoColor;
                                switch (item['estado']) {
                                  case 'Aprobado':
                                    estadoColor = Colors.green;
                                    break;
                                  case 'Rechazado':
                                    estadoColor = Colors.red;
                                    break;
                                  default:
                                    estadoColor = Colors.orange;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.solicitudes2,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        if (!isLast)
                                          Positioned(
                                            left: 12,
                                            top: 25,
                                            bottom: -25,
                                            child: CustomPaint(
                                              painter: DashedLinePainter(),
                                            ),
                                          ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 25,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: estadoColor,
                                              ),
                                            ),
                                            const SizedBox(width: 20),

                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 18,
                                                    ),
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(30),
                                                      ),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                    colors: [
                                                      Color(0xFFE81236),
                                                      Color(0xFF370B12),
                                                    ],
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item['tipoSolicitud'] ??
                                                          'Solicitud',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Fecha: $fechaShow",
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: size.height * 0.14),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Línea discontinua vertical
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashHeight = 7;
    const double dashSpace = 5;
    double startY = 0;

    final paint =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
