import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:auth_company/features/registro_asistencia/services/attendance_service.dart';
import 'package:intl/intl.dart';
import 'package:auth_company/features/user/services/user_service.dart';

class RegistroManual extends StatefulWidget {
  const RegistroManual({super.key});

  @override
  State<RegistroManual> createState() => _RegistroManualState();
}

class _RegistroManualState extends State<RegistroManual> {
  // Servicios
  final AttendanceService _attendanceService = AttendanceService();
  final UserService _userService = UserService();

  // Estados de la UI
  bool _isSaving = false; // Renombrado de _isLoading a _isSaving para claridad
  bool _isDataLoading = true; // ✅ Estado para la carga inicial de datos

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _sucursalController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  DateTime? _fechaSeleccionada;

  /// IMAGEN
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadEmployeeData(); // ✅ Cargar datos al iniciar
  }

  @override
  void dispose() {
    // Liberar recursos
    _nombresController.dispose();
    _apellidosController.dispose();
    _sucursalController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  // FUNCIÓN PARA CARGAR DATOS DEL EMPLEADO (NOMBRE, APELLIDO, SUCURSAL)
  Future<void> _loadEmployeeData() async {
    setState(() => _isDataLoading = true);

    final profileData =
        await _userService.getEmployeeDataForManualRegistration();

    if (profileData != null && mounted) {
      _nombresController.text = profileData['nombre']!;
      _apellidosController.text = profileData['apellido']!;
      _sucursalController.text = profileData['sucursal']!;
    } else if (mounted) {
      // Si profileData es null, se ejecuta este bloque
      _nombresController.text = 'Error de carga'; // Texto que ves
      _apellidosController.text = 'Error de carga';
      _sucursalController.text = 'Error de carga';

      // Sugiero añadir un log o snackbar aquí para depurar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error: No se pudo cargar el perfil del empleado (Revisar logs del backend/service).",
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => _isDataLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // LÓGICA PRINCIPAL DE REGISTRO
  Future<void> _handleRegistro() async {
    // 1. Validaciones básicas
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes seleccionar una fecha")),
      );
      return;
    }
    if (_motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Debes escribir un motivo")));
      return;
    }
    // Nota: Nombres, Apellidos y Sucursal son visuales/informativos si el backend usa el Token.
    // Si la imagen fuera obligatoria, validar _imageFile != null aquí.

    setState(() => _isSaving = true);

    // 2. Formatear fecha a YYYY-MM-DD
    String fechaStr = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);

    // 3. Llamar al servicio
    final result = await _attendanceService.registrarManual(
      fecha: fechaStr,
      motivo: _motivoController.text.trim(),
    );

    setState(() => _isSaving = false);

    // 4. Manejar respuesta usando el diálogo personalizado (ESTE ES EL CAMBIO)
    if (!mounted) return; // Chequeo final después del await

    if (result['success'] == true) {
      // Éxito: Llamar al diálogo personalizado
      _showCustomDialog(
        isSuccess: true,
        title: "Registro Exitoso",
        message: result['message'] ?? "Su registro manual ha sido procesado.",
      );
    } else {
      // Error: Llamar al diálogo personalizado (O puedes dejar el SnackBar si prefieres)
      _showCustomDialog(
        isSuccess: false,
        title: "Error de Registro",
        message: result['message'] ?? "Hubo un error al procesar la solicitud.",
      );

      // Si prefieres el SnackBar para el error (como lo tenías antes, pero mejor usar el diálogo)
      /*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
    );
    */
    }
  }

  void _showCustomDialog({
    required bool isSuccess,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar tocando fuera
      builder: (BuildContext context) {
        // Usamos las dimensiones de la pantalla para el diseño responsivo
        final width = MediaQuery.of(context).size.width;
        final Color primaryColor = Colors.black; // Color dominante del diseño

        return AlertDialog(
          // Fondo transparente para que el Container defina el look
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(horizontal: width * 0.05),

          content: Container(
            padding: const EdgeInsets.all(20),
            // Estilo de tarjeta oscura, similar a los registros en registerList
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Icono de Estado
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color:
                      isSuccess
                          ? Colors.green
                          : Colors.red, // Verde para éxito, Rojo para error
                  size: 60,
                ),
                const SizedBox(height: 15),

                // 2. Título (Registro Exitoso / Error)
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Mensaje
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: width * 0.038,
                  ),
                ),
                const SizedBox(height: 30),

                // 4. Botón de Aceptar (Estilo del botón de "Registrar")
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Cerrar Dialog
                    if (isSuccess) {
                      Navigator.pop(
                        context,
                      ); // Volver atrás solo si fue exitoso
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: width * 0.1,
                    ),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isSuccess
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      isSuccess ? "ACEPTAR" : "REINTENTAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final circleSize = width * 0.4;

    // ✅ Mostrar loader mientras se cargan los datos iniciales
    if (_isDataLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              key: const PageStorageKey("RegistroManual"),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.02),

                    // --------------------- Register ---------------------
                    Row(
                      children: [
                        SvgPicture.asset(
                          "lib/assets/images/Registro.svg",
                          width: width * 0.04,
                          color: Colors.black,
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: width * 0.03,
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.03),

                    // --------------------- VOLVER ---------------------
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          "Volver",
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.03),

                    // --------------------- Título ---------------------
                    Text(
                      "Registro manual",
                      style: TextStyle(
                        fontSize: width * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // --------------------- FORMULARIO ---------------------
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nombresController,
                          readOnly: true,
                          keyboardType: TextInputType.name,
                          obscureText: false,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.04,
                          ),
                          decoration: InputDecoration(
                            labelText: "Nombres",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: width * 0.04,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03),

                        TextFormField(
                          controller: _apellidosController,
                          readOnly: true,
                          keyboardType: TextInputType.name,
                          obscureText: false,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.04,
                          ),
                          decoration: InputDecoration(
                            labelText: "Apellidos",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: width * 0.04,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03),

                        TextFormField(
                          controller: _sucursalController,
                          readOnly: true,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.04,
                          ),
                          decoration: InputDecoration(
                            labelText: "Sucursal",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: width * 0.04,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03),

                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _fechaSeleccionada = picked);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Fecha",
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                              controller: TextEditingController(
                                text:
                                    _fechaSeleccionada == null
                                        ? ""
                                        : "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}",
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.03),

                        // CAMPO MOTIVO (Necesario por requerimiento)
                        // Se adapta visualmente al estilo del resto
                        TextFormField(
                          controller: _motivoController,
                          keyboardType: TextInputType.text,
                          maxLines: 2, // Permite 2 lineas para explicar mejor
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.04,
                          ),
                          decoration: InputDecoration(
                            labelText: "Motivo del registro manual",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: width * 0.04,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.05),

                    // --------------------- CÍRCULO (TU CÓDIGO) ---------------------
                    Center(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => _showImageSourceDialog(context),
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                color: const Color.fromARGB(255, 255, 255, 255),
                                border: Border.all(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  width: 3,
                                ),
                                image:
                                    _imageFile != null
                                        ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  _imageFile == null
                                      ? Icon(
                                        Icons.person_add_alt_1_rounded,
                                        color: const Color.fromARGB(
                                          255,
                                          175,
                                          170,
                                          170,
                                        ),
                                        size: circleSize * 0.4,
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ),

                          SizedBox(height: height * 0.05),

                          if (_imageFile != null)
                            TextButton.icon(
                              onPressed:
                                  () => setState(() => _imageFile = null),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                              label: const Text(
                                'Quitar foto',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // --------------------- BOTÓN PRINCIPAL ---------------------
                    Center(
                      child: GestureDetector(
                        onTap:
                            _isSaving
                                ? null
                                : _handleRegistro, // ✅ Conectado a la función
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.018,
                            horizontal: width * 0.12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isSaving
                                    ? Colors.grey
                                    : Colors.black, // Feedback visual simple
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isSaving ? "Enviando..." : "Registrar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.045,
                                ),
                              ),
                              if (!_isSaving) ...[
                                SizedBox(width: width * 0.02),
                                SvgPicture.asset(
                                  "lib/assets/images/Siguiente.svg",
                                  width: width * 0.045,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.15),
                  ],
                ),
              ),
            ),
          ),
          // Loader superpuesto (Opcional)
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
