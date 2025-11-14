import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:auth_company/features/auth/register/register_service.dart';
import 'package:auth_company/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

enum Genero { masculino, femenino }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _sucursalController = TextEditingController();

  Genero? _selectedGender = Genero.masculino;
  DateTime _selectedDate = DateTime.now();


  ///mapa localizacion///
  GoogleMapController? _mapController;
  LatLng _mapCenter = const LatLng(0, 0); 
  final Set<Marker> _markers = {};
  bool _isKeyboardVisible = false;
  bool _locationDenied = false;







  ///selector de imagenes//
  File? _imageFile; 
  final ImagePicker _picker = ImagePicker(); 

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
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
  if (currentFormKey == null || currentFormKey.currentState?.validate() == true) {

    if (_currentPage == 4) { // <-- Lógica al presionar "Finalizar"
        // Ejecutar la lógica de SUBIDA DE DATOS
        _prepareAndSubmitData();
        return; // Detener la navegación de PageView, que será manejada por _prepareAndSubmitData() si es exitoso
    }
    
    // Lógica original para avanzar las primeras 4 páginas
    if (_currentPage < 4) {
      _pageController.nextPage( duration: const Duration(milliseconds: 100),curve: Curves.easeInOut,);
    } 
    // La página 5 (_buildFivePage) NO tiene validación, así que avanza
    else if (_currentPage == 5) { 
        // Esta es la página final del PageView, que lanza la animación
        // Si llegamos aquí, fue porque _prepareAndSubmitData fue exitoso.
        _pageController.nextPage( duration: const Duration(milliseconds: 100),curve: Curves.easeInOut,);
        Future.delayed(const Duration(milliseconds: 600), () => setState(() =>_isFinished = true));
        Future.delayed(const Duration(milliseconds: 2100), ()=>({if (mounted)Navigator.pushReplacementNamed(context, AppRoutes.splashWelcome)}));
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
          decoration: BoxDecoration(color: _currentPage == index ? Colors.pinkAccent : Colors.white60,shape: BoxShape.circle,),
        );
      }),
    );
  }

 
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 100),curve: Curves.easeInOut,);
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

  if (!serviceEnabled || permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    setState(() => _locationDenied = true);
    return;
  }

  setState(() => _locationDenied = false);
}


Future<void> _determinePosition() async {
  try {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high,);

    setState(() {
      _mapCenter = LatLng(position.latitude, position.longitude);
      _markers.add(Marker(markerId: const MarkerId('current_location'),position: _mapCenter,infoWindow: const InfoWindow(title: 'Ubicación Actual'),),);
    });
  } catch (e) {
    print("Error al obtener la posición: $e");
  }
}



  /*// FUNCIÓN PARA BUSCAR DIRECCIÓN (Geocoding)
  Future<void> _searchAndMarkLocation() async {
    final address = '${_empresaController.text}, ${_sucursalController.text}'; 
    
    try {
      // 1. Convertir la dirección de texto a coordenadas (Lat/Lng)
      List<Location> locations = await GeocodingPlatform.instance?.locationFromAddress(address) ?? [];
      
      if (locations.isNotEmpty) {
        final newPosition = LatLng(locations.first.latitude, locations.first.longitude);
        
        setState(() {
          _mapCenter = newPosition;
          _markers = {}; // Limpia marcadores anteriores
          _markers.add(Marker(
            markerId: const MarkerId('searched_location'),
            position: newPosition,
            infoWindow: InfoWindow(title: address),
          ));
        });
        
        // Mueve la cámara del mapa a la nueva posición
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
      } else {
        // Manejar el caso de que la dirección no se encuentre
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dirección no encontrada.')),
        );
      }
    } catch (e) {
      // Manejar errores de API o conexión
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar la dirección: $e')),
      );
    }
  }
*/

// 1. Inicializar el servicio
final RegisterService _registerService = RegisterService();
// 2. Estado para el loading
bool _isLoading = false;
// Función para convertir la imagen a Base64
String? _getImageBase64() {
  if (_imageFile == null) {
    return null;
  }
  final bytes = _imageFile!.readAsBytesSync();
  return base64Encode(bytes);
}

