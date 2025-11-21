import 'package:flutter/material.dart';
import 'package:auth_company/features/auth/login/login_service.dart'; 
import 'drawer.dart';
import 'footer.dart';
import 'app_bar.dart';

class HomeLayout extends StatefulWidget {
  final Widget child;
  final int? initialIndex;

  const HomeLayout({super.key, required this.child, this.initialIndex});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  String? _currentUid;
  bool _isLoading = true;
  final LoginService _loginService = LoginService(); // Instanciar el servicio

  @override
  void initState() {
    super.initState();
    _loadUserUid(); // Llamar a la carga de datos
  }

  // Método para cargar el UID
  Future<void> _loadUserUid() async {
    final uid = await _loginService.getSavedUid();
    setState(() {
      _currentUid = uid;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar un indicador de carga si aún no tenemos el UID
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Manejar si el UID es nulo (ej. redirigir a Login)
    if (_currentUid == null) {
      // Usar Navigator.pushReplacementNamed para redirigir al login
      // Navigator.pushReplacementNamed(context, AppRoutes.login);
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no autenticado.')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomHomeAppBar(),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          widget.child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // Pasar el UID al footer
            child: AnimatedFloatingFooter(
              initialIndex: widget.initialIndex ?? 0,
              uid: _currentUid, 
            ),
          ),
        ],
      ),
    );
  }
}