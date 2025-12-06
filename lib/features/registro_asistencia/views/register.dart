import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/attendance_service.dart';

class RegistroEmpleados extends StatefulWidget {
  const RegistroEmpleados({super.key});

  @override
  State<RegistroEmpleados> createState() => _RegistroState();
}

class _RegistroState extends State<RegistroEmpleados> {
  bool showGradient = false;

  void toggleGradient(bool value) {
    setState(() => showGradient = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: CustomRegisterAppBar(showGradient: showGradient),
      body: RegisterBody(onScroll: toggleGradient),
    );
  }
}

// 🔹 APPBAR SEPARADO (Mantener igual)
class CustomRegisterAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showGradient;
  final double? heightFactor;

  const CustomRegisterAppBar({
    super.key,
    required this.showGradient,
    this.heightFactor = 0.15,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // ... (El código de tu AppBar se mantiene) ...
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: showGradient ? const Color(0xFFE81236) : Colors.transparent,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ...
      ),
    );
  }
}

// 🔹 BODY PRINCIPAL - Se convierte a Stateful para cargar datos
class RegisterBody extends StatefulWidget {
  final void Function(bool) onScroll;
  const RegisterBody({super.key, required this.onScroll});

  @override
  State<RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
  // 🚨 Usamos el servicio de verdad (aunque el backend aun no devuelva el historial)
  final AttendanceService _apiService = AttendanceService();

  List<Map<String, dynamic>> _registros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    try {
      // 🚨 Implementación de la llamada real al servicio (asumiendo endpoint /history)
      // Nota: Si no has creado el endpoint de historial en NestJS aún, descomenta la simulación
      /*
      final datos = await _apiService.obtenerHistorial();
      if (mounted) {
        setState(() {
          _registros = datos.map((d) => d as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
      */

      // SIMULACIÓN (Quitar cuando el backend esté listo)
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _registros = [
            {'entrada': '08:00', 'salida': '12:00', 'estado_salida': 'Puntual', 'fecha': '2025-12-01'},
            {'entrada': '13:00', 'salida': '17:00', 'estado_salida': 'Atraso', 'fecha': '2025-12-02'},
            {'entrada': '08:05', 'salida': 'Sin registrar', 'estado_salida': 'Pendiente', 'fecha': '2025-12-03'},
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Manejar error (ej: _registros = [])
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // ... (El resto de variables responsivas y el NotificationListener se mantienen) ...
    final double buttonVertical = height * 0.015;
    final double buttonHorizontal = width * 0.08;
    final double bodyFont = width * 0.035;

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        widget.onScroll(scroll.metrics.pixels > 50);
        return true;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 🔸 Cabecera con degradado
            ClipPath(
              clipper: _CurvedBottomClipper(), // 🚨 Requiere la definición de _CurvedBottomClipper
              child: Container(
                width: width,
                height: height * 0.55,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF370B12), Color(0xFFE41335)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.13), // Ajuste
                      Text(
                        'Total de Registros',
                        style: TextStyle(
                          fontSize: width * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.01),
                      // DATO DINÁMICO
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              '${_registros.length}',
                              style: TextStyle(
                                fontSize: width * 0.15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),

            // 🔸 Cuerpo inferior (LISTA DINÁMICA)
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.07,
                right: width * 0.07,
                bottom: height * 0.02,
              ),
              child: _isLoading
                  ? const Center(child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ))
                  : Column(
                      children: _registros.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> registro = entry.value;

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: height * 0.01),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // Muestra la fecha o un identificador claro
                                'Registro del día: ${registro['fecha']}', 
                                style: TextStyle(
                                  fontSize: width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              
                              // TARJETA DE REGISTRO
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(width * 0.04),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(64, 0, 0, 0),
                                      blurRadius: 20,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // 🚨 FILA NEGRA CON HORAS (COMPLETADA)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildTimeColumn(width, 'Hora de entrada', registro['entrada'], Colors.white),
                                          _buildTimeColumn(width, 'Hora de salida', registro['salida'], Colors.white),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: height * 0.02),

                                    // ESTADO DE LA JORNADA
                                    Text(
                                      'Estado de salida: ${registro['estado_salida']}',
                                      style: TextStyle(
                                        fontSize: bodyFont * 1.1,
                                        fontWeight: FontWeight.w600,
                                        color: registro['estado_salida'] == 'Puntual' ? Colors.green : (registro['estado_salida'] == 'Atraso' ? Colors.orange : Colors.grey),
                                      ),
                                    ),

                                    SizedBox(height: height * 0.02),
                                    
                                    // BOTÓN REGISTRAR
                                    ElevatedButton(
                                      onPressed: () {
                                        // 🚨 Navegación al registro manual/modal
                                        showGeneralDialog(
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          barrierDismissible: false,
                                          barrierLabel: "Registro",
                                          transitionDuration: const Duration(milliseconds: 300),
                                          pageBuilder: (context, animation1, animation2) {
                                            return const RegistroModal(texto: "Registro Manual");
                                          },
                                          // ... (Transitions) ...
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                        padding: EdgeInsets.symmetric(
                                          vertical: buttonVertical,
                                          horizontal: buttonHorizontal,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        elevation: 0,
                                        side: const BorderSide(color: Colors.black, width: 2),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            registro['salida'] == 'Sin registrar' ? "Registrar Salida" : "Ver Detalles",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: bodyFont * 1.1,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          // ... icono
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            SizedBox(height: height * 0.12),
          ],
        ),
      ),
    );
  }

  // Widget helper para las columnas de tiempo
  Widget _buildTimeColumn(double width, String title, String time, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: width * 0.030,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// 🚨 DEFINICIÓN DEL CLIPPER (NECESARIO)
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85); // Empieza la curva más arriba
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.85,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// 🚨 DEFINICIÓN DEL MODAL (NECESARIO)
class RegistroModal extends StatelessWidget {
  final String texto;
  const RegistroModal({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    // ... (Tu diseño del modal aquí)
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(texto),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}