// Función principal para preparar y enviar la solicitud al backend
Future<void> _prepareAndSubmitData() async {
  // 1. Validar el último formulario (aunque el PageView avanza sin él, por seguridad)
  if (_formKey3.currentState?.validate() == false) {
      return; 
  }

  // 2. Recopilar y estructurar todos los datos del frontend
  final userData = {
    // Datos Personales
    "nombres": _nombresController.text,
    "apellidos": _apellidosController.text,
    "cedula": _cedulaController.text,
    "correo": _correoController.text,
    "telefono": _telefonoController.text,
    
    // Datos Demográficos
    "genero": _selectedGender?.toString().split('.').last, // 'masculino' o 'femenino'
    "fechaNacimiento": _selectedDate.toIso8601String(), // Formato estándar de fecha/hora

    // Credenciales de Cuenta
    "usuario": _usuarioController.text,
    "contrasena": _contrasenaController.text, // Solo enviar la contraseña principal
    
    // Información de la Empresa
    "ruc": _empresaController.text,
    "sucursal": _sucursalController.text,
    // Coordenadas
    "lat": _mapCenter.latitude,
    "lng": _mapCenter.longitude,
    
    // Foto de Perfil (como Base64 String)
    "fotoPerfilBase64": _getImageBase64(), 
  };

  setState(() => _isLoading = true);
  
  // 3. Llamar al servicio
  final result = await _registerService.register(userData);
  
  setState(() => _isLoading = false);

  if (result != null) {
    // 4. Éxito: Simular la finalización del registro y navegar
    _pageController.nextPage(duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
    
    // El resto de la lógica de finalización ya está en _nextPage()

  } else {
    // 5. Fracaso: Mostrar un mensaje de error (ej: el correo ya existe, error del backend)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en el registro. Verifique sus datos o intente más tarde.')),
      );
    }
    // Opcionalmente, puedes volver a la página de credenciales si el error es de usuario/contraseña
  }
}




