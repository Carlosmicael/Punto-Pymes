import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  late PageController _pageController;

  int mesSeleccionado = 0;

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
  int registroSeleccionado = -1;

  final List<Map<String, String>> listaRegistros = [
    {
      "fecha": "Jueves 23 de Octubre del 2025",
      "estado": "normal",
      "entrada": "Registrado",
      "salida": "Sin registro",
    },
    {"fecha": "Jueves 23 de Octubre del 2025", "estado": "Falto"},
    {"fecha": "Miércoles 12 de Octubre del 2025", "estado": "Con permiso"},
    {
      "fecha": "Jueves 13 de Octubre del 2025",
      "estado": "normal",
      "entrada": "Registrado",
      "salida": "Registrado",
    },
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: 1000 * meses.length,
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: size.width * 0.5,
            child: Container(color: const Color(0xFF303030)),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // PARTE SUPERIOR (ANTES EXPANDED)
                Container(
                  width: double.infinity,
                  height: h * 0.40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(size.width * 0.25),
                    ),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 70),
                      Row(
                        children: [
                          const SizedBox(width: 30),

                          SvgPicture.asset(
                            'lib/assets/images/capas.svg',
                            height: 30,
                            color: Colors.black,
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            "Historial de Registro",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              letterSpacing: 5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: h * 0.08,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              mesSeleccionado = index % meses.length;
                            });
                          },
                          itemBuilder: (context, index) {
                            final int mesIndex = index % meses.length;

                            final double currentPage =
                                _pageController.hasClients &&
                                        _pageController.page != null
                                    ? _pageController.page!
                                    : _pageController.initialPage.toDouble();

                            final double diff = (index - currentPage).abs();
                            final bool esCentral = diff < 0.5;

                            return Transform.scale(
                              scale: esCentral ? 1.15 : 0.85,
                              child: Center(
                                child: Text(
                                  meses[mesIndex],
                                  style: TextStyle(
                                    fontSize: esCentral ? w * 0.05 : w * 0.03,
                                    color:
                                        esCentral
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                    fontWeight:
                                        esCentral
                                            ? FontWeight.bold
                                            : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 25),
                      SizedBox(
                        height: h * 0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: w * 0.1),

                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                                size: w * 0.05,
                              ),
                            ),

                            Expanded(
                              child: Center(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children:
                                        diasSemana.map((dia) {
                                          final bool esSeleccionado =
                                              dia["numero"] == "3";

                                          return Container(
                                            width: w * 0.085,
                                            margin: EdgeInsets.symmetric(
                                              horizontal: w * 0.00,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                SizedBox(height: h * 0.005),
                                                Text(
                                                  dia["dia"]!,
                                                  style: TextStyle(
                                                    color:
                                                        esSeleccionado
                                                            ? Colors.white
                                                            : Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: w * 0.035,
                                                  ),
                                                ),
                                                SizedBox(height: h * 0.005),
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
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.chevron_right,
                                color: Colors.black,
                                size: w * 0.05,
                              ),
                            ),

                            SizedBox(width: w * 0.1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // PARTE INFERIOR (ANTES EXPANDED)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF303030),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.05),
                      Padding(
                        padding: EdgeInsets.only(
                          left: size.width * 0.08,
                          top: size.height * 0.03,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Esta semana",
                            style: TextStyle(
                              fontSize: size.width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      Column(
                        children: List.generate(listaRegistros.length, (index) {
                          final registro = listaRegistros[index];
                          final bool seleccionado =
                              registroSeleccionado == index;

                          final String estado = registro["estado"] ?? "";
                          final String entrada =
                              registro["entrada"] ?? "Sin registro";
                          final String salida =
                              registro["salida"] ?? "Sin registro";
                          final String fecha = registro["fecha"] ?? "Sin fecha";

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                registroSeleccionado = index;
                              });
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // -----------------------------
                                  // LÍNEA BLANCA FUERA DEL CUADRO
                                  // -----------------------------
                                  if (seleccionado)
                                    Positioned(
                                      left: size.width * 0.035,
                                      top: 17,
                                      bottom: 17,
                                      child: Container(
                                        width: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // -----------------------------
                                  // CONTENEDOR PRINCIPAL
                                  // -----------------------------
                                  Container(
                                    width: double.infinity,

                                    margin: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.07,
                                      vertical: size.height * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient:
                                          seleccionado
                                              ? const LinearGradient(
                                                begin: Alignment.bottomLeft,
                                                end: Alignment.topRight,
                                                colors: [
                                                  Color(0xFF370B12),
                                                  Color(0xFFE41335),
                                                ],
                                              )
                                              : null,
                                      color:
                                          seleccionado
                                              ? null
                                              : const Color(0xFF3D3D3D),
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        size.width * 0.05,
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fecha,
                                            style: TextStyle(
                                              fontSize: size.width * 0.035,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),

                                          SizedBox(height: size.height * 0.015),

                                          if (estado == "normal") ...[
                                            Text(
                                              "Registro 1",
                                              style: TextStyle(
                                                color: Color(0xFFED6C7E),
                                                fontSize: size.width * 0.03,
                                              ),
                                            ),

                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),

                                            Row(
                                              children: [
                                                Text(
                                                  "Asistencia de entrada: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize:
                                                        size.width * 0.025,
                                                  ),
                                                ),
                                                Text(
                                                  entrada,
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize:
                                                        size.width * 0.025,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: size.height * 0.008,
                                            ),

                                            Row(
                                              children: [
                                                Text(
                                                  "Asistencia de salida: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize:
                                                        size.width * 0.025,
                                                  ),
                                                ),
                                                Text(
                                                  salida,
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize:
                                                        size.width * 0.025,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: size.height * 0.02,
                                            ),

                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: size.width * 0.1,
                                                vertical: size.height * 0.007,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              child: const Text(
                                                "Ver info",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],

                                          if (estado != "normal") ...[
                                            Text(
                                              estado,
                                              style: TextStyle(
                                                fontSize: size.width * 0.03,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: h * 0.12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
