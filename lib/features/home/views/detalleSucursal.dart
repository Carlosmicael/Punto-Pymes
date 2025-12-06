import 'package:flutter/material.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';

class PantallaSucursal extends StatefulWidget {
  const PantallaSucursal({super.key});

  @override
  State<PantallaSucursal> createState() => _PantallaSucursalState();
}

class _PantallaSucursalState extends State<PantallaSucursal> {
  final List<String> imagenes = const [
    "https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?fm=jpg&q=60&w=3000",
    "https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?fm=jpg&q=60&w=3000",
    "https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?fm=jpg&q=60&w=3000",
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
            // Encabezado
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
                const Text("Volver", style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Sucursal Matriz - Centro",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Carrusel con tap
            Stack(
              children: [
                FanCarouselImageSlider.sliderType1(
                  imagesLink: imagenes,
                  isAssets: false,
                  autoPlay: true,
                  userCanDrag: true,
                  sliderHeight: size.height * 0.30,
                  showIndicator: true,
                  imageRadius: 20,
                  imageFitMode: BoxFit.cover,
                  isClickable: false,
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
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
                    onHorizontalDragUpdate: (_) {}, // Mantiene scroll
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Datos de la sucursal
            Padding(
              padding: const EdgeInsets.all(
                25,
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
              child: ElevatedButton.icon(
                onPressed: () {
                  // Acción del botón, por ejemplo abrir Google Maps
                },
                icon: const Icon(Icons.location_on),
                label: const Text("Ver ubicación"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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
