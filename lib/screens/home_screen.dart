import 'package:flutter/material.dart';
import '../widgets/lottie_animation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AuthCompany'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              LottieAnimationWidget(
                animationPath: 'lib/assets/animaciones/Check Mark - Success.json',
                repeat: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}






/*import 'package:flutter/material.dart';
import '../widgets/lottie_animation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reproductor de Video')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Video desde internet
            VideoPlayerWidget(
              url: 'lib/assets/videos/authCompany.mp4',
              isAsset: true,
              loop: true,
              autoPlay: true,
            ),
          ],
        ),
      ),
    );
  }
}
*/
