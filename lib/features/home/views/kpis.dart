import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  // 📌 Lista de tareas (puedes reemplazar esto luego)
  List<Map<String, dynamic>> tareas = [
    {
      "titulo": "Entregar Documentos",
      "categoria": "Documentos",
      "fecha": DateTime(2025, 12, 11, 12, 45),
    },
    {
      "titulo": "Examen de Matemáticas",
      "categoria": "Matemáticas",
      "fecha": DateTime(2025, 12, 11, 9, 30),
    },
    {
      "titulo": "Entregar Documentos",
      "categoria": "Documentos",
      "fecha": DateTime(2025, 12, 12, 12, 45),
    },
    {
      "titulo": "Examen de Matemáticas",
      "categoria": "Matemáticas",
      "fecha": DateTime(2025, 12, 12, 9, 30),
    },
    {
      "titulo": "Proyecto Ciencias",
      "categoria": "Ciencias",
      "fecha": DateTime(2025, 11, 13, 10, 00),
    },
  ];

  // 🔹 Formateo manual en español (sin usar locale)
  String _formatFecha(DateTime f) {
    const dias = ["lun", "mar", "mié", "jue", "vie", "sáb", "dom"];
    const meses = [
      "ene",
      "feb",
      "mar",
      "abr",
      "may",
      "jun",
      "jul",
      "ago",
      "sep",
      "oct",
      "nov",
      "dic",
    ];

    return "${dias[f.weekday - 1]}, ${f.day} ${meses[f.month - 1]} ${f.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          // 🔹 Agrupar tareas por fecha
          Map<String, List<Map<String, dynamic>>> tareasPorFecha = {};
          for (var t in tareas) {
            String clave = DateFormat("yyyy-MM-dd").format(t["fecha"]);
            tareasPorFecha.putIfAbsent(clave, () => []);
            tareasPorFecha[clave]!.add(t);
          }

          // 🔹 Ordenar fechas
          List<String> fechasOrdenadas =
              tareasPorFecha.keys.toList()..sort((a, b) => a.compareTo(b));

          return Container(
            width: double.infinity,
            height: double.infinity,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE81236), Color(0xFFEB4335)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.12),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "lib/assets/images/Homework.svg",
                        width: width * 0.05,
                        height: width * 0.05,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      SizedBox(width: width * 0.02),
                      Text(
                        "Vacaciones",
                        style: TextStyle(
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.07),

                // 🔹 CONTENEDOR OSCURO
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(width * 0.07),

                    decoration: const BoxDecoration(
                      color: Color(0xFF111918),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(150, 0, 0, 0),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),

                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (String fecha in fechasOrdenadas) ...[
                          // ✔ Título del día
                          Padding(
                            padding: EdgeInsets.only(bottom: height * 0.015),
                            child: Text(
                              _esHoy(fecha)
                                  ? "Hoy"
                                  : _formatFecha(DateTime.parse(fecha)),
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // ✔ Lista ordenada por hora
                          ...(() {
                            final lista = List<Map<String, dynamic>>.from(
                              tareasPorFecha[fecha]!,
                            );
                            lista.sort(
                              (a, b) => a["fecha"].compareTo(b["fecha"]),
                            );

                            return lista
                                .map(
                                  (tarea) => _cardTarea(tarea, width, height),
                                )
                                .toList();
                          })(),

                          SizedBox(height: height * 0.03),
                        ],
                        SizedBox(height: height * 0.07),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 🔹 CARD DE TAREA
  // ============================================================
  Widget _cardTarea(Map<String, dynamic> tarea, double width, double height) {
    final fecha = tarea["fecha"];

    bool completado = false;

    return StatefulBuilder(
      builder: (context, setStateSB) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(bottom: height * 0.015),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: height * 0.02,
          ),
          decoration: BoxDecoration(
            color:
                completado
                    ? const Color.fromARGB(90, 255, 255, 255)
                    : const Color(0xFF303030),
            borderRadius: BorderRadius.circular(width * 0.05),
            boxShadow: [
              BoxShadow(
                color:
                    completado
                        ? Colors.white.withOpacity(0.4)
                        : Colors.black.withOpacity(0.25),
                blurRadius: completado ? width * 0.045 : width * 0.03,
                offset: Offset(0, height * 0.005),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============= CHECKBOX =============
              GestureDetector(
                onTap: () {
                  setStateSB(() => completado = true);

                  Future.delayed(const Duration(milliseconds: 400), () {
                    setState(() => tareas.remove(tarea));
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,

                  // 🔥 MÁS PEQUEÑO
                  width: width * 0.08,
                  height: width * 0.08,

                  decoration: BoxDecoration(
                    color:
                        completado
                            ? const Color.fromARGB(255, 252, 171, 171)
                            : Colors.transparent,

                    borderRadius: BorderRadius.circular(width * 0.018),

                    // 🔥 Borde más delgado
                    border: Border.all(
                      color: Colors.white,
                      width: width * 0.006,
                    ),

                    boxShadow:
                        completado
                            ? [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  255,
                                  143,
                                  176,
                                ).withOpacity(0.8),
                                blurRadius: width * 0.035,
                                spreadRadius: width * 0.008,
                              ),
                            ]
                            : [],
                  ),

                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: completado ? 1 : 0,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: completado ? 1 : 0.6,

                        // ✔ Ícono más pequeño proporcional
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: width * 0.045,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: width * 0.045),

              // ================= TEXTOS =================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      tarea["titulo"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: height * 0.006),

                    // Fecha
                    Text(
                      "${_formatFecha(fecha)}  ${DateFormat("HH:mm").format(fecha)}",
                      style: TextStyle(
                        color: const Color(0xFFFF9BA9),
                        fontSize: width * 0.036,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: height * 0.006),

                    // Categoría
                    Text(
                      tarea["categoria"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔹 Comparar si es hoy
  // ============================================================
  bool _esHoy(String fecha) {
    final hoy = DateFormat("yyyy-MM-dd").format(DateTime.now());
    return fecha == hoy;
  }
}
