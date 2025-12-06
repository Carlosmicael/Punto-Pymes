import 'package:auth_company/features/home/views/solicitudVacacion.dart';
import 'package:auth_company/features/home/views/vacaciones.dart';
import 'package:auth_company/features/home/views/calendario.dart';
import 'package:auth_company/features/home/views/capas.dart';
import 'package:auth_company/features/home/views/horario.dart';
import 'package:auth_company/features/home/views/register.dart';
import 'package:auth_company/features/home/views/registroExitoso.dart';
import 'package:auth_company/features/home/views/registroManual.dart';
import 'package:auth_company/features/home/views/registroScan.dart';
import 'package:auth_company/features/home/views/sucursal.dart';
import 'package:auth_company/features/home/views/user_perfil.dart';

import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login/login_screen.dart';
import 'features/auth/register/register_screen.dart';
import 'features/home/home_layout.dart';
import 'features/home/views/home.dart';
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
        AppRoutes.home:
            (context) =>
                const HomeLayout(child: Home()), // Si HomeLayout permite const

        AppRoutes.splashWelcome: (context) => const StartScreen(),
        AppRoutes.profile:
            (context) => const HomeLayout(child: ProfileScreen()),
        AppRoutes.registroempleados:
            (context) => const HomeLayout(child: RegistroEmpleados()),
        AppRoutes.calendario:
            (context) => const HomeLayout(child: Calendario()),
        AppRoutes.horario: (context) => const HomeLayout(child: Horario()),
        AppRoutes.capas: (context) => const HomeLayout(child: Historial()),
        AppRoutes.sucursal:
            (context) => const HomeLayout(child: SucursalPage()),
        AppRoutes.registroExitoso:
            (context) => const HomeLayout(child: RegistroExitosoScreen()),
        AppRoutes.registroScan:
            (context) => const HomeLayout(child: RegistroScanScreen()),
        AppRoutes.registroManual:
            (context) => const HomeLayout(child: RegistroManual()),
        AppRoutes.vacaciones:
            (context) => const HomeLayout(child: VacacionesScreen()),
        AppRoutes.solicitudVacacion:
            (context) => const HomeLayout(child: SolicitudVacaciones()),
      },
    );
  }
}
