import 'package:auth_company/features/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showVideo = false;


  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenSplash = prefs.getBool('hasSeenSplash') ?? false;

    if (hasSeenSplash) {
      _goToLogin();
    } else {
      setState(() => _showVideo = true);
      _initializeVideo();
      await prefs.setBool('hasSeenSplash', true);
    }
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('lib/assets/videos/authCompany.mp4')
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration &&
          _controller.value.isInitialized) {
        _goToLogin();
      }
    });
  }



  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(), 
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>  FadeTransition(opacity: animation,child: child)
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          image: _showVideo? const DecorationImage(image: AssetImage('lib/assets/images/baPuntopymes.png'),fit: BoxFit.cover,) : null,
          color: _showVideo ? null : Colors.white,
        ),
        child: Center(
          child: _isInitialized
              ? SizedBox(
                  width: screenWidth,
                  height: screenHeight,
                  child:FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  child: Transform.scale(
                    scale: 1.04,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ): const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
