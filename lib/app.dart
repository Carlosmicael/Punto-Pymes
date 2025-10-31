import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login/login_screen.dart';
import 'features/auth/register/register_screen.dart';
import 'features/home/home_layout.dart';
import 'features/home/views/home_screen.dart';
import 'features/auth/splash_screen_welcome.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto Pymes',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeLayout(child: HomeScreen()),
        AppRoutes.splashWelcome: (context) => const StartScreen(),
      },
    );
  }
}
