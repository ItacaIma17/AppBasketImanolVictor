// Pantalla para ver acta (entrenador)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/actaService.dart';

class VerActaEntrenadorPage extends StatelessWidget {
  final int partidoId;

  const VerActaEntrenadorPage({super.key, required this.partidoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acta del Partido')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Vista del acta en desarrollo'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final file = await ActaService.descargarActaPdf(partidoId);
                  // Abrir PDF
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Descargar PDF'),
            ),
          ],
        ),
      ),
    );
  }

}