import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimationWidget extends StatelessWidget {
  final String animationPath;
  final double width;
  final double height;
  final bool repeat;

  const LottieAnimationWidget({
    super.key,
    required this.animationPath,
    this.width = 200,
    this.height = 200,
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        animationPath,
        width: width,
        height: height,
        repeat: repeat,
        fit: BoxFit.contain,
      ),
    );
  }
}
