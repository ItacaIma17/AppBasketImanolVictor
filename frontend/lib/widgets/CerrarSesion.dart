import 'package:flutter/material.dart';
import 'package:tfg_appfede/screens/Inicio/InicioSesion.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';

class DialogoCerrarSesion extends StatelessWidget {
  const DialogoCerrarSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cerrar Sesión'),
      content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            await AutenticacionService.cerrarSesion();
            if (context.mounted) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const InicioSesionPage()),
              );
            }
          },
          child: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

