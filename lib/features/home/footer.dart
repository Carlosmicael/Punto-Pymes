import 'package:flutter/material.dart';

class FloatingFooter extends StatelessWidget {
  const FloatingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double iconSize = height * 0.028; 
    final double containerHeight = height * 0.075;
    final double containerWidth = width * 0.57;

    return Container(
      height: height * 0.15,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.10, vertical: height * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Contenedor principal del footer
            Stack(
              alignment: Alignment.center,
              children: [
                // Rectángulo negro principal
                Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(height * 0.04),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icono Home (con más espacio a la izquierda)
                      Container(
                        margin: EdgeInsets.only(left: width * 0.04), // Más espacio a la izquierda
                        width: iconSize,
                        height: iconSize,
                        child: Image.asset(
                          'lib/assets/icons/iconHome.png',
                          color: Colors.white,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      // Contenedor para User y Capas juntos
                      Row(
                        children: [
                          // Icono User
                          Container(
                            margin: EdgeInsets.only(right: width * 0.03), // Espacio entre User y Capas
                            width: iconSize,
                            height: iconSize,
                            child: Image.asset(
                              'lib/assets/icons/iconUser.png',
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                          
                          // Icono Settings (Capas)
                          Container(
                            margin: EdgeInsets.only(right: width * 0.09), // Espacio a la derecha
                            width: iconSize,
                            height: iconSize,
                            child: Image.asset(
                              'lib/assets/icons/iconCapas.png',
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rectángulo blanco superpuesto ENCIMA del icono Home
                Positioned(
                  left: containerWidth * 0.06, // Ajustado por el nuevo espaciado
                  child: Container(
                    width: containerWidth * 0.4, // Ancho aumentado a 0.4
                    height: containerHeight * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(height * 0.025),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icono Home dentro del rectángulo blanco
                        Container(
                          width: iconSize * 0.8,
                          height: iconSize * 0.8,
                          child: Image.asset(
                            'lib/assets/icons/iconHome.png',
                            color: Colors.black,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: width * 0.012),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: height * 0.014,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: width * 0.008),
                        // Punto verde pequeño
                        Container(
                          width: height * 0.007,
                          height: height * 0.007,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: width * 0.03),

            // Círculo negro con icono de cámara
            Container(
              width: containerHeight, 
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: iconSize * 0.9, 
                  height: iconSize * 0.9,
                  child: Image.asset(
                    'lib/assets/icons/iconCapture.png',
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}