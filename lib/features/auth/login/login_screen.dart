import 'package:flutter/material.dart';
import 'package:auth_company/routes/app_routes.dart';
import 'login_service.dart'; // Importamos el servicio

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
        // Si el login fue exitoso, navega al Home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // Si falló, muestra un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Credenciales incorrectas")),
        );
      }
    }
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
