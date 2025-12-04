import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistroExitosoScreen extends StatefulWidget {
  const RegistroExitosoScreen({super.key});

  @override
  State<RegistroExitosoScreen> createState() => _RegistroExitosoScreenState();
}

class _RegistroExitosoScreenState extends State<RegistroExitosoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _controller.reverse();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ===== VARIABLES RESPONSIVAS =====
    final double topText = size.height * 0.17;
    final double bigCircle = size.width * 0.20;
    final double bigIcon = size.width * 0.1;
    final double whiteBoxHeight = size.height * 0.75;
    final double buttonVertical = size.height * 0.015;
    final double buttonHorizontal = size.width * 0.15;
    final double smallCircle = size.width * 0.080;
    final double svgSize = size.width * 0.020;
    final double titleFont = size.width * 0.055;
    final double bodyFont = size.width * 0.035;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFE81236), Color(0xFF7B1522)],
            ),
          ),

          child: Stack(
            children: [
              // ✨ TEXTO SUPERIOR RESPONSIVO
              Positioned(
                top: topText,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Text(
                    "Automatico",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.037,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ),

              // CUADRO BLANCO ANIMADO RESPONSIVO
              SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: size.width,
                    height: whiteBoxHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(size.width * 0.22),
                        topRight: Radius.circular(size.width * 0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.47),
                          blurRadius: size.width * 0.12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.1),

                            // CÍRCULO NEGRO RESPONSIVO
                            Container(
                              width: bigCircle,
                              height: bigCircle,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.46),
                                    blurRadius: size.width * 0.12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: bigIcon,
                                ),
                              ),
                            ),

                            SizedBox(height: size.height * 0.02),

                            // TÍTULO RESPONSIVO
                            Text(
                              "Registro Exitoso",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: titleFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: size.height * 0.02),

                            // TEXTO DESCRIPTIVO
                            Text(
                              "Presione aceptar para confirmar su asistencia",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: bodyFont,
                              ),
                            ),

                            SizedBox(height: size.height * 0.03),

                            // ===== BOTÓN NEGRO =====
                            SizedBox(
                              width:
                                  size.width *
                                  0.55, // 👈 MISMO ANCHO PARA AMBOS
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: buttonVertical,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.44),
                                      blurRadius: size.width * 0.06,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center, // 👈 Centrado
                                  children: [
                                    Text(
                                      "Aceptar",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: bodyFont * 1.15,
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.07),

                                    // CÍRCULO GRIS CON SVG
                                    Container(
                                      width: smallCircle,
                                      height: smallCircle,
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(
                                          78,
                                          187,
                                          187,
                                          187,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          "lib/assets/images/Siguiente.svg",
                                          width: svgSize,
                                          height: svgSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: size.height * 0.02),

                            // ===== BOTÓN BORDE NEGRO =====
                            SizedBox(
                              width:
                                  size.width *
                                  0.55, // 👈 MISMO ANCHO PARA AMBOS
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: buttonVertical,
                                  horizontal: buttonHorizontal,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Aceptar",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: bodyFont * 1.2,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
