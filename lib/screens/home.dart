import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';

class Category {
  final String name;
  final String imageUrl;
  Category({required this.name, required this.imageUrl});
}

class Home extends StatelessWidget {
  Home({super.key});

  final List<Category> categorias1 = [
    Category(
      name: 'Categoria 1',
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW0lQzMlQTFnZW5lcyUyMGltcHJlc2lvbmFudGVzfGVufDB8fDB8fHww&fm=jpg&q=60&w=3000',
    ),
    Category(
      name: 'Categoria 2',
      imageUrl:
          'https://cdn.pixabay.com/photo/2023/03/16/08/42/camping-7856198_640.jpg',
    ),
    Category(
      name: 'Categoria 3',
      imageUrl:
          'https://media.istockphoto.com/id/636379014/es/foto/manos-la-formaci%C3%B3n-de-una-forma-de-coraz%C3%B3n-con-silueta-al-atardecer.jpg?s=612x612&w=0&k=20&c=R2BE-RgICBnTUjmxB8K9U0wTkNoCKZRi-Jjge8o_OgE=',
    ),
    Category(
      name: 'Categoria 4',
      imageUrl:
          'https://ichef.bbci.co.uk/ace/ws/640/cpsprodpb/9db5/live/48fd9010-c1c1-11ee-9519-97453607d43e.jpg.webp',
    ),
    Category(
      name: 'Categoria 5',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAvOTdPxzNS5A_qxE_wiDMo6qD55nsEFU7LA&s',
    ),
  ];

  final CarouselSliderController buttonCarouselController =
      CarouselSliderController();

  final List<Map<String, String>> categorias = const [
    {"nombre": "Sucursal", "asset": "lib/assets/Sucursal.svg"},
    {"nombre": "Calendar", "asset": "lib/assets/Calendar.svg"},
    {"nombre": "Vacaciones", "asset": "lib/assets/Vacaciones.svg"},
    {"nombre": "Horario", "asset": "lib/assets/Horario.svg"},
    {"nombre": "Zona", "asset": "lib/assets/Zona.svg"},
  ];

  final List<Map<String, String>> asistencias = [
    {"fecha": "10/11/2025", "hora": "08:30 AM"},
    {"fecha": "09/11/2025", "hora": "09:00 AM"},
    {"fecha": "08/11/2025", "hora": "10:15 AM"},
    {"fecha": "10/11/2025", "hora": "08:30 AM"},
    {"fecha": "09/11/2025", "hora": "09:00 AM"},
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    // Altura total del AppBar
    final double appBarHeight = (height * 0.43).clamp(260.0, 360.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          height: appBarHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFFE41335), Color(0xFF370B12)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // SVG grande arriba derecha
              Positioned(
                top: 0,
                right: -20,
                child: SizedBox(
                  width: appBarHeight * 0.70,
                  height: appBarHeight * 0.70,
                  child: SvgPicture.asset(
                    'lib/assets/1.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  // titulo home
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 50),
                      SizedBox(
                        width: appBarHeight * 0.10,
                        height: appBarHeight * 0.10,
                        child: SvgPicture.asset('lib/assets/Home.svg'),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (width * 0.08).clamp(30.0, 40.0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      itemCount: categorias.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final cat = categorias[index];

                        return Column(
                          children: [
                            Text(
                              cat['nombre'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(86, 0, 0, 0),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: const Color.fromARGB(
                                  134,
                                  255,
                                  255,
                                  255,
                                ),
                                child: SvgPicture.asset(
                                  cat['asset'] ??
                                      'assets/icons/placeholder.svg',
                                  width: 25, // tamaño del SVG
                                  height: 25,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 400),
            CarouselSlider(
              items:
                  categorias1
                      .map(
                        (cat) => ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            cat.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      )
                      .toList(),
              controller: buttonCarouselController,
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                aspectRatio: 20 / 9,
                initialPage: 0,
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Recuadro grande de "Últimas asistencias"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Últimas asistencias",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Lista de asistencias
                    Column(
                      children:
                          asistencias.map((asistencia) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(2, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Fecha y hora (izquierda)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        asistencia['fecha']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        asistencia['hora']!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Título (centro)
                                  const Text(
                                    "Registrado",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  // Botón (derecha)
                                  Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE41335),
                                          Color(0xFF370B12),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black38,
                                          blurRadius: 5,
                                          offset: Offset(2, 3),
                                        ),
                                      ],
                                    ),
                                    child: TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "Ver detalle",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ▫️ Recuadro lateral degradado
                    Container(
                      width: 30,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF370B12), Color(0xFFE41335)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // ▫️ Texto principal
                    const Expanded(
                      child: Text(
                        "Número de asistencias del mes:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF370B12),
                        ),
                      ),
                    ),
                    // ▫️ Número (dinámico más adelante)
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        "12", // 🔹 valor representativo
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE41335),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:
              // 🔸 Recuadro 2 - Porcentaje de asistencia del mes
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF370B12), Color(0xFFE41335)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        "Porcentaje de asistencia del mes:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF370B12),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        "85%", // 🔹 valor representativo
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE41335),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // 🔸 Recuadro 3 - Número de faltas del mes
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF370B12), Color(0xFFE41335)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        "Número de faltas del mes:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF370B12),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        "2", // 🔹 valor representativo
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE41335),
                        ),
                      ),
                    ),
                  ],
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
