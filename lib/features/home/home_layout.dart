import 'package:flutter/material.dart';

import 'drawer.dart';
import 'footer.dart';
import 'views/app_bar.dart';

class HomeLayout extends StatefulWidget {
  final Widget child;
  final int? initialIndex;

  const HomeLayout({super.key, required this.child, this.initialIndex});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  // 👉 VARIABLE QUE SE ACTUALIZA
  late Widget currentChild;

  @override
  void initState() {
    super.initState();
    currentChild = widget.child; // Inicia con el contenido enviado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomHomeAppBar(),

      // Drawer ahora envía miniatura → actualiza el layout
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

      body: Stack(
        children: [
          // 👉 Renderizamos el widget dinámico
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: currentChild,
          ),

          // Footer animado
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedFloatingFooter(
              initialIndex: widget.initialIndex ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
