import 'package:auth_company/features/auth/login/login_service.dart';
import 'package:auth_company/features/home/home_layout.dart';
import 'package:auth_company/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Necesario para SvgPicture

import 'package:auth_company/features/user/services/user_service.dart'; 
import 'package:auth_company/features/kpis/views/kpis.dart';           

class AppDrawer extends StatelessWidget {
  // 1. PROPIEDADES ACTUALIZADAS (Tomadas del drawer.dart original)
  final Widget? miniChild;
  final void Function(Widget widget)? onMiniaturaSelected;

  // Se remueve 'this.screenImage'
  const AppDrawer({super.key, this.miniChild, this.onMiniaturaSelected});






  // 2. Función interna para manejar la navegación de KPIs
  Future<void> _navigateToKpis(BuildContext context) async {
    final userService = UserService();
    
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    final perfil = await userService.getProfileRegistroManual();

    if (!context.mounted) return;
    Navigator.pop(context); // Quitar el loading

    if (perfil != null) {
      // Navegamos directamente a la pantalla de KPIs envuelta en el Layout
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeLayout(
            child: KpisScreen(
              companyId: perfil['empresaId'] ?? '',
              employeeId: perfil['uid'] ?? '',
            ),
          ),
        ),
      );
    }
  }



  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Variables de diseño del archivo copia
    final double drawerWidth = size.width;
    final double previewWidth = drawerWidth * 0.20;
    final double previewHeight = size.height * 0.55;

    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    // 2. Lista de categorías del archivo copia (ejemplo, se asume que las rutas y assets son correctos)
    final List<Map<String, String>> categorias = [
      {
        "nombre": "Home",
        "asset": "lib/assets/images/Home.svg",
        "ruta": AppRoutes.home,
      },
      {
        "nombre": "Sucursal",
        "asset": "lib/assets/images/Sucursal.svg",
        "ruta": AppRoutes.registroExitoso, // Asumo esta ruta de ejemplo
      },
      {
        "nombre": "Lista de Asistencias",
        "asset": "lib/assets/images/Calendar.svg",
        "ruta": AppRoutes.registroList, // Asumo esta ruta de ejemplo
      },
      {
        "nombre": "Vacaciones",
        "asset": "lib/assets/images/Vacaciones.svg",
        "ruta": AppRoutes.notificaciones, // Asumo esta ruta de ejemplo
      },
      {
        "nombre": "Registro Scan",
        "asset": "lib/assets/images/Horario.svg",
        "ruta": AppRoutes.registroScan, // Asumo esta ruta de ejemplo
      },
      {
        "nombre": "Horario",
        "asset": "lib/assets/images/Horario.svg",
        "ruta": AppRoutes.horario, // Asumo esta ruta de ejemplo
      },
      {
        "nombre": "Zona",
        "asset": "lib/assets/images/Zona.svg",
        "ruta": AppRoutes.notificaciones, // Asumo esta ruta de ejemplo
      },
      {
        "nombre": "Registro Sensor",
        "asset": "lib/assets/images/Registro.svg",
        "ruta": AppRoutes.registroExitoso, // Asumo esta ruta de ejemplo
      },

      {"nombre": "KPIs", "asset": "lib/assets/images/Homework.svg", "ruta": "special_kpi"},
    ];

    return Drawer(
      width: drawerWidth, // Drawer de ancho completo
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Container(
        // Fondo con gradiente del archivo copia
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFF3C0A13),
              Color(0xFFA21C34),
              Color(0xFFE41335),
              Color(0xFFE81236),
              Color(0xFFEB455E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ───────── SVG de fondo (Huella) ─────────
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: 0.5,
                child: SvgPicture.asset(
                  'lib/assets/images/huella3.svg', // Asume que este asset existe
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                ),
              ),
            ),

            Column(
              children: [
                // ─────────────── Header: Imagen circular + nombre + botón cerrar ───────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 25,
                  ),
                  color: const Color.fromARGB(0, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Imagen circular + texto
                      Row(
                        children: [
                          Container(
                            width: size.width * 0.10,
                            height: size.width * 0.10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://ichef.bbci.co.uk/ace/ws/640/cpsprodpb/9db5/live/48fd9010-c1c1-11ee-9519-97453607d43e.jpg.webp',
                                ), // Imagen de perfil de ejemplo
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Carlos Lopez", // Nombre de usuario de ejemplo
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Botón cerrar
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: size.width * 0.055,
                      ),
                    ],
                  ),
                ),


















                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 0),
                      child: Row(
                        children: [
                          // ───────── Columna de Menú (SVG + Texto) ─────────
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Lista de categorías
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: categorias.map((item) {
                                        final bool isSelected = item['ruta'] == currentRoute;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          child: InkWell(
                                            onTap: () {
                                              // --- LÓGICA DE NAVEGACIÓN MODIFICADA ---
                                              if (item['nombre'] == "KPIs") {
                                                _navigateToKpis(context);
                                              } else {
                                                Navigator.pop(context); // Cierra el drawer
                                                Navigator.pushNamed(
                                                  context,
                                                  item['ruta']!,
                                                );
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                // Punto indicador de ruta actual
                                                if (isSelected)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    margin: const EdgeInsets.only(right: 8),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  )
                                                else
                                                  const SizedBox(width: 8),

                                                const SizedBox(width: 15),
                                                
                                                // SVG del menú
                                                SvgPicture.asset(
                                                  item['asset']!,
                                                  width: MediaQuery.of(context).size.width * 0.05,
                                                  height: MediaQuery.of(context).size.width * 0.05,
                                                  colorFilter: const ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                                
                                                const SizedBox(width: 15),

                                                // Texto del menú
                                                Flexible(
                                                  child: Text(
                                                    item['nombre']!,
                                                    style: TextStyle(
                                                      fontSize: MediaQuery.of(context).size.width * 0.035,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),

















                                // ───────── Opción de Cerrar Sesión (con lógica funcional) ─────────
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(context); // Cierra el Drawer

                                    // Lógica del archivo original (drawer.dart)
                                    await LoginService().clearToken();
                                    print("Token eliminado correctamente");

                                    // Navegar al login
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'lib/assets/images/Logout.svg', // Asume que este asset existe
                                        width: size.width * 0.05,
                                        height: size.width * 0.05,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          "Logout",
                                          style: TextStyle(
                                            fontSize: size.width * 0.035,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // 3. SECCIÓN DE MINIATURA CON miniChild (Tomada de drawer.dart original)
                        // Se mantiene solo la miniatura más grande para simplificar
                        if (miniChild != null)
                          GestureDetector(
                            onTap: () {
                              if (onMiniaturaSelected != null &&
                                  miniChild != null) {
                                // Llama a la función si está definida
                                onMiniaturaSelected!(miniChild!);
                              }
                            },
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width:
                                      previewWidth, // Usando el tamaño calculado
                                  height:
                                      previewHeight, // Usando el tamaño calculado
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(22),
                                      bottomLeft: Radius.circular(22),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topLeft,
                                          child: SizedBox(
                                            width: size.width,
                                            height: size.height,
                                            child:
                                                miniChild ??
                                                Container(
                                                  color: const Color.fromARGB(
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        Container(color: Colors.transparent),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          // Widget alternativo si la miniatura no está disponible (adaptado)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
