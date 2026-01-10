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

  final AttendanceService _apiService = AttendanceService();

  bool _isLoading = false; // Cambiado a false para mostrar botón "Iniciar"
  bool _isSuccess = false;
  String _title = "Registro de Asistencia";
  String _message = "Presiona el botón para registrar tu entrada o salida";
  Color _statusColor = Colors.grey;

  // Candados locales para esta instancia de pantalla
  bool _responseProcessed = false;
  bool _requestInFlight = false;
  bool _dayCompleted = false; // Nuevo estado para cuando ambos registros existen

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Ya no iniciamos el proceso automáticamente
    // El usuario decidirá cuándo presionar el botón "Iniciar"
  }

  Future<void> _registerAttendance() async {
    // Prevent multiple simultaneous requests
    if (_requestInFlight || _responseProcessed) {
      print(
        '⚠️ Petición ignorada: Ya hay una solicitud en proceso o ya fue procesada',
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _requestInFlight = true;
      });
    }

    try {
      // Small delay to show loading animation
      await Future.delayed(const Duration(milliseconds: 800));

      print('🔍 Obteniendo ubicación del dispositivo...');
      final position = await LocationHandler.obtenerPosicionActual();

      // Debug information
      print('📍 Ubicación obtenida:');
      print('   - Latitud: ${position.latitude}');
      print('   - Longitud: ${position.longitude}');
      print('   - Precisión: ${position.accuracy} metros');

      print('🚀 Enviando petición al servidor...');
      final result = await _apiService.registrarAsistencia(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        // Manejar el caso de petición en progreso
        if (result['errorType'] == 'RequestInProgress') {
          print('⚠️ Petición en progreso detectada, ignorando...');
          setState(() {
            _isLoading = false;
            _requestInFlight = false;
          });
          return;
        }
        
        if (result['success'] == true) {
          _responseProcessed = true;
          print('✅ Registro exitoso: ${result['message']}');
          _handleSuccess(result);
        } else {
          print('❌ Error en el registro: ${result['message']}');
          _handleFailure(result);
        }
      }
    } catch (e) {
      print('🔥 Error crítico: $e');
      if (mounted) _handleCriticalError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _requestInFlight = false;
        });
      }
    }
  }

  /// Maneja los casos de éxito, incluyendo 'atraso' y 'salida anticipada'.
  void _handleSuccess(Map<String, dynamic> result) {
    final tipo = (result['tipo'] ?? '').toString();
    final estado = (result['estado'] ?? '').toString();
    final hora = (result['hora'] ?? '').toString();

    setState(() {
      _isLoading = false; // Asegurar que se detenga la animación de carga
      _isSuccess = true;
      _statusColor = Colors.green.shade700;

      if (tipo == 'entrada') {
        _title = "¡Entrada Registrada!";
        if (estado == 'atraso') {
          _message =
              "Tu entrada ha sido registrada a las $hora con retraso. Por favor, revisa tu horario.";
          _statusColor = Colors.orange.shade700;
        } else {
          _message =
              "Tu entrada ha sido registrada correctamente a las $hora.";
        }
      } else if (tipo == 'salida') {
        _title = "¡Salida Registrada!";
        if (estado == 'salida anticipada') {
          _message =
              "Tu salida ha sido registrada a las $hora como anticipada. Consulta con tu supervisor.";
          _statusColor = Colors.orange.shade700;
        } else {
          _message =
              "Tu salida ha sido registrada correctamente a las $hora.";
        }
      }
    });
  }

  /// Maneja los fallos lógicos del servidor (fuera de rango, ya registrado, etc.).
  void _handleFailure(Map<String, dynamic> result) {
    setState(() {
      _isLoading = false; // Asegurar que se detenga la animación de carga
      _isSuccess = false;
      _statusColor = Colors.red.shade700;
      _title = "Fallo en el Registro";

      final errorMessage = (result['message'] ?? 'Error desconocido').toString().toLowerCase(); // Convertimos a minúsculas para comparar mejor
      final statusCode = int.tryParse(result['statusCode']?.toString() ?? '');
      final errorType = (result['errorType'] ?? '').toString();

      // PRIORIDAD 1: Fuera de rango geográfico (Debe ir primero)
      if (errorMessage.contains('fuera de rango') || errorMessage.contains('distancia')) {
        _title = "Fuera de Rango";
        
        final distanceMatch = RegExp(r'([\d.]+)m').firstMatch(errorMessage);
        final distance = distanceMatch?.group(1) ?? 'más';
        
        _message = "Te encuentras a $distance metros de la sucursal. Acércate más para registrar tu asistencia.";
        _statusColor = Colors.orange.shade700;
        // No marcamos como _responseProcessed para que muestre "Reintentar" y permita volver a intentar
        return;
      }

      // PRIORIDAD 2: Duplicados (409 Conflict)
      if (statusCode == 409 || errorType == 'Conflict') {
        if (errorMessage.contains('entrada')) {
          _title = "Aviso: Entrada Ya Registrada";
          _message = "Ya registraste tu entrada hoy. No olvides registrar tu salida al terminar.";
          _statusColor = Colors.blue.shade700;
        } else if (errorMessage.contains('salida')) {
          _title = "Aviso: Salida Ya Registrada";
          _message = "Ya has registrado tu salida anteriormente.";
          _statusColor = Colors.blue.shade700;
        }
        return;
      }

      // PRIORIDAD 3: Jornada completada (403 Forbidden o mensajes específicos)
      // Buscamos la frase completa para evitar falsos positivos
      if (statusCode == 403 || 
          errorMessage.contains('jornada completa') || 
          errorMessage.contains('ya tienes entrada y salida')) {
        _dayCompleted = true; 
        _title = "Jornada Completada";
        _statusColor = Colors.blue.shade700;
        _message = "Has completado tus registros de hoy. ¡Buen trabajo!";
        return;
      }

      // Otros casos...
      if (errorMessage.contains('día laboral')) {
        _message = "Hoy no es un día laboral según tu jornada.";
        _statusColor = Colors.orange.shade700;
        return;
      }

      _message = "Error: ${result['message']}";
    });
  }

  /// Maneja los errores antes de la comunicación con el servidor (GPS, Permisos).
  void _handleCriticalError(String error) {
    setState(() {
      _isLoading = false; // Asegurar que se detenga la animación de carga
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
                    "Registro GPS",
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
                                                if (_isSuccess || _dayCompleted) {
                                                  // LÓGICA: En éxito o jornada completada, redirigir a pantalla principal
                                                  Navigator.pushReplacementNamed(
                                                    context,
                                                    '/home', // Ruta a HomeLayout/HomeScreen
                                                  );
                                                } else if (_responseProcessed) {
                                                  // LÓGICA: En error, reintentar (Restablecer el estado y llamar a _registerAttendance)
                                                  setState(() {
                                                    _isLoading = true;
                                                    _title = "Procesando...";
                                                    _message =
                                                        "Obteniendo ubicación y validando...";
                                                    _statusColor = Colors.grey;
                                                  });
                                                  _registerAttendance();
                                                } else {
                                                  // LÓGICA: Primer intento - Iniciar registro
                                                  setState(() {
                                                    _isLoading = true;
                                                    _title = "Procesando...";
                                                    _message =
                                                        "Obteniendo ubicación y validando...";
                                                    _statusColor = Colors.grey;
                                                  });
                                                  _registerAttendance();
                                                }
                                              }, // Iniciar, Salir, Redirigir o reintentar
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
                                              _isSuccess 
                                                  ? "Aceptar" 
                                                  : _dayCompleted
                                                      ? "Salir"
                                                      : _responseProcessed 
                                                          ? "Reintentar" 
                                                          : "Iniciar",
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
