import 'package:flutter/material.dart';

// Importar el enum centralizado
import '../models/genero.dart';

class FormSection extends StatelessWidget {
  final double width;
  final double height;
  final GlobalKey<FormState> formKey;
  final GlobalKey<FormState> formKey2;
  final GlobalKey<FormState> formKey3;
  final TextEditingController nombresController;
  final TextEditingController apellidosController;
  final TextEditingController cedulaController;
  final TextEditingController correoController;
  final TextEditingController telefonoController;
  final TextEditingController usuarioController;
  final TextEditingController contrasenaController;
  final TextEditingController confirmarContrasenaController;
  final TextEditingController empresaController;
  final TextEditingController sucursalController;
  final TextEditingController dateController;
  final Genero selectedGender;
  final DateTime selectedDate;
  final Function(Genero?) onGenderChanged;
  final Function(DateTime) onDateChanged;
  final Function(bool) onPasswordVisibilityChanged;
  final Function(bool) onConfirmPasswordVisibilityChanged;
  final bool obscurePassword;
  final bool obscurePassword2;

  const FormSection({
    super.key,
    required this.width,
    required this.height,
    required this.formKey,
    required this.formKey2,
    required this.formKey3,
    required this.nombresController,
    required this.apellidosController,
    required this.cedulaController,
    required this.correoController,
    required this.telefonoController,
    required this.usuarioController,
    required this.contrasenaController,
    required this.confirmarContrasenaController,
    required this.empresaController,
    required this.sucursalController,
    required this.dateController,
    required this.selectedGender,
    required this.selectedDate,
    required this.onGenderChanged,
    required this.onDateChanged,
    required this.onPasswordVisibilityChanged,
    required this.onConfirmPasswordVisibilityChanged,
    required this.obscurePassword,
    required this.obscurePassword2,
  });

  @override
  Widget build(BuildContext context) {
    // Este widget no se usa directamente, las formas se acceden por buildForms()
    return Container();
  }

  List<Widget> buildForms() {
    return [
      _buildFirstPage(),
      _buildSecondPage(),
      _buildThirdPage(),
    ];
  }

  // Primera pantalla del formulario
  Widget _buildFirstPage() {
    return Form(
      key: formKey,
      child: ListView(
        padding: EdgeInsets.only(top: height * 0.02),
        children: [
          TextFormField(
            controller: nombresController,
            keyboardType: TextInputType.name,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(
              labelText: "Nombres",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
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
            controller: apellidosController,
            keyboardType: TextInputType.name,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(
              labelText: "Apellidos",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
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
            controller: cedulaController,
            keyboardType: TextInputType.number,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(
              labelText: "Cédula",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
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
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(
              labelText: "Correo",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
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
                }*/
              return null;
            },
          ),

          SizedBox(height: height * 0.02),
          TextFormField(
            controller: telefonoController,
            keyboardType: TextInputType.phone,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(
              labelText: "Telefono",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
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
                }*/
              return null;
            },
          ),
        ],
      ),
    );
  }

  //Segunda pantalla del formulario
  Widget _buildSecondPage() {
    final labelStyle = TextStyle(color: Colors.white70, fontSize: width * 0.04);

    return ListView(
      padding: EdgeInsets.only(top: height * 0.02, left: width * 0.06, right: width * 0.06),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Text("Seleccione Genero", style: labelStyle),
        ),
        SizedBox(height: height * 0.02),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGenderSelector(icon: Icons.male, gender: Genero.masculino),
            const SizedBox(width: 24),
            _buildGenderSelector(icon: Icons.female, gender: Genero.femenino),
          ],
        ),
        SizedBox(height: height * 0.04),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Text("Seleccione año de nacimiento", style: labelStyle),
        ),
        SizedBox(height: height * 0.025),

        InkWell(
          onTap: () => onDateChanged(selectedDate),
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDatePart(label: "Dia", value: selectedDate.day.toString().padLeft(2, '0')),
                _buildDateDivider(),
                _buildDatePart(label: "Mes", value: selectedDate.month.toString().padLeft(2, '0')),
                _buildDateDivider(),
                _buildDatePart(label: "Año", value: selectedDate.year.toString()),
              ],
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
      ],
    );
  }

  Widget _buildGenderSelector({required IconData icon, required Genero gender}) {
    final bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () => onGenderChanged(gender),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withOpacity(0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: width * 0.08),
      ),
    );
  }

  Widget _buildDatePart({required String label, required String value}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: width * 0.04)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.white, fontSize: width * 0.065, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDateDivider() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const VerticalDivider(color: Colors.white54, thickness: 1),
    );
  }

  // Tercera pantalla del formulario
  Widget _buildThirdPage() {
    return Form(
      key: formKey2,
      child: ListView(
        padding: EdgeInsets.only(top: height * 0.02),
        children: [
          SizedBox(height: height * 0.05),

          TextFormField(
            controller: usuarioController,
            keyboardType: TextInputType.name,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(
              labelText: "Usuario",
              labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Usuario cannot be empty";
              }
              if (value.length < 5) {
                return "At least 5 characters required";
                }
              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value)) {
                  return "Invalid usuario (only letters, numbers, - or _)";
                }
              return null;
            },
          ),

          SizedBox(height: height * 0.03),
          TextFormField(
            controller: contrasenaController,
            obscureText: obscurePassword,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              suffixIcon: IconButton(
                icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color.fromARGB(255, 255, 255, 255)),
                onPressed: () => onPasswordVisibilityChanged(!obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password cannot be empty";
                }
              if (value.length < 8) {
                return "At least 8 characters required";
                }
              return null;
            },
          ),

          SizedBox(height: height * 0.03),
          TextFormField(
            controller: confirmarContrasenaController,
            obscureText: obscurePassword2,
            style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            decoration: InputDecoration(
              hintText: "Confirmar Password",
              hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: width * 0.04),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              suffixIcon: IconButton(
                icon: Icon(obscurePassword2 ? Icons.visibility_off : Icons.visibility, color: const Color.fromARGB(255, 255, 255, 255)),
                onPressed: () => onConfirmPasswordVisibilityChanged(!obscurePassword2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password cannot be empty";
                }
                if (value != contrasenaController.text) {
                  return "Passwords do not match";
                }
              if (value.length < 8) {
                return "At least 8 characters required";
                }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
