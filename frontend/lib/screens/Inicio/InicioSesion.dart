// lib/screens/Inicio/InicioSesion.dart

import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/screens/Admin/PanelAdminPage.dart';
import 'package:tfg_appfede/screens/Entrenador/PanelEntrenadorPage.dart';
import 'package:tfg_appfede/screens/InicioApp.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'Registro.dart';

class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool mostrarPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Logo + título
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradienteNaranjaAmarillo,
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            'assets/images/LogoFAB.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.sports_basketball,
                                  size: 80,
                                  color: AppColors.blanco,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "FEDERACIÓN ARAGONESA DE BASKET",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "INICIAR SESIÓN",
                        style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Campo email
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: _inputDecoration("Correo Electrónico"),
                ),

                const SizedBox(height: 20),

                // Campo contraseña
                TextField(
                  controller: passCtrl,
                  obscureText: !mostrarPassword,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: _inputDecoration("Contraseña").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        mostrarPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.blancoOpacidad70,
                      ),
                      onPressed: () {
                        setState(() => mostrarPassword = !mostrarPassword);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Olvidaste contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implementar recuperación de contraseña
                      },
                      child: const Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(color: AppColors.blanco),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón iniciar sesión
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.naranja,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "INICIAR SESIÓN",
                        style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divisor
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.blancoOpacidad54)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'O',
                        style: TextStyle(color: AppColors.blanco),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.blancoOpacidad54)),
                  ],
                ),

                const SizedBox(height: 20),

                // Boton Google
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: _socialButton(
                    text: "Continuar con Google",
                    icon: Icons.g_mobiledata,
                    onPressed: () {
                    },
                  ),
                ),           

                const SizedBox(height: 30),

                // Registro
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Registro()),
                        );
                      },
                      child: const Text(
                        "¿No tienes cuenta? REGÍSTRATE",
                        style: TextStyle(
                          color: AppColors.blanco,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón de invitado
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const InicioPage()),
                        );
                      },
                      child: const Text(
                        "Continuar como invitado",
                        style: TextStyle(
                          color: AppColors.blancoOpacidad70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.blancoOpacidad70),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.blancoOpacidad54),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.blanco),
      ),
    );
  }

  Widget _socialButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.blanco),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.blanco),
        label: Text(
          text,
          style: const TextStyle(color: AppColors.blanco),
        ),
      ),
    );
  }

  /// Manejar el inicio de sesión con redirección por rol
  void _handleLogin() async {
    // Validaciones básicas
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Intentar iniciar sesión
      bool loginExitoso = await AutenticacionService.login(
        emailCtrl.text,
        passCtrl.text,
      );

      if (loginExitoso && mounted) {
        // Obtener el usuario actual después del login
        final usuario = AutenticacionService.usuarioActual;

        print('✅ Login exitoso para: ${usuario?.username}');
        print('🎭 Rol del usuario: ${usuario?.role}');
        print('👑 Es administrador: ${usuario?.isAdmin}');

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Redirigir según el rol
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          if (usuario?.isAdmin == true) {
            // Redirigir al Panel de Administrador
            print('👑 Redirigiendo a PanelAdminPage');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PanelAdminPage()),
            );
          } else if (usuario?.isEntrenador == true) {
            // Redirigir al Panel de Entrenador
            print('🏆 Redirigiendo a PanelEntrenadorPage');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PanelEntrenadorPage()),
            );
          } else if (usuario?.isJugador == true) {
            // Redirigir al Panel de Jugador
            print('🏀 Redirigiendo a PanelJugadorPage');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InicioPage()),
            );
          } else {
            // Redirigir a Inicio normal
            print('👤 Redirigiendo a InicioPage');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InicioPage()),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email o contraseña incorrectos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error en login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}