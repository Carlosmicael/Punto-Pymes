import 'dart:io';
import 'dart:ui';
import 'package:auth_company/features/auth/register/register_service.dart';
import 'package:auth_company/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Importar las secciones
import 'secciones/header_section.dart';
import 'secciones/form_section.dart';
import 'secciones/location_section.dart';
import 'secciones/image_section.dart';
import 'secciones/actions_section.dart';
import 'utils/default_values.dart';

// Importar el modelo centralizado
import 'models/genero.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores y estados (permanecen aquí)
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  int _currentPage = 0;
  bool _obscurePassword = true;
  bool _obscurePassword2 = true;
  bool _isFinished = false;

  //campos de formularios para el registro//
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _sucursalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Genero? _selectedGender = Genero.masculino;
  DateTime _selectedDate = DateTime.now();

  ///mapa localizacion///
  LatLng _mapCenter = const LatLng(0, 0);
  final Set<Marker> _markers = {};
  bool _isKeyboardVisible = false;
  bool _locationDenied = false;

  ///selector de imagenes//
  File? _imageFile;

  // 1. Inicializar el servicio
  final RegisterService _registerService = RegisterService();

  // Estados para el flujo de validación
  bool _isLoading = false;
  Map<String, dynamic>? _preRegistroData;
  bool _cedulaValidada = false;

  // Función para seleccionar fecha
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate, // Usamos la variable con guion bajo que ya tienes
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'SELECCIONE FECHA DE NACIMIENTO',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.red,
              surface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Actualizamos el controlador para que se guarde en el formulario
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // Función principal para preparar y enviar la solicitud al backend
  Future<void> _prepareAndSubmitData() async {
    // 1. Validar el último formulario (aunque el PageView avanza sin él, por seguridad)
    if (_formKey3.currentState?.validate() == false) {
      return;
    }

    // 2. Recopilar y estructurar todos los datos del frontend
    final userData = {
      // Cambiado a singular para coincidir con tu ejemplo guardado
      "nombre": _nombresController.text.trim(),
      "apellido": _apellidosController.text.trim(),

      "cedula": _cedulaController.text.trim(),
      "correo": _correoController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "genero": _selectedGender?.toString().split('.').last,
      "fechaNacimiento": _selectedDate.toIso8601String(),
      "usuario": _usuarioController.text.trim(),
      "contrasena": _contrasenaController.text,

      // 1. Forzar conversión a double (Number en JS)
      "latitud": double.parse(_mapCenter.latitude.toString()),
      "longitud": double.parse(_mapCenter.longitude.toString()),

      // 2. Manejo del UID: Si está vacío, enviar null explícito o no enviarlo
      // para que el Backend sepa que debe generarlo.
      "uid":
          (_preRegistroData?['uid']?.toString().isEmpty ?? true)
              ? null
              : _preRegistroData!['uid'],

      "empresaId": _preRegistroData?['empresaId'] ?? "",
      "branchId": _preRegistroData?['branchId'] ?? "",
      "managerId": _preRegistroData?['managerId'] ?? "",

      // Agrega el cargo si es que venía en el pre-registro
      "cargo": _preRegistroData?['cargo'] ?? "Empleado",

      "status": "activo", // Consistencia con tu ejemplo
      "ruc": _empresaController.text,
      "sucursal": _sucursalController.text,
    };

    try {
      setState(() => _isLoading = true);

      // --- DEBUG PRINT: Contraseña que se enviará al backend ---
      debugPrint(
        '🔐 CONTRASEÑA ENVIADA AL BACKEND: ${_contrasenaController.text}',
      );
      // ---------------------------------------------------------

      // 3. Llamar al servicio con imagen
      final result = await _registerService.registerWithImage(
        userData,
        _imageFile,
      );

      if (result != null) {
        // 4. Éxito: Simular la finalización del registro y navegar
        _pageController.nextPage(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );

        // El resto de la lógica de finalización ya está en _nextPage()
      } else {
        // 5. Fracaso: Mostrar un mensaje de error (ej: el correo ya existe, error del backend)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error en el registro. Verifique sus datos o intente más tarde.',
              ),
            ),
          );
        }
        // Opcionalmente, puedes volver a la página de credenciales si el error es de usuario/contraseña
      }
    } catch (e) {
      // Muestra el mensaje REAL del backend (ej: "El usuario ya existe")
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initLocation() async {
    await _handleLocationPermissions();
    if (!_locationDenied) {
      await _determinePosition();
    }
  }

  Future<void> _handleLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (!serviceEnabled ||
        permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _locationDenied = true);
      return;
    }

    setState(() => _locationDenied = false);
  }

  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _mapCenter = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _mapCenter,
            infoWindow: const InfoWindow(title: 'Ubicación Actual'),
          ),
        );
      });
    } catch (e) {
      print("Error al obtener la posición: $e");
    }
  }

  // Diálogo de validación de cédula
  Future<void> _showCedulaValidationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validación de Cédula'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Por favor, ingrese su número de cédula para continuar.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cedulaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verificarCedula,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Verificar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Verificar cédula en el backend
  Future<void> _verificarCedula() async {
    if (_cedulaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese su cédula')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _registerService.checkCedula(
        _cedulaController.text.trim(),
      );

      // --- DEBUG PRINT: Respuesta completa del servidor ---
      debugPrint('--- BACKEND RESPONSE ---');
      debugPrint(result.toString());
      // ----------------------------------------------------

      // Error general de servicio
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al verificar la cédula. Intente nuevamente'),
          ),
        );
        return;
      }

      // Cédula no existe
      if (result['exists'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta cédula no está registrada, reintente'),
          ),
        );
        return;
      }

      final data = result['data'] as Map<String, dynamic>?;

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos incompletos para esta cédula')),
        );
        return;
      }

      final estadoRegistro = data['estadoRegistro'] as String?;

      if (estadoRegistro == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado de registro no definido')),
        );
        return;
      }

      // Usuario ya registrado
      if (estadoRegistro == 'registrado') {
        _showUsuarioYaRegistradoDialog();
        return;
      }

      // Pre-registro válido
      if (estadoRegistro == 'pendiente') {
        _cargarDatosPreRegistro(data);

        setState(() {
          _cedulaValidada = true;
        });
        return;
      }

      // Estado no esperado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado desconocido: $estadoRegistro')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Mostrar diálogo de usuario ya registrado
  void _showUsuarioYaRegistradoDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICONO
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 16),

                  // TÍTULO
                  const Text(
                    'Usuario ya registrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // MENSAJE
                  const Text(
                    'Esta cédula ya está asociada a una cuenta existente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 24),

                  // BOTÓN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ir al Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Cargar datos del pre-registro
  void _cargarDatosPreRegistro(Map<String, dynamic> data) {
    // --- DEBUG PRINTS: Verificando campos específicos ---
    debugPrint('===[ CARGANDO DATOS DE PRE-REGISTRO ]===');
    debugPrint(
      '🏢🏢🏢 Empresa: ${data['empresaNombre']} (ID: ${data['empresaId']})',
    );
    debugPrint(
      '📍📍📍 Sucursal: ${data['sucursalNombre']} (ID: ${data['branchId']})',
    );
    debugPrint(
      '🌎🌎🌎 Coordenadas: Lat ${data['latitud']}, Lng ${data['longitud']}',
    );
    debugPrint('👤👤👤 Usuario: ${data['nombre']} ${data['apellido']}');
    // ----------------------------------------------------

    setState(() {
      _preRegistroData = data;

      // Datos personales - usando valores predeterminados
      _nombresController.text = DefaultValues.getValue(data, 'nombre', DefaultValues.nombre);
      _apellidosController.text = DefaultValues.getValue(data, 'apellido', DefaultValues.apellido);
      _correoController.text = DefaultValues.getValue(data, 'correo', DefaultValues.correo);
      _telefonoController.text = DefaultValues.getValue(data, 'telefono', DefaultValues.telefono);

      // Datos de empresa - usando valores predeterminados
      _empresaController.text = DefaultValues.getValue(data, 'empresaNombre', DefaultValues.empresaNombre);
      _sucursalController.text = DefaultValues.getValue(data, 'sucursalNombre', DefaultValues.sucursalNombre);

      // Limpiar marcadores (por seguridad)
      _markers.clear();

      // Coordenadas - usando valores predeterminados si no existen
      final latitud = DefaultValues.getValue(data, 'latitud', DefaultValues.latitudDefecto);
      final longitud = DefaultValues.getValue(data, 'longitud', DefaultValues.longitudDefecto);
      
      _mapCenter = LatLng(latitud, longitud);

      _markers.add(
        Marker(
          markerId: const MarkerId('branch_location'),
          position: _mapCenter,
          infoWindow: InfoWindow(
            title: DefaultValues.getValue(data, 'sucursalNombre', DefaultValues.sucursalNombre),
            snippet: DefaultValues.getValue(data, 'empresaNombre', DefaultValues.empresaNombre),
          ),
        ),
      );

      // Género - usando valor predeterminado
      final generoStr = DefaultValues.getValue(data, 'genero', DefaultValues.genero);
      _selectedGender = generoStr.toString().toLowerCase() == 'masculino' 
          ? Genero.masculino 
          : Genero.femenino;

      // Fecha de nacimiento - usando valor predeterminado
      final fechaStr = DefaultValues.getValue(data, 'fechaNacimiento', '');
      if (fechaStr.isNotEmpty) {
        _selectedDate = DateTime.parse(fechaStr);
      } else {
        _selectedDate = DefaultValues.fechaNacimientoDefecto;
      }

      if (data['latitud'] != null && data['longitud'] != null) {
        debugPrint('✅ Coordenadas detectadas y asignadas al mapa');
      } else {
        debugPrint('⚠️ No se recibieron coordenadas (latitud/longitud)');
      }
    });
  }

  //pagina principal de finalizacion
  void _nextPage() {
    GlobalKey<FormState>? currentFormKey;

    if (_currentPage == 0) {
      currentFormKey = _formKey;
    } else if (_currentPage == 2) {
      currentFormKey = _formKey2;
    } else if (_currentPage == 3) {
      currentFormKey = _formKey3;
    }

    // Si no hay formulario a validar O la validación es exitosa
    if (currentFormKey == null ||
        currentFormKey.currentState?.validate() == true) {
      if (_currentPage == 4) {
        // <-- Lógica al presionar "Finalizar"
        // Ejecutar la lógica de SUBIDA DE DATOS
        _prepareAndSubmitData();
        return; // Detener la navegación de PageView, que será manejada por _prepareAndSubmitData() si es exitoso
      }

      // Lógica original para avanzar las primeras 4 páginas
      if (_currentPage < 4) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
      // La página 5 (_buildFivePage) NO tiene validación, así que avanza
      else if (_currentPage == 5) {
        // Esta es la página final del PageView, que lanza la animación
        // Si llegamos aquí, fue porque _prepareAndSubmitData fue exitoso.
        _pageController.nextPage(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
        Future.delayed(
          const Duration(milliseconds: 600),
          () => setState(() => _isFinished = true),
        );
        Future.delayed(
          const Duration(milliseconds: 2100),
          () => ({
            if (mounted)
              Navigator.pushReplacementNamed(context, AppRoutes.splashWelcome),
          }),
        );
      }
    }
  }

  Widget _buildPageIndicator(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: size * 0.01),
          width: size * 0.025,
          height: size * 0.025,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.pinkAccent : Colors.white60,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }

  Color getBackgroundColor() {
    if (_isFinished) {
      return const Color(0xFFFFFFFF).withOpacity(1.0);
    } else if (_currentPage >= 5) {
      return const Color(0xFFFFFFFF).withOpacity(0.60);
    } else if (_currentPage >= 4) {
      return const Color(0xFFFFFFFF).withOpacity(0.32);
    } else {
      return Colors.black.withOpacity(0.55);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Si la cédula no ha sido validada, mostrar diálogo de validación
    if (!_cedulaValidada) {
      return _buildCedulaValidationDialog();
    }

    // Crear instancias de las secciones
    final formSection = FormSection(
      width: width,
      height: height,
      formKey: _formKey,
      formKey2: _formKey2,
      formKey3: _formKey3,
      nombresController: _nombresController,
      apellidosController: _apellidosController,
      cedulaController: _cedulaController,
      correoController: _correoController,
      telefonoController: _telefonoController,
      usuarioController: _usuarioController,
      contrasenaController: _contrasenaController,
      confirmarContrasenaController: _confirmarContrasenaController,
      empresaController: _empresaController,
      sucursalController: _sucursalController,
      dateController: _dateController,
      selectedGender: _selectedGender as Genero,
      selectedDate: _selectedDate,

      // 1. Modificado para ver el cambio de Género
      onGenderChanged: (gender) {
        setState(() {
          _selectedGender = gender ?? Genero.masculino;
        });
        print("DEBUG: 🚻 Género seleccionado: $_selectedGender");
      },

      // 2. Modificado para ver el cambio de Fecha
      onDateChanged: (date) {
        print("DEBUG: 📅 Click detectado en fecha. Abriendo selector...");
        _selectDate().then((_) {
          print("DEBUG: 📅 Fecha actual tras cerrar selector: $_selectedDate");
          print(
            "DEBUG: 📝 Texto en controlador de fecha: ${_dateController.text}",
          );
        });
      },

      onPasswordVisibilityChanged:
          (visible) => setState(() => _obscurePassword = visible),
      onConfirmPasswordVisibilityChanged:
          (visible) => setState(() => _obscurePassword2 = visible),
      obscurePassword: _obscurePassword,
      obscurePassword2: _obscurePassword2,
    );

    final locationSection = LocationSection(
      width: width,
      height: height,
      formKey3: _formKey3,
      empresaController: _empresaController,
      sucursalController: _sucursalController,
      mapCenter: _mapCenter,
      markers: _markers,
      isKeyboardVisible: _isKeyboardVisible,
      locationDenied: _locationDenied,
      onMapCreated: (controller) => controller, // _mapController no se usa
      onRetryLocation: _initLocation,
      preRegistroData: _preRegistroData,
    );

    final imageSection = ImageSection(
      width: width,
      height: height,
      imageFile: _imageFile,
      onImagePicked: (file) => setState(() => _imageFile = file),
      onImageRemoved: () => setState(() => _imageFile = null),
    );

    final actionsSection = ActionsSection(
      currentPage: _currentPage,
      width: width,
      height: height,
      isFinished: _isFinished,
      onNextPage: _nextPage,
      onPreviousPage: _previousPage,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('lib/assets/images/fondo.png', fit: BoxFit.cover),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              color: getBackgroundColor(),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.02,
              ),
              child: Column(
                children: [
                  // Header con logo, título e indicador
                  HeaderSection(
                    currentPage: _currentPage,
                    width: width,
                    height: height,
                    buildPageIndicator: _buildPageIndicator,
                  ),

                  // PageView con formularios
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged:
                          (index) => setState(() => _currentPage = index),
                      children: [
                        // Formularios de la sección 1 (datos personales, demográficos, credenciales)
                        ...formSection.buildForms(),

                        // Sección 4: Datos de empresa y ubicación
                        locationSection,

                        // Sección 5: Foto de perfil
                        imageSection,

                        // Sección 6: Animación final
                        _buildSixPage(width, height),
                      ],
                    ),
                  ),

                  // Botones de navegación
                  actionsSection,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el diálogo de validación de cédula
  Widget _buildCedulaValidationDialog() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('lib/assets/images/fondo.png', fit: BoxFit.cover),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.02,
              ),

              // 🔥 CARD PERSONALIZADA (REEMPLAZA AlertDialog)
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TÍTULO
                    const Text(
                      'Validación de Cédula',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DESCRIPCIÓN
                    const Text(
                      'Por favor, ingrese su número de cédula para continuar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),

                    const SizedBox(height: 24),

                    // INPUT
                    TextField(
                      controller: _cedulaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Cédula',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // BOTONES
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verificarCedula,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Verificar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSixPage(double width, double height) {
    return Container();
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _cedulaController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _usuarioController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    _empresaController.dispose();
    _sucursalController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
