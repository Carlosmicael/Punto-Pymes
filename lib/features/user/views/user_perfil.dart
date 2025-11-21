import 'package:auth_company/features/user/services/user_service.dart';
import 'package:flutter/material.dart';

// Definición de colores
const Color _kPrimaryTextColor = Colors.black87;
const Color _kSecondaryTextColor = Colors.black54;
const Color _kLightGrey = Color(0xFFE0E0E0);

class ProfileScreen extends StatefulWidget {
  // El UID debe ser pasado a la pantalla
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para los campos
  final UserService _userService = UserService();
  final TextEditingController _nombresCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();

  // No editables (solo lectura)
  final TextEditingController _cedulaCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();

  String _fotoPerfilUrl = '';
  bool _isLoading = true;
  String _selectedGender = 'masculino'; // o el valor que cargues

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Método para cargar datos del Backend
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final data = await _userService.getProfile(widget.uid);

    if (data != null && mounted) {
      // Asignar los valores a los controladores
      _nombresCtrl.text = data['nombres'] ?? '';
      _apellidosCtrl.text = data['apellidos'] ?? '';
      _telefonoCtrl.text = data['telefono'] ?? '';
      _cedulaCtrl.text = data['cedula'] ?? 'N/A';
      _correoCtrl.text = data['correo'] ?? 'N/A';
      _fotoPerfilUrl = data['fotoPerfilUrl'] ?? '';
      _selectedGender = data['genero'] ?? 'masculino';

      setState(() => _isLoading = false);
    } else if (mounted) {
      // Manejo de error si la carga falla
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los datos del perfil.')),
      );
    }
  }

  // Método para guardar la edición
  Future<void> _saveProfileChanges() async {
    // Recolectar solo los datos que se pueden editar
    final userData = {
      "nombres": _nombresCtrl.text,
      "apellidos": _apellidosCtrl.text,
      "telefono": _telefonoCtrl.text,
      "genero": _selectedGender,
    };

    // Intentar actualizar
    final success = await _userService.updateProfile(widget.uid, userData);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '¡Perfil actualizado con éxito!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Falló la actualización.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Si está cargando, muestra un indicador
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Usa el URL de la foto de perfil en el header
            _ProfileHeader(fotoUrl: _fotoPerfilUrl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              // Pasa los controladores y el género a la sección de info
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
            SizedBox(
              width: width * 0.6,
              height: height * 0.065,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB455E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(height * 0.05),
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 45.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 20,
                child: Text(
                  'Hola',
                  style: TextStyle(fontSize: 18, color: Colors.transparent),
                ),
              ),
            ),
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

// WIDGET DE LA CABECERA
class _ProfileHeader extends StatelessWidget {
  final String fotoUrl;

  const _ProfileHeader({required this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.35;

    // Usamos NetworkImage si fotoUrl no está vacío, de lo contrario un ícono de persona.
    final ImageProvider avatarImage =
        fotoUrl.isNotEmpty
            ? NetworkImage(fotoUrl) as ImageProvider
            : const AssetImage(
              'assets/icons/perfil.png',
            ); // Usa un asset por defecto local

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Fondo de color
        Container(
          height: headerHeight,
          decoration: const BoxDecoration(
            color: Colors.redAccent, // Color de fondo
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        // Avatar del Usuario
        Positioned(
          bottom: -50, // Lo mueve 50 unidades fuera del Container
          left: 0,
          right: 0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: avatarImage, // Aquí se carga la imagen
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

// WIDGET DE INFORMACIÓN
class _ProfileInfoSection extends StatelessWidget {
  // Los controladores ahora son obligatorios
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
        const SizedBox(height: 70), // Espacio para que el avatar no se monte
        // Campos Editables
        _buildTextField(
          label: 'Nombres',
          controller: nombresCtrl,
          isEditable: true,
        ),
        _buildTextField(
          label: 'Apellidos',
          controller: apellidosCtrl,
          isEditable: true,
        ),
        _buildTextField(
          label: 'Teléfono',
          controller: telefonoCtrl,
          isEditable: true,
        ),

        // Campos NO Editables (Solo Lectura)
        _buildTextField(
          label: 'Cédula',
          controller: cedulaCtrl,
          isEditable: false,
        ),
        _buildTextField(
          label: 'Correo',
          controller: correoCtrl,
          isEditable: false,
        ),

        const SizedBox(height: 15),

        // Selector de Género
        _buildGenderSelector(),

        const SizedBox(height: 40),
      ],
    );
  }

  // Helper para construir campos de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
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
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly:
                !isEditable, // Deshabilita la edición si isEditable es falso
            style: TextStyle(
              color: isEditable ? _kSecondaryTextColor : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: !isEditable,
              fillColor: isEditable ? Colors.white : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isEditable ? _kLightGrey : Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isEditable ? _kLightGrey : Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Selector de Género
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
            // Botón Masculino
            GestureDetector(
              onTap: () => onGenderChanged('masculino'),
              child: _buildGenderButton(
                Icons.male,
                selectedGender == 'masculino',
              ),
            ),
            const SizedBox(width: 15),
            // Botón Femenino
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

  // Constructor de botones de género
  Widget _buildGenderButton(IconData icon, bool isSelected) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[100] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : _kLightGrey,
          width: isSelected ? 2 : 1,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ]
                : null,
      ),
      child: Icon(
        icon,
        size: 30,
        color: isSelected ? Colors.blueAccent : Colors.grey[600],
      ),
    );
  }
}
