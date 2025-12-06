import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auth_company/routes/app_routes.dart';

// Lista de sucursales con imágenes desde internet
const List<Map<String, dynamic>> sucursales = [
  {
    "titulo": "Sucursal Matriz - Centro",
    "direccion": "Av. Universitaria y 18 de Noviembre, Loja",
    "empleados": 35,
    "imagen":
        "https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW0lQzMlQTFnZW5lcyUyMGltcHJlc2lvbmFudGVzfGVufDB8fDB8fHww&fm=jpg&q=60&w=3000",
    "ruta": AppRoutes.capas,
  },
  {
    "titulo": "Sucursal Norte",
    "direccion": "Av. Norte y Loja",
    "empleados": 20,
    "imagen":
        "https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW0lQzMlQTFnZW5lcyUyMGltcHJlc2lvbmFudGVzfGVufDB8fDB8fHww&fm=jpg&q=60&w=3000",
    "ruta": AppRoutes.capas,
  },
  {
    "titulo": "Sucursal Sur",
    "direccion": "Av. Sur y Loja",
    "empleados": 15,
    "imagen":
        "https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW0lQzMlQTFnZW5lcyUyMGltcHJlc2lvbmFudGVzfGVufDB8fDB8fHww&fm=jpg&q=60&w=3000",
    "ruta": AppRoutes.capas,
  },
  {
    "titulo": "Sucursal Este",
    "direccion": "Av. Este y Loja",
    "empleados": 10,
    "imagen":
        "https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW0lQzMlQTFnZW5lcyUyMGltcHJlc2lvbmFudGVzfGVufDB8fDB8fHww&fm=jpg&q=60&w=3000",
    "ruta": AppRoutes.capas,
  },
];

class SucursalPage extends StatelessWidget {
  const SucursalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),

            // Ícono + Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'lib/assets/images/Sucursal.svg',
                    width: screenWidth * 0.07,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Sucursal',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Cuadro blanco
            Container(
              width: size.width,
              height: 350,
              color: const Color.fromARGB(255, 229, 229, 229),
            ),

            // *** CUADRO ENCIMA DEL CUADRO AZUL ***
            Transform.translate(
              offset: const Offset(0, -380),
              child: Container(
                width: size.width,
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(64, 0, 0, 0),
                      blurRadius: 30,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    // ---- TEXTO A LA IZQUIERDA ----
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar sucursal...",
                          hintStyle: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ---- BOTÓN CON ÍCONO DE LUPA ----
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(64, 0, 0, 0),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenedor principal
            Transform.translate(
              offset: const Offset(0, -130),
              child: Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(64, 0, 0, 0),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cuadro degradado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF370B12), Color(0xFFE41335)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "${sucursales.length} Sucursales",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista RESPONSIVA
                    Column(
                      children:
                          sucursales.map((item) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                bool small = constraints.maxWidth < 360;

                                double imageSize =
                                    small
                                        ? screenWidth * 0.25
                                        : screenWidth * 0.3;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(17),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),

                                  child:
                                      small
                                          ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              _buildInfo(
                                                context,
                                                item,
                                                screenWidth,
                                              ),
                                              const SizedBox(height: 10),
                                              _buildImage(item, imageSize),
                                            ],
                                          )
                                          : Row(
                                            children: [
                                              Expanded(
                                                child: _buildInfo(
                                                  context,
                                                  item,
                                                  screenWidth,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _buildImage(item, imageSize),
                                            ],
                                          ),
                                );
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET DE INFO (CORREGIDO)
  Widget _buildInfo(
    BuildContext context,
    Map<String, dynamic> item,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['titulo'],
          style: TextStyle(
            fontSize: screenWidth * 0.043,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              const TextSpan(
                text: "Dirección: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: item['direccion']),
            ],
          ),
        ),

        const SizedBox(height: 4),

        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              const TextSpan(
                text: "Empleados activos: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: item['empleados'].toString()),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.registroScan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.12,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Ver",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: screenWidth * 0.025),
                SvgPicture.asset(
                  'lib/assets/images/flecha.svg',
                  height: screenWidth * 0.028,
                  width: screenWidth * 0.028,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET IMAGEN
  Widget _buildImage(Map<String, dynamic> item, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(94, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(item['imagen'], fit: BoxFit.cover),
      ),
    );
  }
}
