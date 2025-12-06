import 'package:auth_company/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';

class AppDrawer extends StatelessWidget {
  final ui.Image? screenImage;

  const AppDrawer({super.key, this.screenImage});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double drawerWidth = size.width;
    final double previewWidth = drawerWidth * 0.25;
    final double previewHeight = drawerWidth * 0.40;
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    final List<Map<String, String>> categorias = [
      {
        "nombre": "Home",
        "asset": "lib/assets/images/Home.svg",
        "ruta": AppRoutes.home,
      },
      {
        "nombre": "Sucursal",
        "asset": "lib/assets/images/Sucursal.svg",
        "ruta": AppRoutes.registroempleados,
      },
      {
        "nombre": "Calendar",
        "asset": "lib/assets/images/Calendar.svg",
        "ruta": AppRoutes.calendario,
      },
      {
        "nombre": "Vacaciones",
        "asset": "lib/assets/images/Vacaciones.svg",
        "ruta": AppRoutes.vacaciones,
      },
      {
        "nombre": "Horario",
        "asset": "lib/assets/images/Horario.svg",
        "ruta": AppRoutes.horario,
      },
      {
        "nombre": "Zona",
        "asset": "lib/assets/images/Zona.svg",
        "ruta": AppRoutes.capas,
      },
      {
        "nombre": "Registro",
        "asset": "lib/assets/images/Registro.svg",
        "ruta": AppRoutes.registroempleados,
      },
    ];
    return Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFF3C0A13),
              Color(0xFFA21C34),
              Color(0xFFE41335),
              Color(0xFFE81236),
              Color(0xFFEB455E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ───────── SVG de fondo ─────────
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: 0.5, // 0.0 totalmente transparente, 1.0 opaco
                child: SvgPicture.asset(
                  'lib/assets/images/huella3.svg',
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                ),
              ),
            ),

            Column(
              children: [
                // ─────────────── Header transparente ───────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 25,
                  ),
                  color: const Color.fromARGB(0, 0, 0, 0), // fondo transparente
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ───────── Columna izquierda: imagen circular + texto ─────────
                      Row(
                        children: [
                          Container(
                            width: size.width * 0.10,
                            height: size.width * 0.10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://ichef.bbci.co.uk/ace/ws/640/cpsprodpb/9db5/live/48fd9010-c1c1-11ee-9519-97453607d43e.jpg.webp',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Carlos Lopez",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // ───────── Columna derecha: botón cerrar ─────────
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: size.width * 0.055, // tamaño responsivo
                      ),
                    ],
                  ),
                ),

                // ─────────────── Sección texto + miniaturas ───────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 0),
                    child: Row(
                      children: [
                        // ───────── Columna de texto ─────────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ───────── Lista de categorías centrada ─────────
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center, // lista centrada verticalmente
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        categorias.map((item) {
                                          final String currentRoute =
                                              ModalRoute.of(
                                                context,
                                              )?.settings.name ??
                                              '';

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 15,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  item['ruta']!,
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  // ─── Punto indicador ───
                                                  if (item['ruta'] ==
                                                      currentRoute)
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                    )
                                                  else
                                                    const SizedBox(
                                                      width: 8,
                                                    ), // espacio fijo para no empujar el texto

                                                  const SizedBox(width: 15),
                                                  // ─── SVG ───
                                                  SvgPicture.asset(
                                                    item['asset']!,
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.05,
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.05,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 15),

                                                  // ─── Texto ───
                                                  Flexible(
                                                    child: Text(
                                                      item['nombre']!,
                                                      style: TextStyle(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.035,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),

                                // ───────── SVG adicional + texto al final ─────────
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'lib/assets/images/Logout.svg', // tu SVG
                                      width: size.width * 0.05,
                                      height: size.width * 0.05,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        "Logout",
                                        style: TextStyle(
                                          fontSize: size.width * 0.035,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ), // margen inferior opcional
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // ───────── Row de miniaturas ─────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Miniatura 1
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: SizedBox(
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 0.20,
                                    child:
                                        screenImage == null
                                            ? const Icon(
                                              Icons.image_not_supported,
                                              size: 36,
                                              color: Colors.white,
                                            )
                                            : ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      30,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      30,
                                                    ),
                                                  ),
                                              child: SizedBox(
                                                width: previewWidth * 2.5,
                                                height: previewHeight * 3.0,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    RawImage(
                                                      image: screenImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Container(
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: SizedBox(
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 0.25,
                                    child:
                                        screenImage == null
                                            ? const Icon(
                                              Icons.image_not_supported,
                                              size: 36,
                                              color: Colors.white,
                                            )
                                            : ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      30,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      30,
                                                    ),
                                                  ),
                                              child: SizedBox(
                                                width: previewWidth * 3.0,
                                                height: previewHeight * 3.5,
                                                child: RawImage(
                                                  image: screenImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32), // espacio inferior opcional
              ],
            ),
          ],
        ),
      ),
    );
  }
}