@override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
  await _handleLocationPermissions();
  if (!_locationDenied) {
    await _determinePosition();
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

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('lib/assets/images/fondo.png', fit: BoxFit.cover,),

          BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut,color: getBackgroundColor(),),
          ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: height * 0.02,),
              child: Column(
                children: [
                  SizedBox(height: height * 0.05),


                  AnimatedOpacity(opacity: _currentPage <= 4 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),curve: Curves.easeInOut,
                  child: SizedBox(width: width * 0.25, height: height * 0.12,child: Image.asset('lib/assets/images/logoTalenTrack.png'),),
                  ),
                  SizedBox(height: height * 0.015),

                  AnimatedOpacity(
                    opacity: _currentPage <= 4 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: SizedBox(height: height * 0.05, 
                      child: Center(child: Text("Register",style: TextStyle(fontSize: width * 0.075,fontWeight: FontWeight.bold,color: Colors.white,letterSpacing: 7.5,),),),
                    ),
                  ),
                  SizedBox(height: height * 0.015),

                  AnimatedOpacity(
                    opacity: _currentPage <= 4 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),curve: Curves.easeInOut,
                    child: SizedBox(height: height * 0.03,child: Center(child: _buildPageIndicator(width)),),
                  ),

                  SizedBox(height: height * 0.03),


                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      children: [
                        _buildFirstPage(width, height),
                        _buildSecondPage(width, height),
                        _buildThirdPage(width, height),
                        _buildFourthPage(width, height),
                        _buildFivePage(width, height),
                        _buildSixPage(width, height),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.025),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      AnimatedOpacity(
                        opacity: _isFinished ? 0.0 : 1.0,
                        duration: Duration(milliseconds: 500),
                        curve:Curves.easeInOut,
                        child: Row(
                          children: [
                            if (_currentPage > 0 && _currentPage < 4)
                                SizedBox(
                                  width: width * 0.40,
                                  height: height * 0.045,
                                  child: TextButton(
                                    onPressed: _previousPage,
                                    style: TextButton.styleFrom(foregroundColor: Colors.black87,backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255),),
                                        SizedBox(width: width * 0.015),
                                        Text("Anterior",style: TextStyle(fontSize: width * 0.04, color: const Color.fromARGB(221, 255, 255, 255),),),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                SizedBox(width: width * 0.40),

                            SizedBox(width: width * 0.02),
                            SizedBox(
                              width: width * 0.40,
                              height: height * 0.045,
                              child: ElevatedButton(
                                onPressed: _nextPage,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),elevation: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(_currentPage < 4 ? "Siguiente" : "Finalizar", style: TextStyle(fontSize: width * 0.04),),
                                    SizedBox(width: width * 0.015),
                                    const Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                            ),
                            
                          ],
                        ),

                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }





  // Primera pantalla del formulario
  Widget _buildFirstPage(double width, double height) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(top: height * 0.02),
        children: [

          TextFormField(
            controller: _nombresController,
            keyboardType: TextInputType.name,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(labelText: "Nombres",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
            ),

            validator: (value) {

              /*if (value == null || value.trim().isEmpty) {
                return "Nombres cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }

              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid nombres (only letters, numbers, - or _)";
                }*/
                return null;
              },
            ),

          SizedBox(height: height * 0.02),
          TextFormField(
            controller: _apellidosController,
            keyboardType: TextInputType.name,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(labelText: "Apellidos",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
            ),

            validator: (value) {

              /*if (value == null || value.trim().isEmpty) {
                return "Apellidos cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }

              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid apellidos (only letters, numbers, - or _)";
                }*/
                return null;
              },
            ),
            
          SizedBox(height: height * 0.02),
          TextFormField(
            controller: _cedulaController,
            keyboardType: TextInputType.number,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(labelText: "Cédula",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
            ),

            validator: (value) {

              /*if (value == null || value.trim().isEmpty) {
                return "Cédula cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }

              if (cedula && value.length != 10) {
                  return "Cédula inválida";
              }

              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid cédula (only letters, numbers, - or _)";
                }*/
                return null;
              },
            ),

          SizedBox(height: height * 0.02),
          TextFormField(
            controller: _correoController,
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(labelText: "Correo",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
            ),

            validator: (value) {

              /*if (value == null || value.trim().isEmpty) {
                return "Correo cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }

              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid correo (only letters, numbers, - or _)";
                }

              if (email && !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                  return "Correo inválido";
                }
                */
                return null;
              },
            ),

          SizedBox(height: height * 0.02),
          TextFormField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(labelText: "Telefono",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
            ),

            validator: (value) {

              /*if (value == null || value.trim().isEmpty) {
                return "Telefono cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }

              final regex = RegExp(r'^[0-9]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid telefono (only numbers)";
                }

                */
                return null;
              },
            ),
        ],
      ),
    );
  }







  //Segunda pantalla del formulario
  Widget _buildSecondPage(double width, double height) {
  final labelStyle = TextStyle(color: Colors.white70, fontSize: width * 0.04);

  return ListView(
    padding: EdgeInsets.only(top: height * 0.02,left: width * 0.06,right: width * 0.06),

    children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 0.0),child: Text("Seleccione Genero", style: labelStyle),),
      SizedBox(height: height * 0.02),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          _buildGenderSelector(icon: Icons.male,gender: Genero.masculino,width: width),

          const SizedBox(width: 24),

          _buildGenderSelector(icon: Icons.female,gender: Genero.femenino,width: width,),
        ],
      ),
      SizedBox(height: height * 0.04),


      Padding(padding: const EdgeInsets.symmetric(horizontal: 0.0),child: Text("Seleccione año de nacimiento", style: labelStyle),),
      SizedBox(height: height * 0.025),

      InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDatePart(label: "Dia", value: _selectedDate ?.day.toString().padLeft(2, '0') ?? "--",width: width,),
              _buildDateDivider(),
    
              _buildDatePart(label: "Mes", value: _selectedDate?.month.toString().padLeft(2, '0') ?? "--",width: width,),
              _buildDateDivider(),
              
              _buildDatePart(label: "Año", value: _selectedDate?.year.toString() ?? "----", width: width,),
            ],
          ),
        ),
      ),
      SizedBox(height: height * 0.02),
    ],
  );
}


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context,initialDate: _selectedDate,firstDate: DateTime(1900),lastDate: DateTime.now(),);

    if (picked != null && picked != _selectedDate) {
      setState(() =>_selectedDate = picked);
    }
  }



  Widget _buildGenderSelector({required IconData icon,required Genero gender,required double width,}) {
    final bool isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),

      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isSelected ? Colors.black.withOpacity(0.4) : Colors.transparent,borderRadius: BorderRadius.circular(12), ),
        child: Icon(icon,color: Colors.white,size: width * 0.08,),
      ),
    );
  }


  Widget _buildDatePart({required String label, required String value, required double width}) {
    return Column(
      children: [
        Text(label,style: TextStyle(color: Colors.white70, fontSize: width * 0.04),),
        const SizedBox(height: 4),

        Text(value,style: TextStyle(color: Colors.white,fontSize: width * 0.065,fontWeight: FontWeight.bold,),),
      ],
    );
  }

  Widget _buildDateDivider() {
    return Container(height: 50, padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const VerticalDivider(color: Colors.white54,thickness: 1,),
    );
  }





  // Tercera pantalla del formulario
  Widget _buildThirdPage(double width, double height) {
    return Form(
      key: _formKey2,
      child: ListView(
        padding: EdgeInsets.only(top: height * 0.02),
        children: [

          SizedBox(height: height * 0.05),

          TextFormField(
            controller: _usuarioController,
            keyboardType: TextInputType.name,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(labelText: "Usuario",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
            ),

            validator: (value) {

              /*if (value == null || value.trim().isEmpty) {
                return "Usuario cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }

              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid usuario (only letters, numbers, - or _)";
                }*/
                return null;
              },
            ),

          SizedBox(height: height * 0.03),

          TextFormField(
            controller: _contrasenaController,
            obscureText: _obscurePassword,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(hintText: "Password",hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color.fromARGB(255, 255, 255, 255),),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),),

              validator: (value) {
                /*if (value == null || value.isEmpty) {
                  return "Password cannot be empty";
                  }
                if (value.length < 8) {
                  return "At least 8 characters required";
                  }*/
                return null;
                },
            ),

            SizedBox(height: height * 0.03),
            TextFormField(
              controller: _confirmarContrasenaController,
              obscureText: _obscurePassword2,
              style: TextStyle(color: Colors.white, fontSize: width * 0.04),
              decoration: InputDecoration(hintText: "Confirmar Password",hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword2 ? Icons.visibility_off : Icons.visibility, color: const Color.fromARGB(255, 255, 255, 255),),
                  onPressed: () => setState(() => _obscurePassword2 = !_obscurePassword2),
                ),),

                validator: (value) {
                  /*if (value == null || value.isEmpty) {
                    return "Password cannot be empty";
                    }
                    if (value != _contrasenaController.text) {
                      return "Passwords do not match";
                    }
                  if (value.length < 8) {
                    return "At least 8 characters required";
                    }*/
                  return null;
                  },
              ),

        ],
      ),
    );
  }



  // Widget para la cuarta pantalla
  Widget _buildFourthPage(double width, double height) {
    final newKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    if (_isKeyboardVisible != newKeyboardVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _isKeyboardVisible = newKeyboardVisible));
    }

    return Form(
      key: _formKey3,
      child: ListView(
        padding: EdgeInsets.only(top: height * 0.03),
        children: [

          TextFormField(
            controller: _empresaController,
            keyboardType: TextInputType.name,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(labelText: "Ruc(Empresa)",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
            ),

            validator: (value) {

              /*if (value == null || value.trim().isEmpty) {
                return "Empresa cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }

              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid empresa (only letters, numbers, - or _)";
                }*/
                return null;  
              },
            ),

          SizedBox(height: height * 0.03),
          TextFormField(
            controller: _sucursalController,
            keyboardType: TextInputType.name,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(labelText: "Sucursales",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
            ),

            validator: (value) {

              /*if (value == null || value.trim().isEmpty) {
                return "Sucursal cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }

              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid sucursal (only letters, numbers, - or _)";
                }*/
                return null;
              },
            ),
            
          SizedBox(height: height * 0.03),


          ElevatedButton.icon(
            onPressed: /*_searchAndMarkLocation*/ null,
            icon: const Icon(Icons.search, color: Colors.black),
            label: const Text('Buscar Ubicación en Mapa', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),),
          ),
          
        SizedBox(height: height * 0.03),

          FutureBuilder(
            future: Future.delayed(const Duration(seconds: 3)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildGoogleMapWidget(height);
              } else {
                return Container(
                  height: height * 0.4, 
                  decoration: BoxDecoration(color: Colors.black45,borderRadius: BorderRadius.circular(12),border: Border.all(color: Colors.white54, width: 1.0)),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white),),
                );
              }
            },
          ),
        ],
      ),
    );
  }





