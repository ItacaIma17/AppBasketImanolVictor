import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../screens/DetallesPartido.dart';

class TarjetaPartido extends StatelessWidget {
  final Partido partido;

  const TarjetaPartido({
    super.key,
    required this.partido,
  });

  @override
  Widget build(BuildContext context) {
    final esProgramado = partido.esProgramado;
    final esFinalizado = partido.esFinalizado;

    return GestureDetector(
      onTap: () {
        if (!esProgramado) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallePartidoPage(partido: partido),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                  const SizedBox(width: 6),
                  Text(
                    '${partido.fecha} - ${partido.hora}',
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [

                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.naranja.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield, size: 32, color: AppColors.naranja),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          partido.nombreLocal,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: !esProgramado ? AppColors.gradienteNaranjaAmarillo : null,
                      color: esProgramado ? AppColors.naranja.withOpacity(0.2) : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      partido.resultadoTexto,
                      style: TextStyle(
                        fontSize: !esProgramado ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: !esProgramado ? Colors.white : AppColors.naranja,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.amarilloAragon.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield, size: 32, color: AppColors.amarilloAragon),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          partido.nombreVisitante,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.white54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      partido.pabellon,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (esProgramado) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.naranja.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'POR JUGAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.naranja,
                    ),
                  ),
                ),
              ],
              if (esFinalizado) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FINALIZADO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
