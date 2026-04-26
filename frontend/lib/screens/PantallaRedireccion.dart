// lib/screens/SplashScreen.dart

import 'package:flutter/material.dart';
import '../config/common/resources/colores.dart';
import '../services/autenticacion_service.dart';
import 'Admin/PanelAdminPage.dart';
import 'Entrenador/PanelEntrenadorPage.dart';
import 'InicioApp.dart';
import 'Inicio/InicioSesion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    // Esperar 2 segundos para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar si hay sesión activa
    final isLoggedIn = await AutenticacionService.isLoggedIn();

    if (isLoggedIn) {
      // Obtener el usuario actual
      final usuario = AutenticacionService.usuarioActual;

      print('🎭 Usuario logueado: ${usuario?.username}, Rol: ${usuario?.role}');

      // Redirigir según el rol
      if (usuario?.isAdmin == true) {
        print('👑 Redirigiendo a Panel Admin');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PanelAdminPage()),
        );
      } else if (usuario?.isEntrenador == true) {
        print('🏆 Redirigiendo a Panel Entrenador');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PanelEntrenadorPage()),
        );
      } else if (usuario?.isJugador == true) {
        print('🏀 Redirigiendo a Panel Jugador');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioPage()),
        );
      } else {
        print('👤 Redirigiendo a Inicio');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioPage()),
        );
      }
    } else {
      print('🔓 No hay sesión, redirigiendo a Login');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InicioSesionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_basketball,
                size: 100,
                color: AppColors.naranja,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: AppColors.naranja,
              ),
              SizedBox(height: 20),
              Text(
                'Cargando...',
                style: TextStyle(
                  color: AppColors.blanco,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}