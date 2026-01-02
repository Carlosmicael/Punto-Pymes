import 'package:auth_company/features/user/services/user_service.dart';
import 'package:auth_company/features/auth/login/login_service.dart';
import 'package:flutter/material.dart';

// Definición de colores del diseño original
const Color _kPrimaryTextColor = Colors.black87;
const Color _kSecondaryTextColor = Colors.black54;
const Color _kLightGrey = Color(0xFFE0E0E0);

// -------------------------------------------------------------------------
// WIDGET PRINCIPAL (Stateful para la lógica)
// -------------------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  // Ahora requiere el UID, como en la copia funcional
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores y servicios
  final LoginService _loginService = LoginService();
  final UserService _userService = UserService();
  final TextEditingController _nombresCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _cedulaCtrl = TextEditingController(); // Solo lectura
  final TextEditingController _correoCtrl = TextEditingController(); // Solo lectura

  String _fotoPerfilUrl = '';
  bool _isLoading = true;
  String _selectedGender = 'masculino';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Lógica de carga del perfil
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final authToken = await _loginService.getSavedToken();

    if (authToken == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: No se encontró token de sesión.')),
        );
      }
      return;
    }

    final data = await _userService.getProfile(widget.uid, authToken);

    if (data != null && mounted) {
      _nombresCtrl.text = data['nombre'] ?? '';
      _apellidosCtrl.text = data['apellido'] ?? '';
      _telefonoCtrl.text = data['telefono'] ?? '';
      _cedulaCtrl.text = data['cedula'] ?? 'N/A';
      _correoCtrl.text = data['correo'] ?? 'N/A';
      _fotoPerfilUrl = data['avatar'] ?? '';
      _selectedGender = data['genero'] ?? 'masculino';

      setState(() => _isLoading = false);
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los datos del perfil.')),
      );
    }
  }

  // Lógica de guardado del perfil
  Future<void> _saveProfileChanges() async {
    final authToken = await _loginService.getSavedToken();

    if (authToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Error: No se encontró token para guardar cambios.')),
        );
      }
      return;
    }

    final userData = {
      "nombre": _nombresCtrl.text,
      "apellido": _apellidosCtrl.text,
      "telefono": _telefonoCtrl.text,
      "genero": _selectedGender,
    };

    final success =
        await _userService.updateProfile(widget.uid, userData, authToken);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '¡Perfil actualizado con éxito!' : 'Falló la actualización.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: success ? Colors.green : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    if (_isLoading) {
      return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()));
    }

    // Usa Scaffold con fondo blanco del diseño original
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // El header usa el diseño visual de user_perfil.dart y el URL dinámico
            _ProfileHeader(
              fondoUrl: _fotoPerfilUrl, // Para el fondo (si es la misma imagen)
              avatarUrl: _fotoPerfilUrl, // Para el avatar
            ),

            // Contenido de la información del perfil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              // Pasa los controladores y callbacks a la sección de información
              child: _ProfileInfoSection(
                nombresCtrl: _nombresCtrl,
                apellidosCtrl: _apellidosCtrl,
                cedulaCtrl: _cedulaCtrl,
                correoCtrl: _correoCtrl,
                telefonoCtrl: _telefonoCtrl,
                selectedGender: _selectedGender,
                onGenderChanged: (newGender) {
                  setState(() {
                    _selectedGender = newGender;
                  });
                },
              ),
            ),
            
            // Botón de Guardar de la copia funcional
            SizedBox(
              width: width * 0.6,
              height: size.height * 0.065,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB455E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.height * 0.05),
                  ),
                ),
                onPressed: _saveProfileChanges,
                child: Text(
                  "Guardar",
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100), // Espacio final
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _cedulaCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }
}

