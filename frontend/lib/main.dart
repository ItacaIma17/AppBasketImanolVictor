// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tfg_appfede/screens/PantallaRedireccion.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/services/loggerService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LoggerService.setDebugMode(kDebugMode);

  // Inicializar el servicio de autenticación
  await AutenticacionService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Baloncesto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      /// Cuando user entra se redirige a pantalla segun su rol
      home: const SplashScreen(),
    );
  }
}