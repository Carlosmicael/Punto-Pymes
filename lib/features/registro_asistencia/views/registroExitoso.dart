import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Importaciones de tus nuevos servicios
import '../utils/location_handler.dart';
import '../services/attendance_service.dart';

class RegistroExitosoScreen extends StatefulWidget {
  const RegistroExitosoScreen({super.key});

  @override
  State<RegistroExitosoScreen> createState() => _RegistroExitosoScreenState();
}

class _RegistroExitosoScreenState extends State<RegistroExitosoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  // Lógica de Estado
  final AttendanceService _apiService = AttendanceService();
  bool _isLoading = true;
  bool _isSuccess = false;
  String _title = "Procesando...";
  String _message = "Obteniendo ubicación y validando...";
  Color _statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    // Configuración de animación original
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // INICIAR EL PROCESO AUTOMÁTICO
    _registerAttendance();
  }

  /// Función principal de lógica
  Future<void> _registerAttendance() async {
    try {
      // 1. Obtener Ubicación (Puede lanzar una excepción por GPS o Permisos)
      final position = await LocationHandler.obtenerPosicionActual();

      // -----------------------------------------------------------------
      // ✅ UBICACIÓN
      // -----------------------------------------------------------------
      print('--- UBICACIÓN DEL DISPOSITIVO ---');
      print('Latitud: ${position.latitude}');
      print('Longitud: ${position.longitude}');
      print('Precisión (m): ${position.accuracy}');
      print('---------------------------------');
      // -----------------------------------------------------------------

      // 2. Llamar al Servicio
      final result = await _apiService.registrarAsistencia(
        position.latitude,
        position.longitude,
      );

      // 3. Manejo de Respuesta del Backend
      if (result['success'] == true) {
        _handleSuccess(result);
      } else {
        _handleFailure(result);
      }
    } catch (e) {
      // 4. Manejo de Errores Críticos (GPS, Permisos)

      // 🚨 Imprimir el error completo antes de clasificarlo
      print('--- ERROR CRÍTICO CAPTURADO ---');
      print('Excepción completa: $e'); // ✅ IMPRIME LA EXCEPCIÓN COMPLETA AQUÍ
      print('------------------------------');

      _handleCriticalError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Maneja los casos de éxito, incluyendo 'atraso' y 'salida anticipada'.
  void _handleSuccess(Map<String, dynamic> result) {
    String tipo = result['tipo'] as String;
    String estado = result['estado'] as String;
    String hora = result['hora'] as String;

    setState(() {
      _isSuccess = true;
      _statusColor = Colors.green.shade700; // Color por defecto

      if (tipo == 'entrada') {
        _title = "¡Registro de Entrada Exitoso!";

        if (estado == 'atraso') {
          _message =
              "Tu entrada a las **$hora** fue registrada con **atraso**. Por favor, revisa tu horario.";
          _statusColor = Colors.orange.shade700; // Advertencia
        } else {
          // estado 'válido'
          _message =
              "Tu entrada ha sido registrada correctamente a las **$hora**.";
        }
      } else if (tipo == 'salida') {
        _title = "¡Registro de Salida Exitoso!";

        if (estado == 'salida anticipada') {
          _message =
              "Tu salida a las **$hora** fue registrada como **anticipada**. Consulta con tu supervisor.";
          _statusColor = Colors.orange.shade700; // Advertencia
        } else {
          // estado 'válido'
          _message =
              "Tu salida ha sido registrada correctamente a las **$hora**.";
        }
      }
    });
  }

  /// Maneja los fallos lógicos del servidor (fuera de rango, ya registrado, etc.).
  void _handleFailure(Map<String, dynamic> result) {
    setState(() {
      _isSuccess = false;
      _statusColor = Colors.red.shade700; // Color por defecto de error
      _title = "Fallo en el Registro";

      String errorMessage =
          result['message'] as String; // Mensaje de la excepción NestJS

      if (errorMessage.contains('fuera de rango')) {
        _message =
            "No pudimos registrar tu asistencia. Estás **fuera del rango geográfico** de la sucursal asignada.";
      } else if (errorMessage.contains('día laboral')) {
        _message =
            "Hoy no es un día laboral según tu jornada asignada. Contacta a RRHH si es un error.";
      } else if (errorMessage.contains('Ya tienes entrada y salida')) {
        _message =
            "Ya tienes un registro de entrada y salida para el día de hoy. Día completado.";
        _statusColor = Colors.blue.shade700; // Aviso informativo
        _title = "Aviso Importante";
      } else if (errorMessage.contains('Ya existe una entrada')) {
        _message =
            "Ya tienes un registro de **entrada** para el día de hoy. Intenta registrar tu **salida**.";
        _title = "Aviso: Entrada Duplicada";
      } else {
        _message = "Ocurrió un error inesperado: $errorMessage";
      }
    });
  }

  /// Maneja los errores antes de la comunicación con el servidor (GPS, Permisos).
  void _handleCriticalError(String error) {
    setState(() {
      _isSuccess = false;
      _statusColor = Colors.red.shade700;
      _title = "Error Crítico";

      if (error.contains('GPS está desactivado')) {
        _message =
            "El GPS está desactivado. Por favor, enciéndelo para registrar tu asistencia.";
      } else if (error.contains('Permisos de ubicación denegados')) {
        _message =
            "Necesitamos los permisos de ubicación para registrar tu asistencia. Por favor, actívalos.";
      } else {
        _message =
            "Ocurrió un error inesperado al obtener tu ubicación: $error";
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _controller.reverse();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ... (Variables responsivas originales se mantienen igual) ...
    final double topText = size.height * 0.17;
    final double bigCircle = size.width * 0.20;
    final double bigIcon = size.width * 0.1;
    final double whiteBoxHeight = size.height * 0.75;
    final double buttonVertical = size.height * 0.015;
    final double buttonHorizontal = size.width * 0.15;
    final double smallCircle = size.width * 0.080;
    final double svgSize = size.width * 0.020;
    final double titleFont = size.width * 0.055;
    final double bodyFont = size.width * 0.035;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFE81236), Color(0xFF7B1522)],
            ),
          ),
          child: Stack(
            children: [
              // ... (Texto "Automatico" original se mantiene) ...
              Positioned(
                top: topText,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Text(
                    "Automatico",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.037,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ),

              SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    // ... (Decoración del contenedor blanco original) ...
                    width: size.width,
                    height: whiteBoxHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(size.width * 0.22),
                        topRight: Radius.circular(size.width * 0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.47),
                          blurRadius: size.width * 0.12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.1),

                            // CÍRCULO CON ESTADO DINÁMICO
                            Container(
                              width: bigCircle,
                              height: bigCircle,
                              decoration: BoxDecoration(
                                // COLOR DINÁMICO
                                color: _isLoading ? Colors.grey : _statusColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.46),
                                    blurRadius: size.width * 0.12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                // ÍCONO DINÁMICO
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : Icon(
                                          _isSuccess
                                              ? Icons.check
                                              : Icons.priority_high,
                                          color: Colors.white,
                                          size: bigIcon,
                                        ),
                              ),
                            ),

                            SizedBox(height: size.height * 0.02),

                            // TÍTULO DINÁMICO
                            Text(
                              _title,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: titleFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: size.height * 0.02),

                            // MENSAJE DINÁMICO
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                _message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: bodyFont,
                                ),
                              ),
                            ),

                            SizedBox(height: size.height * 0.03),

                            // BOTONES (Solo habilitados si terminó de cargar)
                            IgnorePointer(
                              ignoring: _isLoading,
                              child: Column(
                                children: [
                                  // ... (Botón "Aceptar" Negro original con onTap modificado) ...
                                  SizedBox(
                                    width: size.width * 0.55,
                                    child: GestureDetector(
                                      onTap:
                                          _isLoading
                                              ? null // Deshabilita el toque mientras carga
                                              : () {
                                                if (_isSuccess) {
                                                  // LÓGICA: En éxito, simplemente cerrar la pantalla
                                                  Navigator.of(context).pop();
                                                } else {
                                                  // LÓGICA: En error, reintentar (Restablecer el estado y llamar a _registerAttendance)
                                                  setState(() {
                                                    _isLoading = true;
                                                    _title = "Procesando...";
                                                    _message =
                                                        "Obteniendo ubicación y validando...";
                                                    _statusColor = Colors.grey;
                                                  });
                                                  _registerAttendance();
                                                }
                                              }, // Cerrar al aceptar
                                      child: Container(
                                        // ... (Estilos originales botón negro) ...
                                        padding: EdgeInsets.symmetric(
                                          vertical: buttonVertical,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.44,
                                              ),
                                              blurRadius: size.width * 0.06,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Aceptar",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: bodyFont * 1.15,
                                                letterSpacing: 2.5,
                                              ),
                                            ),
                                            SizedBox(width: size.width * 0.07),
                                            Container(
                                              width: smallCircle,
                                              height: smallCircle,
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                  78,
                                                  187,
                                                  187,
                                                  187,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  "lib/assets/images/Siguiente.svg",
                                                  width: svgSize,
                                                  height: svgSize,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: size.height * 0.02),

                                  // Si hay error, podríamos cambiar este botón a "Reintentar"
                                  if (!_isSuccess && !_isLoading)
                                    GestureDetector(
                                      onTap: _registerAttendance,
                                      child: SizedBox(
                                        width: size.width * 0.55,
                                        child: Container(
                                          // ... (Estilos botón blanco borde negro) ...
                                          padding: EdgeInsets.symmetric(
                                            vertical: buttonVertical,
                                            horizontal: buttonHorizontal,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              // LÓGICA: Mostrar estado de carga, ACEPTAR si es éxito, REINTENTAR si es error
                                              _isLoading
                                                  ? "PROCESANDO"
                                                  : _isSuccess
                                                  ? "ACEPTAR"
                                                  : "REINTENTAR",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: bodyFont * 1.2,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 2.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
