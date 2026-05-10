import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

class NavegadorJornadas extends StatelessWidget {
  final int jornadaActual;
  final int totalJornadas;
  final Function(int) onJornadaChanged;
  final Map<int, int>? partidosPorJornada;

  const NavegadorJornadas({
    super.key,
    required this.jornadaActual,
    required this.totalJornadas,
    required this.onJornadaChanged,
    this.partidosPorJornada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              GestureDetector(
                onTap: jornadaActual > 1
                    ? () => onJornadaChanged(jornadaActual - 1)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: jornadaActual > 1 ? AppColors.naranja : Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left, color: AppColors.blanco, size: 28),
                ),
              ),

              const SizedBox(width: 24),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.gradienteNaranjaAmarillo,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.naranja.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'JORNADA',
                      style: TextStyle(
                        color: AppColors.blanco,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$jornadaActual',
                      style: const TextStyle(
                        color: AppColors.blanco,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '/ $totalJornadas',
                      style: TextStyle(
                        color: AppColors.blanco.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              GestureDetector(
                onTap: jornadaActual < totalJornadas
                    ? () => onJornadaChanged(jornadaActual + 1)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: jornadaActual < totalJornadas ? AppColors.naranja : Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, color: AppColors.blanco, size: 28),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalJornadas,
              itemBuilder: (context, index) {
                int jornada = index + 1;
                int? numPartidos = partidosPorJornada?[jornada];
                bool isCurrent = jornadaActual == jornada;

                return GestureDetector(
                  onTap: () => onJornadaChanged(jornada),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isCurrent ? AppColors.gradienteNaranjaAmarillo : null,
                      color: isCurrent ? null : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isCurrent ? Colors.transparent : AppColors.blancoOpacidad70,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$jornada',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : AppColors.blancoOpacidad70,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        if (numPartidos != null && numPartidos > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isCurrent ? Colors.white : AppColors.naranja,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
