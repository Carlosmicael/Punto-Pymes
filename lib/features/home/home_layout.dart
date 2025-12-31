import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui; // Importar dart:ui para ui.Image

import 'package:auth_company/features/auth/login/login_service.dart'; // Importar el servicio de login

import 'drawer.dart'; // Asegúrate de que este drawer acepta screenImage
import 'footer.dart'; // Asegúrate de que este footer acepta initialIndex y uid
import 'app_bar.dart';

class HomeLayout extends StatefulWidget {
  final Widget child;
  final int? initialIndex;

  const HomeLayout({super.key, required this.child, this.initialIndex});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  // --- Lógica de Autenticación (del archivo original) ---
  String? _currentUid;
  bool _isLoading = true;
  final LoginService _loginService = LoginService();
  late Widget currentChild;

  // --- Lógica de Captura de Pantalla (del archivo copia) ---
  final GlobalKey previewKey = GlobalKey();
  ui.Image? screenImage;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    currentChild = widget.child;
    _loadUserUid(); // Cargar datos del usuario

    // Capturar la pantalla después de que el frame inicial se haya dibujado
    // y un pequeño retraso para asegurar que todo está renderizado.
    /*WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Esperar un poco para asegurar que la UI está estable antes de capturar
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _captureAndOpenDrawer();
    });*/
  }

  // Método para cargar el UID
  Future<void> _loadUserUid() async {
    final uid = await _loginService.getSavedUid();
    setState(() {
      _currentUid = uid;
      _isLoading = false;
    });
  }

  // Método para capturar la pantalla
  /*Future<void> captureScreen() async {
    try {
      final boundary = previewKey.currentContext?.findRenderObject();

      if (boundary is! RenderRepaintBoundary) {
        // print("Render aún no listo");
        return;
      }

      if (boundary.debugNeedsPaint) {
        // Si el boundary necesita pintarse, esperamos un poco y reintentamos.
        Future.delayed(const Duration(milliseconds: 100), captureScreen);
        return;
      }

      // Captura la imagen con un pixelRatio reducido (0.5) para eficiencia
      final image = await boundary.toImage(pixelRatio: 0.5);

      if (mounted) {
        setState(() {
          screenImage = image;
        });
      }
    } catch (e) {
      // print("Error capturando pantalla: $e");
    }
  }*/

  Future<void> _captureAndOpenDrawer() async {
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      _scaffoldKey.currentState?.openDrawer();
      return;
    }

    try {
      RenderRepaintBoundary? boundary =
          previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary != null) {
        // Usamos un pixelRatio bajo (1.0) para que la captura sea instantánea y no pese
        ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        setState(() {
          screenImage = image;
        });
      }
    } catch (e) {
      debugPrint("Error capturando pantalla: $e");
    }
    // 3. Abrimos el drawer DESPUÉS de intentar la captura
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    // 1. Mostrar un indicador de carga si aún no tenemos el UID
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Manejar si el UID es nulo (Usuario no autenticado)
    if (_currentUid == null) {
      // **AQUÍ SE DEBE IMPLEMENTAR LA REDIRECCIÓN A LA PANTALLA DE LOGIN**
      // Por ejemplo: Navigator.pushReplacementNamed(context, AppRoutes.login);
      return const Scaffold(
        body: Center(
          child: Text('Error: Usuario no autenticado. Redirigiendo...'),
        ),
      );
    }

    // 3. Renderizar el layout principal
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomHomeAppBar(onMenuPressed: _captureAndOpenDrawer),
      // Pasar la imagen capturada al Drawer
      drawer: AppDrawer(
        miniChild: currentChild,

        // 🔥 Cuando el usuario toca la miniatura:
        onMiniaturaSelected: (widgetSeleccionado) {
          setState(() {
            currentChild = widgetSeleccionado;
          });

          Navigator.pop(context); // cerrar drawer
        },
      ),
      body: SizedBox(
        height: screenHeight,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                key: isKeyboardOpen ? null : previewKey,
                child: widget.child,
              ),
            ),

            Positioned.fill(
              child: RepaintBoundary( 
                child: currentChild,
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Offstage(
                offstage: isKeyboardOpen, 
                child: AnimatedFloatingFooter(
                  initialIndex: widget.initialIndex ?? 0,
                  uid: _currentUid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