Widget _buildGoogleMapWidget(double height) {

  if (_isKeyboardVisible) {
    return Container(
      height: height * 0.4,
      decoration: BoxDecoration(color: Colors.black54,borderRadius: BorderRadius.circular(12),border: Border.all(color: Colors.white54, width: 1.0),),
      child: Center(child: Text("Mapa desactivado (teclado activo)",style: TextStyle(color: Colors.white70, fontSize: 16),),),
    );
  }

  if (_locationDenied) {
    return Container(
      height: height * 0.4,
      decoration: BoxDecoration(color: Colors.black54,borderRadius: BorderRadius.circular(12),border: Border.all(color: Colors.white54, width: 1.0),),
      child: Center(
        child: Padding( 
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off,color: Colors.redAccent,size: 40,),
              SizedBox(height: height * 0.02), 
              Text("Permisos de ubicación deshabilitados. 🛑\nPor favor, activa la ubicación y otorga permisos manualmente.",
                style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w600,),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.03), 

              ElevatedButton(
                onPressed: () => _initLocation(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, 
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                ),
                child: const Text("Reintentar / Habilitar Permisos",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold,),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  if (_mapCenter.latitude == 0 && _mapCenter.longitude == 0) {
    return Container(
      height: height * 0.4,
      decoration: BoxDecoration(color: Colors.black45,borderRadius: BorderRadius.circular(12),border: Border.all(color: Colors.white54, width: 1.0),),
      child: const Center(child: CircularProgressIndicator(color: Colors.white),),
    );
  }

  return Container(
    height: height * 0.4,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),border: Border.all(color: Colors.white54, width: 1.0)),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(zoomGesturesEnabled: true,scrollGesturesEnabled: true, mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: _mapCenter, zoom: 14,),
        onMapCreated: (GoogleMapController controller) => _mapController = controller,
        markers: _markers,
        myLocationEnabled: true,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer(),),
        },
      ),
    ),
  );
}



// Quinta pantalla del formulario
  Widget _buildFivePage(double width, double height) {
    final circleSize = width * 0.45; 

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          InkWell(
            onTap: () => _showImageSourceDialog(context),
            customBorder: const CircleBorder(),
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(shape: BoxShape.circle,boxShadow: [BoxShadow(color: Colors.black26,blurRadius: 10,offset: const Offset(0, 5),),],color: const Color.fromARGB(255, 255, 255, 255),border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 3),
                image: _imageFile != null? DecorationImage(image: FileImage(_imageFile!),fit: BoxFit.cover,) : null,
              ),
              child: _imageFile == null ? Icon(Icons.person_add_alt_1_rounded,color: const Color.fromARGB(255, 175, 170, 170),size: circleSize * 0.6,) : const SizedBox.shrink(), 
            ),
          ),

          SizedBox(height: height * 0.05),

          if (_imageFile != null)
            TextButton.icon(
              onPressed: () => setState(() => _imageFile = null),
              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 255, 255)), label: const Text('Quitar foto', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
            ),
        ],
      ),
    );
  }


  //Sexto pantalla del formulario
  Widget _buildSixPage(double width, double height) {
  return Container();
}




}