// -------------------------------------------------------------------------
// WIDGET DE LA CABECERA (Adaptado con URL dinámico, manteniendo el diseño)
// -------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final String fondoUrl;
  final String avatarUrl;

  const _ProfileHeader({required this.fondoUrl, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.40;

    // Proveedores de imagen
    final ImageProvider fondoImage = fondoUrl.isNotEmpty
        ? NetworkImage(fondoUrl)
        : const AssetImage('assets/images/default_bg.png'); // Placeholder
    final ImageProvider avatarImage = avatarUrl.isNotEmpty
        ? NetworkImage(avatarUrl)
        : const AssetImage('assets/images/perfil.png'); // Placeholder

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Contenedor de la Imagen de Fondo y Sombra Difuminada (Diseño Original)
        Container(
          height: headerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: fondoImage, // Usamos la URL dinámica aquí
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const Spacer(),
              // Gradiente Difuminado (Fade-out) en la parte inferior de la imagen
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(1.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Avatar de Perfil Grande y Flotante (Diseño Original)
        Positioned(
          top: headerHeight - 110,
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    // Avatar con la imagen dinámica
                    image: DecorationImage(
                      image: avatarImage, // Usamos la URL dinámica aquí
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Botón de la Cámara (Diseño Original)
                Positioned(
                  bottom: 10,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: _kSecondaryTextColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------------
// WIDGET DE LA SECCIÓN DE INFORMACIÓN (Adaptado con TextFormField y lógica)
// -------------------------------------------------------------------------

class _ProfileInfoSection extends StatelessWidget {
  // Parámetros de la copia funcional
  final TextEditingController nombresCtrl;
  final TextEditingController apellidosCtrl;
  final TextEditingController cedulaCtrl;
  final TextEditingController correoCtrl;
  final TextEditingController telefonoCtrl;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const _ProfileInfoSection({
    required this.nombresCtrl,
    required this.apellidosCtrl,
    required this.cedulaCtrl,
    required this.correoCtrl,
    required this.telefonoCtrl,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70), // Espacio para el avatar flotante
        // Título "Perfil" (Diseño Original)
        const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _kPrimaryTextColor,
          ),
        ),

        const SizedBox(height: 30),

        // Campos Editables (Usando el diseño de TextFormField de la copia)
        _buildTextField(
            label: 'Nombres:', controller: nombresCtrl, isEditable: true),
        _buildTextField(
            label: 'Apellidos:', controller: apellidosCtrl, isEditable: true),
        _buildTextField(
            label: 'Numero de telefono:',
            controller: telefonoCtrl,
            isEditable: true),

        // Campos NO Editables (Solo Lectura)
        _buildTextField(
            label: 'Cedula:', controller: cedulaCtrl, isEditable: false),
        _buildTextField(
            label: 'Correo:', controller: correoCtrl, isEditable: false),

        const SizedBox(height: 30),

        // Sección Género (Diseño Original/Adaptado)
        _buildGenderSelector(),

        const SizedBox(height: 50),
      ],
    );
  }

  // Helper para construir campos de texto (Diseño de la copia funcional)
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    // Para mantener el diseño original que usa un divisor, usaremos un
    // TextFormField con un borde inferior y Padding.
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del campo (Diseño Original)
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

          // Valor del campo (TextFormField de la copia funcional, pero estilizado)
          TextFormField(
            controller: controller,
            readOnly: !isEditable,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: isEditable ? _kSecondaryTextColor : Colors.grey[600],
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
              filled: !isEditable,
              fillColor: isEditable ? Colors.white : Colors.grey[50],
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _kLightGrey, width: 1),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _kPrimaryTextColor, width: 2),
              ),
              disabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _kLightGrey, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Selector de Género (Combinación de lógica y diseño)
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genero',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _kPrimaryTextColor,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            // Botón Hombre
            GestureDetector(
              onTap: () => onGenderChanged('masculino'),
              child: _buildGenderButton(
                Icons.male, 
                selectedGender == 'masculino',
              ),
            ),
            const SizedBox(width: 15),
            // Botón Mujer
            GestureDetector(
              onTap: () => onGenderChanged('femenino'),
              child: _buildGenderButton(
                Icons.female, 
                selectedGender == 'femenino',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Constructor de botones de género (Diseño Original)
  Widget _buildGenderButton(IconData icon, bool isSelected) {
    // Usamos el color de selección del diseño original (Gris Oscuro)
    const Color selectedColor = Colors.black87; 

    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? selectedColor : _kLightGrey,
          width: isSelected ? 0 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black54,
        size: 30,
      ),
    );
  }
}