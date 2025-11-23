import 'package:flutter/material.dart';

// Definición de colores
const Color _kPrimaryTextColor = Colors.black87;
const Color _kSecondaryTextColor = Colors.black54;
const Color _kLightGrey = Color(0xFFE0E0E0);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Scaffold con fondo blanco
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // El header y el avatar están en el mismo widget con Stack
            _ProfileHeader(),

            // Contenido de la información del perfil
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: _ProfileInfoSection(),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET DE LA CABECERA (Fondo, Avatar, Menú) ---
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    // Altura del área superior con la imagen (aproximadamente 35-40% de la pantalla)
    final double headerHeight = screenHeight * 0.40;

    return Stack(
      clipBehavior: Clip.none, // Permite que el avatar se salga del contenedor
      children: [
        // 1. Contenedor de la Imagen de Fondo y Sombra Difuminada
        Container(
          height: headerHeight,
          width: double.infinity,
          // La imagen de fondo superior (cabeza y hombros del usuario)
          decoration: const BoxDecoration(
            image: DecorationImage(
              // Usamos una imagen de asset para simular el fondo
              image: NetworkImage(
                'https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW0lQzMlQTFnZW5lcyUyMGltcHJlc2lvbmFudGVzfGVufDB8fDB8fHww&fm=jpg&q=60&w=3000',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            // El SafeArea envuelve solo el botón de menú para no superponerlo
            children: [
              const Spacer(),
              // Gradiente Difuminado (Fade-out) en la parte inferior de la imagen
              Container(
                height: 100, // Altura del difuminado
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(
                        1.0,
                      ), // Se difumina a blanco sólido
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Avatar de Perfil Grande y Flotante
        Positioned(
          top:
              headerHeight -
              110, // Posiciona el centro del avatar cerca del final de la cabecera
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 180, // Tamaño grande del avatar
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
                    // Avatar (la parte central de la cabeza)
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://plus.unsplash.com/premium_photo-1711031505781-2a45c879ceac?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW0lQzMlQTFnZW5lcyUyMGltcHJlc2lvbmFudGVzfGVufDB8fDB8fHww&fm=jpg&q=60&w=3000',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Botón de la Cámara
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

// --- WIDGET DE LA SECCIÓN DE INFORMACIÓN ---
class _ProfileInfoSection extends StatelessWidget {
  const _ProfileInfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70), // Espacio para el avatar flotante
        // Título "Perfil"
        const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _kPrimaryTextColor,
          ),
        ),

        const SizedBox(height: 30),

        // Campos de Información
        _buildProfileField('Nombres:', 'Carlos Michael'),
        _buildProfileField('Apellidos:', 'Lopez Ojeda'),
        _buildProfileField('Cedula:', '1150836318'),
        _buildProfileField('Correo:', 'drea.lovebooks@gmail.com'),
        _buildProfileField('Numero de telefono', '0969621169'),

        const SizedBox(height: 30),

        // Sección Género
        _buildGenderSection(),

        const SizedBox(height: 50),
      ],
    );
  }

  // Widget para cada campo de información (título, valor, divisor)
  Widget _buildProfileField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del campo (Ej: Nombres:)
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

          // Valor del campo (Ej: Carlos Michael)
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: _kSecondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),

          // Línea divisora
          Container(height: 1, color: _kLightGrey),
        ],
      ),
    );
  }

  // Widget para la sección de Género (botones con íconos)
  Widget _buildGenderSection() {
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
            // Botón Hombre (Seleccionado)
            _buildGenderButton(Icons.person, true),
            const SizedBox(width: 15),
            // Botón Mujer (No Seleccionado)
            _buildGenderButton(Icons.person_outline, false),
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
        color:
            isSelected
                ? Colors.grey[600]
                : Colors.white, // Gris oscuro si está seleccionado
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.grey[600]! : _kLightGrey,
          width: isSelected ? 0 : 1,
        ),
        boxShadow:
            isSelected
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
        // Usamos íconos de persona genéricos para simular los de la imagen
        icon,
        color: isSelected ? Colors.white : Colors.black54,
        size: 30,
      ),
    );
  }
}
