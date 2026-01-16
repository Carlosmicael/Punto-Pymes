import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final int currentPage;
  final double width;
  final double height;
  final Widget Function(double) buildPageIndicator;

  const HeaderSection({
    super.key,
    required this.currentPage,
    required this.width,
    required this.height,
    required this.buildPageIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: height * 0.05),

        // Logo y título
        AnimatedOpacity(
          opacity: currentPage <= 4 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: width * 0.25,
            height: height * 0.12,
            child: Image.asset('lib/assets/images/logoTalenTrack.png'),
          ),
        ),
        SizedBox(height: height * 0.015),

        AnimatedOpacity(
          opacity: currentPage <= 4 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: height * 0.05, 
            child: Center(
              child: Text(
                "Register",
                style: TextStyle(
                  fontSize: width * 0.075,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 7.5,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.015),

        // Indicador de página
        AnimatedOpacity(
          opacity: currentPage <= 4 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: height * 0.03,
            child: Center(child: buildPageIndicator(width)),
          ),
        ),
        SizedBox(height: height * 0.03),
      ],
    );
  }
}
