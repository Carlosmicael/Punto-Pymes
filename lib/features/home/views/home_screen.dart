import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:auth_company/routes/app_routes.dart';

// -------------------- AppBar personalizado --------------------
class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(300);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Alturas y tamaños dinámicos
    final appBarHeight = (screenHeight * 0.35).clamp(250.0, 420.0);
    final svgSize = appBarHeight * 0.7;
    final iconSize = appBarHeight * 0.12;
    final categoryHeight = appBarHeight * 0.40;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: Container(
        height: appBarHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFE41335), Color(0xFF370B12)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              right: -20,
              child: SizedBox(
                width: svgSize,
                height: svgSize,
                child: Opacity(
                  opacity: 0.5,
                  child: SvgPicture.asset(
                    'lib/assets/images/huella.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: appBarHeight * 0.25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Row(
                    children: [
                      SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: SvgPicture.asset('lib/assets/images/Home.svg'),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Flexible(
                        child: Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (screenWidth * 0.08 / textScale).clamp(
                              24.0,
                              38.0,
                            ),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: appBarHeight * 0.1),
                SizedBox(
                  height: categoryHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.22,
                    ),
                    itemCount: categorias.length,
                    separatorBuilder:
                        (_, __) => SizedBox(width: screenWidth * 0.04),
                    itemBuilder: (context, index) {
                      final cat = categorias[index];
                      return Column(
                        children: [
                          Text(
                            cat['nombre'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: categoryHeight * 0.1),

                          // 🔥 Animación secuencial aquí 🔥
                          PulseButton(
                            delay:
                                index *
                                350, // cada botón se anima uno tras otro
                            child: TextButton(
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    cat['ruta']!,
                                  ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(86, 0, 0, 0),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: iconSize * 0.8,
                                  backgroundColor: const Color.fromARGB(
                                    134,
                                    255,
                                    255,
                                    255,
                                  ),
                                  child: SvgPicture.asset(
                                    cat['asset'] ??
                                        'assets/icons/placeholder.svg',
                                    width: iconSize * 0.5,
                                    height: iconSize * 0.5,
                                  ),
                                ),
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
    );
  }
}

// -------------------- Body --------------------
class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    final double paddingH = screenWidth * 0.05;
    final double boxHeight = (screenHeight * 0.09).clamp(65.0, 80.0);

    return SingleChildScrollView(
      key: const PageStorageKey("Home"),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.38),
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
              viewportFraction: 0.85,
              aspectRatio: 16 / 9,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),

          // 🔹 Últimas asistencias
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingH),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
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
                  Text(
                    "Últimas asistencias",
                    style: TextStyle(
                      fontSize: (screenWidth * 0.045 / textScale).clamp(16, 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Column(
                    children:
                        asistencias.map((a) {
                          return Container(
                            margin: EdgeInsets.only(
                              bottom: screenHeight * 0.015,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.05,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(27),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(2, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a['fecha']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: (screenWidth *
                                                0.035 /
                                                textScale)
                                            .clamp(13, 16),
                                      ),
                                    ),
                                    Text(
                                      a['hora']!,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: (screenWidth *
                                                0.032 /
                                                textScale)
                                            .clamp(12, 14),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Registrado",
                                  style: TextStyle(
                                    fontSize: (screenWidth * 0.035 / textScale)
                                        .clamp(13, 16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width: screenWidth * 0.25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE41335),
                                        Color(0xFF370B12),
                                      ],
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
                                    child: Text(
                                      "Ver detalle",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: (screenWidth * 0.03).clamp(
                                          12,
                                          14,
                                        ),
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

          SizedBox(height: screenHeight * 0.04),
          _buildInfoBox(
            screenWidth,
            boxHeight,
            "Número de asistencias del mes:",
            "12",
          ),
          _buildInfoBox(
            screenWidth,
            boxHeight,
            "Porcentaje de asistencia del mes:",
            "85%",
          ),
          _buildInfoBox(
            screenWidth,
            boxHeight,
            "Número de faltas del mes:",
            "2",
          ),
          SizedBox(height: screenHeight * 0.12),
        ],
      ),
    );
  }

  Widget _buildInfoBox(
    double screenWidth,
    double height,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: height * 0.7,
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
              width: screenWidth * 0.07,
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
            SizedBox(width: screenWidth * 0.05),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: (screenWidth * 0.04).clamp(14.0, 17.0),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF370B12),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.05),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: (screenWidth * 0.055).clamp(18.0, 24.0),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE41335),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//pantallaPrincipal//
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // Esto es clave para el diseño
      appBar: CustomHomeAppBar(),
      body: HomeBody(),
    );
  }
}

// -------------------- Clase para categorías --------------------
class Category {
  final String name;
  final String imageUrl;
  Category({required this.name, required this.imageUrl});
}

// -------------------- Datos globales --------------------
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
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYaNAmcHAKJ1Sj0bNPhceqR0Nd1roPsbrhrg&s',
  ),
  Category(
    name: 'Categoria 5',
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAvOTdPxzNS5A_qxE_wiDMo6qD55nsEFU7LA&s',
  ),
];

final CarouselSliderController buttonCarouselController =
    CarouselSliderController();

final List<Map<String, String>> categorias = [
  {
    "nombre": "Sucursal",
    "asset": "lib/assets/images/Sucursal.svg",
    "ruta": AppRoutes.capas,
  },
  {
    "nombre": "Calendar",
    "asset": "lib/assets/images/Calendar.svg",
    "ruta": AppRoutes.capas,
  },
  {
    "nombre": "Vacaciones",
    "asset": "lib/assets/images/Vacaciones.svg",
    "ruta": AppRoutes.capas,
  },
  {
    "nombre": "Horario",
    "asset": "lib/assets/images/Horario.svg",
    "ruta": AppRoutes.capas,
  },
  {
    "nombre": "Zona",
    "asset": "lib/assets/images/Zona.svg",
    "ruta": AppRoutes.capas,
  },
  {
    "nombre": "Registro Manual",
    "asset": "lib/assets/images/Registro.svg",
    "ruta": AppRoutes.registroManual,
  },
  {
    "nombre": "Homework",
    "asset": "lib/assets/images/Homework.svg",
    "ruta": AppRoutes.capas,
  },
];

final List<Map<String, String>> asistencias = [
  {"fecha": "10/11/2025", "hora": "08:30 AM"},
  {"fecha": "09/11/2025", "hora": "09:00 AM"},
  {"fecha": "08/11/2025", "hora": "10:15 AM"},
  {"fecha": "07/11/2025", "hora": "08:00 AM"},
];

class PulseButton extends StatefulWidget {
  final Widget child;
  final int delay; // milisegundos

  const PulseButton({super.key, required this.child, required this.delay});

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> glowOpacity;
  late Animation<double> glowBlur;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    glowOpacity = Tween<double>(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    glowBlur = Tween<double>(
      begin: 0.0,
      end: 18.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    scale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () async {
      await controller.forward();
      await controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Transform.scale(
          scale: scale.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(glowOpacity.value),
                  blurRadius: glowBlur.value,
                  spreadRadius: glowBlur.value * 0.35,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
