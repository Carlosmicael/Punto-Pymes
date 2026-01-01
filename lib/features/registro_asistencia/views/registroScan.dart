import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:auth_company/features/registro_asistencia/services/attendance_service.dart';
import 'package:auth_company/features/user/services/user_service.dart';
import 'package:auth_company/routes/app_routes.dart';

class RegistroScanScreen extends StatefulWidget {
  const RegistroScanScreen({super.key});

  @override
  State<RegistroScanScreen> createState() => _RegistroScanScreenState();
}

class _RegistroScanScreenState extends State<RegistroScanScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final AttendanceService attendanceService = AttendanceService();
  final UserService userService = UserService();

  bool _isAuth = false;
  String _statusMessage = "";
  StatusType _statusType = StatusType.info;

  Future<void> _autenticarHuella() async {
    print("DEBUG: Iniciando flujo biométrico...");
    try {
      final authenticated = await auth.authenticate(
        localizedReason:
            'Por favor, escanee su huella para registrar asistencia.',
        biometricOnly: true,
      );

      print("DEBUG: Resultado authenticate = $authenticated");

      if (authenticated) {
        setState(() {
          _isAuth = true;
          _statusMessage = "Huella reconocida correctamente";
          _statusType = StatusType.success;
        });
      } else {
        setState(() {
          _statusMessage = "Huella no reconocida";
          _statusType = StatusType.error;
        });
      }
    } catch (e) {
      print("DEBUG: Excepción en authenticate -> $e");
      setState(() {
        _statusMessage = "Error en autenticación biométrica";
        _statusType = StatusType.error;
      });
    }
  }

  Future<void> _enviarRegistro() async {
    print("DEBUG: Preparando envío de registro biométrico...");
    try {
      final ids = await userService.getIdsForAttendance();

      if (ids == null) {
        setState(() {
          _statusMessage = "No se pudieron obtener los datos del usuario";
          _statusType = StatusType.error;
        });
        return;
      }

      final result = await attendanceService.registrarAsistenciaHuella(
        companyId: ids['companyId']!,
        employeeId: ids['employeeId']!,
        deviceId: "flutter-app",
      );

      print("DEBUG: Respuesta del backend -> $result");

      if (result['success'] == true) {
        setState(() {
          _statusMessage = result['message'] ?? "Registro exitoso";
          _statusType = StatusType.success;
        });
      } else {
        setState(() {
          _statusMessage =
              result['message'] ?? "Error al registrar asistencia";
          _statusType = StatusType.error;
        });
      }
    } catch (e) {
      print("DEBUG: Excepción al enviar registro -> $e");
      setState(() {
        _statusMessage = "Error de conexión con el servidor";
        _statusType = StatusType.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            ScannerOverlay(
              boxSizeFactor: 0.65,
              offsetYFactor: -0.10,
              borderThickness: 4,
              cornerLength: 30,
              overlayColor: Colors.black54,
            ),

            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  GestureDetector(
                    onTap: _autenticarHuella,
                    child: Icon(
                      Icons.fingerprint,
                      size: 120,
                      color: _isAuth ? Colors.green : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 30), // 🔼 SUBIDO un poco

                  if (_statusMessage.isNotEmpty)
                    _StatusCard(
                      message: _statusMessage,
                      type: _statusType,
                    )
                  else
                    const Text(
                      "Toque el sensor para validar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),

                  const SizedBox(height: 56), // 🔽 más compacto

                  if (_isAuth)
                    ElevatedButton(
                      onPressed: _enviarRegistro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF370B12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 48,
                        ),
                      ),
                      child: const Text(
                        "Enviar Registro",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 80),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.registroManual);
                    },
                    child: Container(
                      height: 55,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF370B12), Color(0xFFE41335)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Registro Manual",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.edit, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== STATUS CARD ===================== */

enum StatusType { success, error, info }

class _StatusCard extends StatelessWidget {
  final String message;
  final StatusType type;

  const _StatusCard({
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      StatusType.success => Colors.green,
      StatusType.error => Colors.redAccent,
      StatusType.info => Colors.blueAccent,
    };

    final icon = switch (type) {
      StatusType.success => Icons.check_circle,
      StatusType.error => Icons.error,
      StatusType.info => Icons.info,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== OVERLAY SCANNER ===================== */

class ScannerOverlay extends StatelessWidget {
  final double boxSizeFactor;
  final double offsetYFactor;
  final double borderThickness;
  final double cornerLength;
  final Color overlayColor;

  const ScannerOverlay({
    super.key,
    this.boxSizeFactor = 0.7,
    this.offsetYFactor = 0.0,
    this.borderThickness = 4,
    this.cornerLength = 28,
    this.overlayColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final boxWidth = w * boxSizeFactor;
        final boxHeight = boxWidth;

        return IgnorePointer(
          child: CustomPaint(
            size: Size(w, h),
            painter: _ScannerPainter(
              holeRect: Rect.fromLTWH(
                (w - boxWidth) / 2,
                (h - boxHeight) / 2 + (h * offsetYFactor),
                boxWidth,
                boxHeight,
              ),
              overlayColor: overlayColor,
              borderThickness: borderThickness,
              cornerLength: cornerLength,
            ),
          ),
        );
      },
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final Rect holeRect;
  final Color overlayColor;
  final double borderThickness;
  final double cornerLength;

  _ScannerPainter({
    required this.holeRect,
    required this.overlayColor,
    required this.borderThickness,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = overlayColor,
    );
    canvas.drawRect(
      holeRect,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = borderThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final l = holeRect.left;
    final t = holeRect.top;
    final r = holeRect.right;
    final b = holeRect.bottom;
    final c = cornerLength;

    canvas.drawLine(Offset(l, t), Offset(l + c, t), cornerPaint);
    canvas.drawLine(Offset(l, t), Offset(l, t + c), cornerPaint);
    canvas.drawLine(Offset(r, t), Offset(r - c, t), cornerPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + c), cornerPaint);
    canvas.drawLine(Offset(l, b), Offset(l + c, b), cornerPaint);
    canvas.drawLine(Offset(l, b), Offset(l, b - c), cornerPaint);
    canvas.drawLine(Offset(r, b), Offset(r - c, b), cornerPaint);
    canvas.drawLine(Offset(r, b), Offset(r, b - c), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
