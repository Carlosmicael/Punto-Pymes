import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class RegistroManual extends StatefulWidget {
  const RegistroManual({super.key});

  @override
  State<RegistroManual> createState() => _RegistroManualState();
}

class _RegistroManualState extends State<RegistroManual> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _sucursalController = TextEditingController();

  DateTime? _fechaSeleccionada;

  /// IMAGEN
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final circleSize = width * 0.4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                          decoration: InputDecoration(
                            labelText: "Fecha",
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.04,
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
                              color: const Color.fromARGB(255, 255, 255, 255),
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
                          onPressed: () => setState(() => _imageFile = null),
                          icon: const Icon(Icons.delete, color: Colors.black),
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
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.018,
                        horizontal: width * 0.12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
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
                            "Registrar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.045,
                            ),
                          ),
                          SizedBox(width: width * 0.02),
                          SvgPicture.asset(
                            "lib/assets/images/Siguiente.svg",
                            width: width * 0.045,
                          ),
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
    );
  }
}
