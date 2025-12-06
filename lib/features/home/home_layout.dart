import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

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
  final GlobalKey previewKey = GlobalKey(); // ← YA NO ES STATIC
  ui.Image? screenImage;

  Future<void> captureScreen() async {
    try {
      final boundary = previewKey.currentContext?.findRenderObject();

      if (boundary is! RenderRepaintBoundary) {
        print("Render aún no listo");
        return;
      }

      if (boundary.debugNeedsPaint) {
        Future.delayed(const Duration(milliseconds: 100), captureScreen);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 0.5);

      if (mounted) {
        setState(() {
          screenImage = image;
        });
      }
    } catch (e) {
      print("Error capturando pantalla: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) captureScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomHomeAppBar(),
      drawer: AppDrawer(screenImage: screenImage),
      body: Stack(
        children: [
          RepaintBoundary(
            key: previewKey,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0), // ← Evita overflow
              child: widget.child,
            ),
          ),

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
