import 'package:flutter/material.dart';
import '../widgets/lottie_animation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'AuthCompany',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const LottieAnimationWidget(
              animationPath: 'lib/assets/animaciones/loading.json',
              width: 250,
              height: 250,
              repeat: false,
            ),
          ],
        ),
      ),
    );
  }
}
