import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  late PageController _pageController;
  bool mostrarDetalle = false;
  Map<String, dynamic>? registroActivo;

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
  final List<Map<String, dynamic>> listaRegistros = [
    {
      "fecha": "Jueves 23 de Octubre del 2025",
      "estadoGeneral": "Registrado",
      "nroRegistro": "1",

      "entrada": {
        "horaEsperada": "7:00 AM",
        "horaRegistrada": "7:01 AM",
        "estado": "Retraso",
        "asistencia": "Registrado",
      },

      "salida": {
        "horaEsperada": "7:00 PM",
        "horaRegistrada": "7:01 PM",
        "estado": "Retraso",
        "asistencia": "Registrado",
      },

      "horasTotales": "2 hr 20 min",
    },

    // -------------------------
    // REGISTRO: FALTO
    // -------------------------
    {
      "nroRegistro": "2",
      "fecha": "Jueves 23 de Octubre del 2025",
      "estadoGeneral": "Falto",
      "entrada": null,
      "salida": null,
    },

    // -------------------------
    // REGISTRO: CON PERMISO
    // -------------------------
    {
      "nroRegistro": "3",
      "fecha": "Miércoles 12 de Octubre del 2025",
      "estadoGeneral": "Con permiso",
      "entrada": null,
      "salida": null,
    },

    // ---------------------------------------------
    // REGISTRO COMPLETO PERO SALIDA SIN REGISTRO
    // ---------------------------------------------
    {
      "nroRegistro": "4",
      "fecha": "Jueves 13 de Octubre del 2025",
      "estadoGeneral": "Registrado",

      "entrada": {
        "horaEsperada": "7:00 AM",
        "horaRegistrada": "7:00 AM",
        "estado": "Normal",
        "asistencia": "Registrado",
      },

      "salida": {
        "horaEsperada": "7:00 PM",
        "horaRegistrada": null,
        "estado": null,
        "asistencia": "Sin registro",
      },

      "horasTotales": "2 hr 20 min",
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

  void mostrarBottomSheet(Map<String, dynamic> registro) {
    setState(() {
      mostrarDetalle = true;
      registroActivo = registro;
    });
  }

  void cerrarBottomSheet() {
    setState(() {
      mostrarDetalle = false;
      registroActivo = null;
    });
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
            key: const PageStorageKey("Capas"),
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
                                                ? const Color.fromARGB(
                                                  255,
                                                  0,
                                                  0,
                                                  0,
                                                )
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
                          final bool mostrarBoton =
                              (registro["entrada"]?["asistencia"] ==
                                  "Registrado") ||
                              (registro["salida"]?["asistencia"] ==
                                  "Registrado");

                          final String estadoGeneral =
                              registro["estadoGeneral"] ?? "";
                          final entrada =
                              registro["entrada"]; // puede ser null o Map
                          final salida =
                              registro["salida"]; // puede ser null o Map
                          final nroRegistro =
                              registro["nroRegistro"]; // <-- ES UN STRING

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
                                          // FECHA
                                          // FECHA
                                          Text(
                                            fecha,
                                            style: TextStyle(
                                              fontSize: size.width * 0.035,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),

                                          SizedBox(height: size.height * 0.01),

                                          // NÚMERO DE REGISTRO (SE MUESTRA EN TODOS)
                                          Text(
                                            "Registro $nroRegistro",
                                            style: TextStyle(
                                              fontSize: size.width * 0.030,
                                              color: Colors.white70,
                                            ),
                                          ),

                                          SizedBox(height: size.height * 0.015),

                                          // -----------------------------------------------------
                                          //                 REGISTRO COMPLETO
                                          // -----------------------------------------------------
                                          if (estadoGeneral ==
                                              "Registrado") ...[
                                            if (entrada != null)
                                              Text(
                                                "Asistencia entrada: ${entrada["asistencia"]}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: size.width * 0.030,
                                                ),
                                              ),

                                            SizedBox(
                                              height: size.height * 0.010,
                                            ),

                                            if (salida != null)
                                              Text(
                                                "Asistencia salida: ${salida["asistencia"]}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: size.width * 0.030,
                                                ),
                                              ),
                                            if (mostrarBoton) ...[
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  foregroundColor: Colors.white,
                                                  side: const BorderSide(
                                                    color: Colors.white,
                                                    width: 1.5,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          50,
                                                        ), // Opcional
                                                  ),
                                                ),
                                                onPressed: () {
                                                  mostrarBottomSheet(
                                                    registro,
                                                  ); // <-- ACTIVA EL DETALLE
                                                },
                                                child: const Text(
                                                  "Ver detalle",
                                                ),
                                              ),
                                            ],
                                          ]
                                          // -----------------------------------------------------
                                          //               FALTO / CON PERMISO
                                          // -----------------------------------------------------
                                          else ...[
                                            Text(
                                              estadoGeneral,
                                              style: TextStyle(
                                                fontSize: size.width * 0.035,
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
          if (mostrarDetalle && registroActivo != null) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: cerrarBottomSheet,
                child: Container(color: Colors.black.withOpacity(0.55)),
              ),
            ),

            Positioned(
              child: Center(
                child: Container(
                  width: size.width * 0.90,
                  padding: EdgeInsets.all(size.width * 0.05),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 18,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TÍTULO
                      if (registroActivo!["nroRegistro"] != null)
                        Text(
                          "Registro ${registroActivo!["nroRegistro"]}",
                          style: TextStyle(
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),

                      const Divider(),

                      /// FECHA
                      if (registroActivo!["fecha"] != null)
                        Text("Fecha: ${registroActivo!["fecha"]}"),

                      /// HORAS TOTALES
                      if (registroActivo!["horasTotales"] != null)
                        Text(
                          "Horas trabajadas: ${registroActivo!["horasTotales"]}",
                        ),

                      const SizedBox(height: 10),
                      const Divider(),

                      /// ENTRADA
                      Text(
                        "Entrada:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      if (registroActivo!["entrada"] != null) ...[
                        if (registroActivo!["entrada"]["horaEsperada"] != null)
                          Text(
                            "Hora Entrada: ${registroActivo!["entrada"]["horaEsperada"]}",
                          ),

                        if (registroActivo!["entrada"]["horaRegistrada"] !=
                            null)
                          Text(
                            "Hora Registrada: ${registroActivo!["entrada"]["horaRegistrada"]}",
                          ),

                        if (registroActivo!["entrada"]["estado"] != null)
                          Text(
                            "Estado: ${registroActivo!["entrada"]["estado"]}",
                          ),

                        if (registroActivo!["entrada"]["asistencia"] != null)
                          Text(
                            "Asistencia: ${registroActivo!["entrada"]["asistencia"]}",
                          ),
                      ] else
                        Text("Sin entrada registrada"),

                      const SizedBox(height: 10),
                      const Divider(),

                      /// SALIDA
                      Text(
                        "Salida:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      if (registroActivo!["salida"] != null) ...[
                        if (registroActivo!["salida"]["horaEsperada"] != null)
                          Text(
                            "Hora Salida: ${registroActivo!["salida"]["horaEsperada"]}",
                          ),

                        if (registroActivo!["salida"]["horaRegistrada"] != null)
                          Text(
                            "Hora Registrada: ${registroActivo!["salida"]["horaRegistrada"]}",
                          ),

                        if (registroActivo!["salida"]["estado"] != null)
                          Text(
                            "Estado: ${registroActivo!["salida"]["estado"]}",
                          ),

                        if (registroActivo!["salida"]["asistencia"] != null)
                          Text(
                            "Asistencia: ${registroActivo!["salida"]["asistencia"]}",
                          ),
                      ] else
                        Text("Sin salida registrada"),

                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: cerrarBottomSheet,
                          child: const Text("Cerrar"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
