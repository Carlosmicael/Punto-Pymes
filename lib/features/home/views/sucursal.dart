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
            const SizedBox(height: 90),
            // Fila SVG + título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    child: SvgPicture.asset(
                      'lib/assets/images/Sucursal.svg',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Sucursal',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cuadro azul
            Container(width: size.width, height: 280, color: Colors.blue),
            Transform.translate(
              offset: const Offset(0, -60), // lo sube para superponerse
              child: Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Número de sucursales
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
                        "${sucursales.length} sucursales",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: screenWidth * 0.05,

                          fontWeight: FontWeight.bold,
                          letterSpacing: 6.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Lista de sucursales
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sucursales.length,
                      itemBuilder: (context, index) {
                        final item = sucursales[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(10),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['titulo'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "Dirección: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: item['direccion']),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "Empleados activos: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: item['empleados'].toString(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            item['ruta'],
                                          );
                                        },
                                        icon: SvgPicture.network(
                                          'https://upload.wikimedia.org/wikipedia/commons/2/29/Double_arrow_icon.svg', // doble flecha
                                          height: 20,
                                          width: 20,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Ver",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          shadowColor: Colors.black87,
                                          elevation: 6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item['imagen'],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
