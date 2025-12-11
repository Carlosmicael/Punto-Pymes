import 'package:auth_company/features/home/views/detalleSucursal.dart';
import 'package:auth_company/features/home/views/kpis.dart';
import 'package:flutter/material.dart';

// 📌 IMPORTS HOME
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
import 'package:auth_company/features/home/views/home.dart';
import 'package:auth_company/features/home/home_layout.dart';

// 📌 IMPORTS AUTH
import 'package:auth_company/features/auth/splash_screen.dart';
import 'package:auth_company/features/auth/login/login_screen.dart';
import 'package:auth_company/features/auth/register/register_screen.dart';
import 'package:auth_company/features/auth/splash_screen_welcome.dart';

// 📌 ROUTES
import 'routes/app_routes.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto Pymes',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: {
        // AUTH
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.splashWelcome: (context) => const StartScreen(),

        // HOME
        AppRoutes.home: (context) => HomeLayout(child: Home()),

        // PANTALLAS CON LAYOUT
        AppRoutes.profile:
            (context) => HomeLayout(child: const ProfileScreen()),
        AppRoutes.registroempleados:
            (context) => HomeLayout(child: const RegistroEmpleados()),
        AppRoutes.calendario:
            (context) => HomeLayout(child: const Calendario()),
        AppRoutes.horario: (context) => HomeLayout(child: const Horario()),
        AppRoutes.capas: (context) => HomeLayout(child: const Historial()),
        AppRoutes.sucursal:
            (context) => HomeLayout(child: const SucursalPage()),
        AppRoutes.registroExitoso:
            (context) => HomeLayout(child: const RegistroExitosoScreen()),
        AppRoutes.registroScan:
            (context) => HomeLayout(child: const RegistroScanScreen()),
        AppRoutes.registroManual:
            (context) => HomeLayout(child: const RegistroManual()),
        AppRoutes.vacaciones:
            (context) => HomeLayout(child: const VacacionesScreen()),
        AppRoutes.solicitudVacacion:
            (context) => HomeLayout(child: const SolicitudVacaciones()),
        AppRoutes.detalleSucursal:
            (context) => HomeLayout(child: PantallaSucursal()),
        AppRoutes.kpis: (context) => HomeLayout(child: HomeworkScreen()),
      },
    );
  }
}
