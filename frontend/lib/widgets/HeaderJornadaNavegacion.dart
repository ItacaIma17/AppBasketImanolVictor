import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

class HeaderJornadaNavegacion extends StatelessWidget {
  final int jornadaActual;
  final int totalJornadas;
  final Function(int) onJornadaChanged;
  final String? titulo;
  final bool mostrarBotonAtras;
  final VoidCallback? onBack;

  const HeaderJornadaNavegacion({
    super.key,
    required this.jornadaActual,
    required this.totalJornadas,
    required this.onJornadaChanged,
    this.titulo,
    this.mostrarBotonAtras = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.negro,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [

          if (titulo != null)
            Row(
              children: [
                if (mostrarBotonAtras)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
                    onPressed: onBack ?? () => Navigator.pop(context),
                  ),
                Expanded(
                  child: Text(
                    titulo!,
                    style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

          if (titulo != null) const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.blanco,
                  size: 32,
                ),
                onPressed: jornadaActual > 1
                    ? () => onJornadaChanged(jornadaActual - 1)
                    : null,
              ),

              const SizedBox(width: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.gradienteNaranjaAmarillo,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.naranja.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$jornadaActual',
                      style: const TextStyle(
                        color: AppColors.blanco,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.blanco,
                  size: 32,
                ),
                onPressed: jornadaActual < totalJornadas
                    ? () => onJornadaChanged(jornadaActual + 1)
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'de $totalJornadas jornadas',
            style: TextStyle(
              color: AppColors.blancoOpacidad70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
