import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores y servicios
  final LoginService _loginService = LoginService();
  final UserService _userService = UserService();
  
  // CORRECCIÓN: Instancia del ImagePicker
  final ImagePicker _picker = ImagePicker();
  
  final TextEditingController _nombresCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _cedulaCtrl = TextEditingController(); 
  final TextEditingController _correoCtrl = TextEditingController(); 

  String _fotoPerfilUrl = '';
  File? _localImage; 
  bool _isLoading = true;
  String _selectedGender = 'masculino';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // CORRECCIÓN: Implementación del método para seleccionar imagen (como en registroManual.dart)
  Future<void> _pickImage(ImageSource source) async {
    print('🎯 DEBUG: _pickImage llamado con source: $source');
    
    try {
      print('🎯 DEBUG: Llamando a ImagePicker.pickImage...');
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Calidad reducida como en registroManual
      );

      print('🎯 DEBUG: pickImage completado. Resultado: $pickedFile');

      if (pickedFile != null) {
        print('🎯 DEBUG: Imagen seleccionada, actualizando estado...');
        setState(() {
          _localImage = File(pickedFile.path);
        });
        print('🎯 DEBUG: Estado actualizado con imagen: ${pickedFile.path}');
      } else {
        print('🎯 DEBUG: No se seleccionó ninguna imagen');
      }
    } catch (e) {
      print('🎯 DEBUG: ERROR en _pickImage: $e');
      debugPrint("Error al seleccionar imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la imagen')),
      );
    }
  }

  // CORRECCIÓN: Diálogo para seleccionar fuente de imagen (como en registroManual.dart)
  void _showImageSourceDialog(BuildContext context) {
    print('🎯 DEBUG: Abriendo diálogo de selección de imagen...');
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        print('🎯 DEBUG: Builder del diálogo ejecutado');
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  print('🎯 DEBUG: Galería seleccionada');
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  print('🎯 DEBUG: Cámara seleccionada');
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

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final authToken = await _loginService.getSavedToken();

    if (authToken == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final data = await _userService.getProfile(widget.uid, authToken);

    if (data != null && mounted) {
      _nombresCtrl.text = data['nombre'] ?? ''; // ✅ Campo singular oficial
      _apellidosCtrl.text = data['apellido'] ?? ''; // ✅ Campo singular oficial
      _telefonoCtrl.text = data['telefono'] ?? '';
      _cedulaCtrl.text = data['cedula'] ?? 'N/A';
      _correoCtrl.text = data['correo'] ?? 'N/A';
      _fotoPerfilUrl = data['avatar'] ?? '';
      _selectedGender = data['genero'] ?? 'masculino';

      setState(() => _isLoading = false);
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileChanges() async {
    final authToken = await _loginService.getSavedToken();

    if (authToken == null) return;

    // CORRECCIÓN: Nombres de campos coinciden con UpdateUserDto del backend (singulares)
    final userData = {
      'nombre': _nombresCtrl.text,     // ✅ Singular
      'apellido': _apellidosCtrl.text,  // ✅ Singular
      'telefono': _telefonoCtrl.text,
      'genero': _selectedGender,
    };

    setState(() => _isLoading = true);

    final success = await _userService.updateProfile(
      widget.uid, 
      userData, 
      authToken, 
      imageFile: _localImage, 
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '¡Perfil actualizado con éxito!' : 'Falló la actualización.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      // Recargar datos para ver la nueva URL de la imagen si se subió una
      if (success) _loadProfileData(); 
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CORRECCIÓN: Pasamos _localImage y el callback _showImageSourceDialog al widget hijo
            _ProfileHeader(
              fondoUrl: _fotoPerfilUrl, 
              avatarUrl: _fotoPerfilUrl,
              localImage: _localImage,
              onImagePick: () {
                print('🎯 DEBUG: Botón cámara presionado');
                _showImageSourceDialog(context);
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
            
            Container(
              width: width * 0.8, // Más ancho
              height: size.height * 0.08, // Más alto
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB455E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // Bordes más redondeados
                  ),
                  elevation: 5, // Sombra para mejor visibilidad
                ),
                onPressed: _saveProfileChanges,
                child: Text(
                  "Guardar",
                  style: TextStyle(
                    fontSize: width * 0.05, // Texto más grande
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100), 
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
// WIDGET DE LA CABECERA (Corregido para recibir parámetros)
// -------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final String fondoUrl;
  final String avatarUrl;
  
  // CORRECCIÓN: Parámetros necesarios para que este widget "tonto" funcione
  final File? localImage;
  final VoidCallback onImagePick;

  const _ProfileHeader({
    required this.fondoUrl, 
    required this.avatarUrl,
    required this.localImage,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.40;

    final ImageProvider fondoImage = fondoUrl.isNotEmpty
        ? NetworkImage(fondoUrl)
        : const AssetImage('assets/images/default_bg.png') as ImageProvider; 
        
    final ImageProvider avatarImage = avatarUrl.isNotEmpty
        ? NetworkImage(avatarUrl)
        : const AssetImage('assets/images/perfil.png') as ImageProvider;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: headerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: fondoImage, 
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const Spacer(),
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
                // Avatar circular con funcionalidad de clic
                GestureDetector(
                  onTap: onImagePick, // Al hacer clic en la imagen se abre el diálogo
                  child: Container(
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
                      // CORRECCIÓN: Lógica visual corregida usando parámetros
                      image: DecorationImage(
                        image: localImage != null 
                            ? FileImage(localImage!) 
                            : avatarImage, 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Icono de Edit (Solo visual, no funcional)
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
                      Icons.edit, // Cambiado a icono de edit
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
} // CORRECCIÓN: Faltaba esta llave de cierre
// -------------------------------------------------------------------------
// WIDGET DE LA SECCIÓN DE INFORMACIÓN 
// -------------------------------------------------------------------------

class _ProfileInfoSection extends StatelessWidget {
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
        const SizedBox(height: 70), 
        const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _kPrimaryTextColor,
          ),
        ),

        const SizedBox(height: 30),

        _buildTextField(
            label: 'Nombres:', controller: nombresCtrl, isEditable: true),
        _buildTextField(
            label: 'Apellidos:', controller: apellidosCtrl, isEditable: true),
        _buildTextField(
            label: 'Número de teléfono:', // Corregido typo
            controller: telefonoCtrl,
            isEditable: true),

        _buildTextField(
            label: 'Cédula:', controller: cedulaCtrl, isEditable: false),
        _buildTextField(
            label: 'Correo:', controller: correoCtrl, isEditable: false),

        const SizedBox(height: 30),

        _buildGenderSelector(),

        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

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

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Género',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _kPrimaryTextColor,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            GestureDetector(
              onTap: () => onGenderChanged('masculino'),
              child: _buildGenderButton(
                Icons.male, 
                selectedGender == 'masculino',
              ),
            ),
            const SizedBox(width: 15),
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

  Widget _buildGenderButton(IconData icon, bool isSelected) {
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