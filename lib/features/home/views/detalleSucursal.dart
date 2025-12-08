import 'package:flutter/material.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';

class PantallaSucursal extends StatefulWidget {
  const PantallaSucursal({super.key});

  @override
  State<PantallaSucursal> createState() => _PantallaSucursalState();
}

class _PantallaSucursalState extends State<PantallaSucursal> {
  final List<String> imagenes = const [
    "https://media.licdn.com/dms/image/v2/D4D22AQFZJZSsWQAhtw/feedshare-shrink_800/B4DZq2djBpHsAg-/0/1763997792917?e=2147483647&v=beta&t=yYAsl2lzVm2XwYbPOwwMaiyYen9ixPTH4pkBpsxDdC4",
    "https://media.licdn.com/dms/image/v2/D4D22AQGEveEKh_UCpA/feedshare-shrink_800/B4DZq2djA.G8Ag-/0/1763997792504?e=2147483647&v=beta&t=vC8iPjbgYD6lcTgeJHtRA2Sl_OJr3hzOt5O9HWQC58I",
    "https://media.licdn.com/dms/image/v2/D4D22AQF_CdPBwP-FKA/feedshare-shrink_800/B4DZq2djCpHsAg-/0/1763997793183?e=2147483647&v=beta&t=qjIC1CJC7ozf5r-vrM6caz-lvkzAqBevM8YjuUQUWfo",
  ];

  int currentIndex = 0; // Para abrir la imagen visible

  // Lista de datos de la sucursal
  final List<Map<String, String>> sucursalDatos = [
    {
      "label": "Dirección",
      "value": "Av. Universitaria y 18 de Noviembre, Loja",
    },
    {"label": "Empleados activos", "value": "35"},
    {"label": "Teléfono", "value": "(07) 257-1100"},
    {"label": "Horario de atención", "value": "Lunes a viernes, 08h00 - 17h00"},
    {"label": "Encargado", "value": "Ing. María Torres"},
    {
      "label": "Servicios",
      "value": "Atención general, recursos humanos, soporte técnico",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 75),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "Volver",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                children: [
                  const Text(
                    "Sucursal Matriz - Centro",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                  height: size.height * 0.32,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.70),
                    itemCount: imagenes.length,
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);

                      if (index == imagenes.length - 1) {
                        Future.delayed(const Duration(milliseconds: 350), () {
                          PageController(viewportFraction: 0.70).jumpToPage(0);
                          setState(() => currentIndex = 0);
                        });
                      }
                    },
                    itemBuilder: (_, index) {
                      final bool isCenter = index == currentIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: isCenter ? 0 : 35,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.7),
                              builder:
                                  (_) => Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        imagenes[currentIndex],
                                        width: size.width * 0.85,
                                        height: size.height * 0.45,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              imagenes[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    imagenes.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: currentIndex == i ? 14 : 10,
                      height: currentIndex == i ? 14 : 10,
                      decoration: BoxDecoration(
                        color:
                            currentIndex == i
                                ? const Color(0xFFE41335)
                                : Colors.grey.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Datos de la sucursal
            Padding(
              padding: const EdgeInsets.all(
                30,
              ), // Aquí ajustas el padding general
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    sucursalDatos
                        .map(
                          (dato) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ), // Padding entre cada dato
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: "${dato['label']}: ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: dato['value']),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Botón "Ver ubicación"
            Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFFE41335), Color(0xFFED6C7E)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Acción del botón
                  },
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: const Text(
                    "Ver ubicación",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
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
