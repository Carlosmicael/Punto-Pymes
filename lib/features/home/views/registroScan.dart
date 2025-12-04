import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class RegistroScanScreen extends StatefulWidget {
  const RegistroScanScreen({super.key});

  @override
  State<RegistroScanScreen> createState() => _RegistroScanScreenState();
}

class _RegistroScanScreenState extends State<RegistroScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    final backCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.low,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final w = constraints.maxWidth;

            return Stack(
              children: [
                // PREVIEW REAL DE LA CÁMARA
                FutureBuilder(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_controller!);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                  },
                ),

                // OVERLAY PARA SCANNER (cuadro más arriba)
                ScannerOverlay(
                  boxSizeFactor: 0.65,
                  offsetYFactor: -0.10, // ↩ Subido 10% hacia arriba
                  borderThickness: 4,
                  cornerLength: 30,
                  overlayColor: Colors.black54,
                ),

                // Botón atrás
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),

                // ==== BOTÓN REGISTRO MANUAL (DEBAJO DEL CUADRO) ====
                Positioned(
                  top: h * 0.62, // movido proporcional debajo del cuadro
                  left: w * 0.14,
                  right: w * 0.14,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF370B12), Color(0xFFE41335)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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
              ],
            );
          },
        ),
      ),
    );
  }
}

// ====================== OVERLAY DEL SCANNER ========================== //

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

        final left = (w - boxWidth) / 2;
        final top = (h - boxHeight) / 2 + (h * offsetYFactor);

        return IgnorePointer(
          child: CustomPaint(
            size: Size(w, h),
            painter: _ScannerPainter(
              holeRect: Rect.fromLTWH(left, top, boxWidth, boxHeight),
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
    final overlayPaint = Paint()..color = overlayColor;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, overlayPaint);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRect(holeRect, clearPaint);
    canvas.restore();

    final edgePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white12;
    canvas.drawRect(holeRect, edgePaint);

    final cornerPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderThickness
          ..strokeCap = StrokeCap.round
          ..color = Colors.white;

    final left = holeRect.left;
    final top = holeRect.top;
    final right = holeRect.right;
    final bottom = holeRect.bottom;
    final c = cornerLength;

    canvas.drawLine(Offset(left, top), Offset(left + c, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + c), cornerPaint);

    canvas.drawLine(Offset(right, top), Offset(right - c, top), cornerPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + c), cornerPaint);

    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + c, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left, bottom - c),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(right, bottom),
      Offset(right - c, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - c),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
