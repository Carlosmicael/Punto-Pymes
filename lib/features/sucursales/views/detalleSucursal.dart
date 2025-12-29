import 'package:flutter/material.dart';
import 'dart:async';

// Constante para fallback
const String defaultImage =
    "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80";

class PantallaSucursal extends StatefulWidget {
  const PantallaSucursal({super.key});

  @override
  State<PantallaSucursal> createState() => _PantallaSucursalState();
}

class _PantallaSucursalState extends State<PantallaSucursal> {
  int currentIndex = 0;
  late final PageController _pageController;
  Timer? _autoScrollTimer;

  int totalImages = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.70);

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || totalImages <= 1 || !_pageController.hasClients) return;

      final nextPage = (currentIndex + 1) % totalImages;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 1. RECUPERAR DATOS COMO MAPA
    final Map<String, dynamic>? sucursal =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (sucursal == null) {
      return const Scaffold(body: Center(child: Text("No se cargaron datos")));
    }

    // Slider
    final List<String> imagenes =
        (sucursal['imagenes'] != null &&
                sucursal['imagenes'] is List &&
                sucursal['imagenes'].isNotEmpty)
            ? List<String>.from(sucursal['imagenes'])
            : [defaultImage];

    totalImages = imagenes.length;

    // Datos visuales
    final List<Map<String, String>> datosVisuales = [
      {"label": "Dirección", "value": sucursal['direccion']},
      {"label": "Teléfono", "value": sucursal['telefono']},
      {"label": "Horario", "value": sucursal['horario']},
      {"label": "Encargado", "value": sucursal['encargado']},
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 90),

            // Header Volver
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text("Volver", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: Text(
                sucursal['nombre'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ===== CARRUSEL COMPLETO =====
            SizedBox(
              height: size.height * 0.32,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagenes.length,
                physics: const BouncingScrollPhysics(),
                padEnds: false,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
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

            const SizedBox(height: 8),

            // ===== INDICADORES =====
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

            const SizedBox(height: 5),

            // ===== DATOS =====
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    datosVisuales
                        .map(
                          (dato) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
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

            const SizedBox(height: 1),

            // ===== BOTÓN VER UBICACIÓN =====
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
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 25,
                  ),
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
