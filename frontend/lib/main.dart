// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tfg_appfede/screens/Inicio/InicioSesion.dart';
import 'package:tfg_appfede/screens/Liga/LigaService.dart';
import 'package:tfg_appfede/screens/PantallaRedireccion.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/services/equipoService.dart';
import 'package:tfg_appfede/services/jugadorService.dart';
import 'package:tfg_appfede/services/loggerService.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    LoggerService.setDebugMode(kDebugMode);

  // Inicializar el servicio de autenticación
  await AutenticacionService.init();
  // Cargar datos de la BD al iniciar
  try {
    final ligas = await LigaService.listarLigas();
    final equipos = await EquipoService.listarEquipos();
    final jugadores = await JugadorService.listarJugadores();

    print("✓ Datos cargados correctamente");
  } catch (e) {
    print("✗ Error cargando datos: $e");
  }
  
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