import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Horario extends StatefulWidget {
  const Horario({super.key});

  @override
  State<Horario> createState() => HorarioS();
}

class HorarioS extends State<Horario> {
  final List<String> meses = [
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre",
  ];
  final List<Map<String, String>> diasSemana = [
    {"dia": "L", "numero": "1"},
    {"dia": "M", "numero": "2"},
    {"dia": "Mi", "numero": "3"},
    {"dia": "J", "numero": "4"},
    {"dia": "V", "numero": "5"},
    {"dia": "S", "numero": "6"},
    {"dia": "D", "numero": "7"},
  ];
  final List<Map<String, dynamic>> registros = [
    {
      "fecha": "Jueves 23",
      "horasLaboradas": "2hr 5min",
      "horaEntrada": "12:00 AM",
      "horaSalida": "8:00 PM",
      "svgPath": "lib/assets/images/Dia.svg",
    },
    {
      "fecha": "Viernes 24",
      "horasLaboradas": "3hr 30min",
      "horaEntrada": "9:00 AM",
      "horaSalida": "5:00 PM",
      "svgPath": "lib/assets/images/Noche.svg",
    },
    {
      "fecha": "Jueves 23",
      "horasLaboradas": "2hr 5min",
      "horaEntrada": "12:00 AM",
      "horaSalida": "8:00 PM",
      "svgPath": "lib/assets/images/Dia.svg",
    },
    {
      "fecha": "Viernes 24",
      "horasLaboradas": "3hr 30min",
      "horaEntrada": "9:00 AM",
      "horaSalida": "5:00 PM",
      "svgPath": "lib/assets/images/Noche.svg",
    },
  ];
  int mesSeleccionado = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Índice inicial alto para simular circularidad
    _pageController = PageController(
      initialPage: 1000 * meses.length + mesSeleccionado,
      viewportFraction: 0.4,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final sidePadding = w * 0.06;
    final topPadding = h * 0.06;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con blur
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

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sidePadding,
                  vertical: topPadding,
                ),
                child: Column(
                  children: [
                    // Encabezado con SVG y título
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
                    const SizedBox(height: 15),

                    // Fila de año
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const Text(
                          "2025",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Carrusel circular de meses
                    SizedBox(
                      height: 100,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            mesSeleccionado = index % meses.length;
                          });
                        },
                        itemBuilder: (context, index) {
                          final int mesIndex = index % meses.length;

                          // Evitar null en _pageController.page
                          final double currentPage =
                              _pageController.hasClients &&
                                      _pageController.page != null
                                  ? _pageController.page!
                                  : _pageController.initialPage.toDouble();

                          final double difference = (index - currentPage).abs();
                          final bool esCentral = difference < 0.5;

                          final double scale = esCentral ? 1.2 : 0.9;
                          final double yOffset =
                              (3 - scale) * 1 + (esCentral ? 25 : 0);

                          return GestureDetector(
                            onTap: () {
                              if (_pageController.hasClients) {
                                // Calcula salto circular correcto
                                final int currentIndex =
                                    _pageController.page!.round();
                                final int jump = index - currentIndex;

                                _pageController.animateToPage(
                                  currentIndex + jump,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            },
                            child: Transform.translate(
                              offset: Offset(0, yOffset),
                              child: Transform.scale(
                                scale: scale,
                                child: Center(
                                  child: Text(
                                    meses[mesIndex],
                                    style: TextStyle(
                                      fontSize: esCentral ? 26 : 20,
                                      color:
                                          esCentral
                                              ? Colors.white
                                              : Colors.grey.shade400,
                                      fontWeight:
                                          esCentral
                                              ? FontWeight.bold
                                              : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      height: h * 0.1, // 10% de la altura de la pantalla
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Columna izquierda
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: w * 0.06, // 8% del ancho de pantalla
                            ),
                          ),

                          // Columna central centrada
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      diasSemana.map((dia) {
                                        final bool esSeleccionado =
                                            dia["numero"] == "3";
                                        return Container(
                                          width:
                                              w *
                                              0.1, // 12% del ancho de pantalla
                                          margin: EdgeInsets.symmetric(
                                            horizontal: w * 0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              w * 0.08,
                                            ),
                                            gradient:
                                                esSeleccionado
                                                    ? const LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end:
                                                          Alignment
                                                              .bottomCenter,
                                                      colors: [
                                                        Color(0xFFE41335),
                                                        Color(0xFF370B12),
                                                      ],
                                                    )
                                                    : null,
                                            color:
                                                esSeleccionado
                                                    ? null
                                                    : Colors.transparent,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(height: h * 0.01),
                                              Text(
                                                dia["dia"]!,
                                                style: TextStyle(
                                                  color:
                                                      esSeleccionado
                                                          ? Colors.white
                                                          : Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      w *
                                                      0.035, // Tamaño de texto
                                                ),
                                              ),
                                              SizedBox(height: h * 0.015),
                                              Text(
                                                dia["numero"]!,
                                                style: TextStyle(
                                                  color:
                                                      esSeleccionado
                                                          ? Colors.white
                                                          : Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: w * 0.035,
                                                ),
                                              ),
                                              SizedBox(height: h * 0.01),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          ),

                          // Columna derecha
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: w * 0.06,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Jueves 23",
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            letterSpacing: 5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Generar los cuadros dinámicamente
                    Column(
                      children:
                          registros.map((registro) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 20,
                                    sigmaY: 20,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        // Fila superior: Fecha y Horas laboradas
                                        // Fila superior: Fecha y Horas laboradas
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              registro["fecha"],
                                              style: TextStyle(
                                                color: const Color.fromRGBO(
                                                  237,
                                                  108,
                                                  126,
                                                  1,
                                                ),
                                                fontSize:
                                                    w *
                                                    0.045, // Fuente responsiva
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Horas laboradas: ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize:
                                                          w *
                                                          0.04, // Fuente responsiva
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        registro["horasLaboradas"],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                      fontSize:
                                                          w *
                                                          0.04, // Fuente responsiva
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 0),
                                        const Divider(color: Colors.white24),

                                        const SizedBox(height: 2),
                                        // Fila inferior: Entrada, Salida, SVG
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // Columna Entrada
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Hora de entrada:",
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    registro["horaEntrada"],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Línea vertical
                                            Container(
                                              width: 1,
                                              height: 40,
                                              color: Colors.white24,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                            ),

                                            // Columna Salida
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Hora de salida:",
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    registro["horaSalida"],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // SVG más pequeño y abajo
                                            SizedBox(
                                              width: 40,
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: SvgPicture.asset(
                                                  registro["svgPath"],
                                                  height: 25,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: h * 0.07),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
