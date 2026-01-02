import 'package:auth_company/features/registro_asistencia/views/registerList.dart';
import 'package:auth_company/features/registro_asistencia/views/registroExitoso.dart';
import 'package:auth_company/features/registro_asistencia/views/registroScan.dart';
import 'package:auth_company/features/registro_asistencia/views/registroManual.dart';
import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login/login_screen.dart';
import 'features/auth/register/register_screen.dart';
import 'features/home/home_layout.dart';
import 'features/home/views/home_screen.dart';
import 'features/auth/splash_screen_welcome.dart';

import 'features/sucursales/views/sucursal.dart';
import 'features/sucursales/views/detalleSucursal.dart';

import 'package:auth_company/features/kpis/views/kpis.dart';

import 'features/horarios/views/horario.dart';

import 'package:auth_company/features/notificaciones/views/notificaciones.dart';

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

        //AppRoutes.profile: (context) => ProfileScreen(uid: ),
        AppRoutes.registroExitoso:
            (context) => const HomeLayout(child: RegistroExitosoScreen()),
        AppRoutes.registroScan:
            (context) => const HomeLayout(child: RegistroScanScreen()),
        AppRoutes.registroList:
            (context) => const HomeLayout(child: RegistroEmpleados()),
        AppRoutes.registroManual:
            (context) => const HomeLayout(child: RegistroManual()),

        AppRoutes.sucursal:
            (context) => const HomeLayout(child: SucursalPage()),
        AppRoutes.detalleSucursal:
            (context) => const HomeLayout(child: PantallaSucursal()),

        AppRoutes.kpis: 
        (context) => const HomeLayout(child: KpisScreen(companyId: '', employeeId: '',)),

        AppRoutes.horario: 
        (context) => const HomeLayout(child: Horario()),

        AppRoutes.notificaciones: 
        (context) => const HomeLayout(child: HistorialNotificaciones()),
      },
    );
  }
}
