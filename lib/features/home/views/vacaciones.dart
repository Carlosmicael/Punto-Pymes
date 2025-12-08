import 'package:auth_company/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VacacionesScreen extends StatelessWidget {
  const VacacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final List<Map<String, dynamic>> datos = [
      {"titulo": "Días disponibles", "numero": 10},
      {"titulo": "Días restantes", "numero": 5},
      {"titulo": "Días usados", "numero": 3},
    ];

    final List<Map<String, dynamic>> historial = [
      {
        "numero": "026334",
        "fechaSolicitud": "02/07/2025",
        "fechas": ["02/08/2025", "03/08/2025"],
        "motivo": "Viaje familiar",
        "dias": 2,
        "estado": "En proceso",
      },
      {
        "numero": "026335",
        "fechaSolicitud": "01/06/2025",
        "fechas": ["10/07/2025", "11/07/2025"],
        "motivo": "Vacaciones",
        "dias": 2,
        "estado": "Aprobado",
      },
    ];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(),

            child: SingleChildScrollView(
              key: const PageStorageKey("Vacaciones"),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.02),

                  // ------------------ ENCABEZADO ------------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "lib/assets/images/Vacaciones.svg",
                          width: width * 0.05,
                          height: width * 0.05,
                          color: Colors.black,
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          "Vacaciones",
                          style: TextStyle(
                            fontSize: width * 0.03,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.03),

                  // ------------------ SCROLL HORIZONTAL ------------------
                  SizedBox(
                    height: height * 0.18,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: datos.length,
                      itemBuilder: (context, index) {
                        final item = datos[index];

                        return Container(
                          width: width * 0.60,
                          margin: EdgeInsets.only(
                            right: width * 0.04,
                            left:
                                index == 0
                                    ? width * 0.04
                                    : 0, // 👈 Solo el primer cuadro empieza más a la derecha
                          ),
                          padding: EdgeInsets.all(width * 0.04),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [Color(0xFF7B1522), Color(0xFFE41335)],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  item["titulo"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Center(
                                child: Text(
                                  "${item["numero"]}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: height * 0.03),

                  // ------------------ BOTÓN ------------------
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: width * 0.55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.025,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.solicitudVacacion,
                            );
                          },
                          child: Text(
                            "Solicitar Vacaciones",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.03),
                  // ------------------ HISTORIAL ------------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.015,
                        horizontal: width * 0.04,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF7B1522), Color(0xFFE41335)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Historial de solicitudes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: width * 0.06,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  // ------------------ LISTA HISTORIAL ------------------
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.1,
                    ), // 👈 padding horizontal también aquí
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historial.length,
                      itemBuilder: (context, i) {
                        final item = historial[i];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.015,
                                horizontal: width * 0.01,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "Nro de solicitud:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(item["numero"]),
                                    ],
                                  ),
                                  const SizedBox(height: 5),

                                  Row(
                                    children: [
                                      const Text(
                                        "Fecha de solicitud:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(item["fechaSolicitud"]),
                                    ],
                                  ),
                                  const SizedBox(height: 5),

                                  const Text(
                                    "Fechas solicitadas:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  ...item["fechas"].map<Widget>(
                                    (f) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 25,
                                        top: 2,
                                      ),
                                      child: Text(
                                        f,
                                        style: TextStyle(
                                          fontSize: width * 0.035,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Row(
                                    children: [
                                      const Text(
                                        "Motivo:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(item["motivo"])),
                                    ],
                                  ),
                                  const SizedBox(height: 5),

                                  Row(
                                    children: [
                                      const Text(
                                        "Días:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(item["dias"].toString()),
                                    ],
                                  ),
                                  const SizedBox(height: 5),

                                  Row(
                                    children: [
                                      const Text(
                                        "Estado:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(item["estado"]),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.grey.withOpacity(0.4),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
