import 'package:auth_company/features/tracking/location_tracking_service.dart';
import 'package:auth_company/features/tracking/services/branch_config_service.dart';
import 'package:auth_company/features/tracking/services/socket_service.dart';
import 'package:auth_company/location_permission_service.dart';
import 'package:flutter/material.dart';
import 'package:auth_company/routes/app_routes.dart';
import 'login_service.dart'; // Importamos el servicio
import 'package:auth_company/auth_storage.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final LoginService _loginService = LoginService(); // Instancia del servicio
  

  /// Función que valida el formulario y llama al servicio de login
  void _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      final token = await _loginService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );



      if (token != null) {
        bool granted = await LocationPermissionService.requestPermissions();
        AuthStorage.saveToken(token);

        print("PERMISOS DE UBICACIÓN: $granted");

        if (!granted) {
          print("Permisos de ubicación denegados");
          return;
        }

        print("TOKEN: $token");

        final branchData = await _loginService.getBranchConfig(token);
        print("DATOS DE SUCURSAL: $branchData");

        await BranchConfigService.saveBranchConfig(
          lat: branchData['latitud'],
          lng: branchData['longitud'],
          radius: branchData['rangoGeografico'],
          threshold: branchData['umbral'], 
          uid: branchData['uid'],
          companyId: branchData['companyId'],
          branchId: branchData['branchId'],
        );

        var uid = await BranchConfigService.getUid();
        print("DATOS GUARDADOS EN EL DISPOSITIVO: $uid");


        String userId = branchData['uid'];
        String companyId = branchData['companyId'];
        String branchId = branchData['branchId'];

        print("DATOS DE EMPRESA: $companyId");
        print("DATOS DE SUCURSAL: $branchId");
        print("DATOS DE USUARIO: $userId");
        

        SocketService.connect(
          userId: userId,
          companyId: companyId,
          branchId: branchId,
        );

        print("SOCKET CONECTADO");

        await LocationTrackingService.startTracking();
        print("TRACKING INICIADO");


        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }else {
        _showErrorDialog();
      }





    }
  }

  void _showErrorDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Error",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.80,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono estilo Android (Material)
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 60,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Credenciales incorrectas",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "El usuario o la contraseña no coinciden.\nIntente nuevamente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),

                  const SizedBox(height: 25),

                  // Botón estilo Material
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Aceptar",
                        style: TextStyle(
                          fontSize: 16,
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

      // Animación suave de desvanecimiento
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo y título
                SizedBox(
                  height: height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/logoTalenTrack.png',
                        width: width * 0.25,
                        height: height * 0.12,
                      ),
                      SizedBox(height: height * 0.015),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Formulario
                SizedBox(
                  height: height * 0.55,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Campo usuario
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            hintText: "Username",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Username cannot be empty";
                            }
                            if (value.length < 5) {
                              return "At least 5 characters required";
                            }
                            final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
                            if (!regex.hasMatch(value)) {
                              return "Invalid username (only letters, numbers, - or _)";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: height * 0.02),

                        // Campo contraseña
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "Password",
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black54,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
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

                        SizedBox(height: height * 0.04),

                        // Botón Login
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEB455E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  height * 0.05,
                                ),
                              ),
                            ),
                            onPressed: _validateAndLogin,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.025),

                        // Link a registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don’t have an account? ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: width * 0.035,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.register,
                                  ),
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.035,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
