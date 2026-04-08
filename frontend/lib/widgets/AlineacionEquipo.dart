import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

/// Widget reutilizable para mostrar la alineación de un equipo
/// Usado en: ConfirmarAlineaciones, PresentarAlineacion
class AlineacionEquipoWidget extends StatelessWidget {
  final Map<String, dynamic>? alineacion;
  final bool esLocal;
  final bool mostrarNumeroOrden;
  final bool soloLectura;

  const AlineacionEquipoWidget({
    super.key,
    required this.alineacion,
    required this.esLocal,
    this.mostrarNumeroOrden = true,
    this.soloLectura = true,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay alineación, mostrar mensaje
    if (alineacion == null) {
      return _buildAlineacionVacia();
    }

    final Color colorPrincipal = esLocal ? AppColors.naranja : AppColors.amarilloAragon;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorPrincipal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorPrincipal,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con nombre del equipo
          _buildHeaderEquipo(colorPrincipal),

          const SizedBox(height: 16),

          // Lista de jugadores
          ..._buildListaJugadores(colorPrincipal),

          // Total de jugadores
          const SizedBox(height: 12),
          _buildTotalJugadores(colorPrincipal),
        ],
      ),
    );
  }

  /// Widget cuando no hay alineación
  Widget _buildAlineacionVacia() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Center(
        child: Text(
          'Alineación no presentada',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Header con el nombre del equipo
  Widget _buildHeaderEquipo(Color color) {
    return Row(
      children: [
        Icon(
          Icons.shield,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            alineacion!['equipo'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Lista de jugadores
  List<Widget> _buildListaJugadores(Color color) {
    final jugadores = alineacion!['jugadores'] as List;

    return List.generate(
      jugadores.length,
      (index) {
        final jugador = jugadores[index];
        return _buildJugadorCard(jugador, index, color);
      },
    );
  }

  /// Card individual de jugador
  Widget _buildJugadorCard(
    Map<String, dynamic> jugador,
    int index,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Número de orden (opcional)
          if (mostrarNumeroOrden) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Dorsal
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.grisClaro,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${jugador['dorsal']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Nombre y posición
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jugador['nombre'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  jugador['posicion'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Footer con total de jugadores
  Widget _buildTotalJugadores(Color color) {
    final jugadores = alineacion!['jugadores'] as List;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups, size: 16),
          const SizedBox(width: 8),
          Text(
            '${jugadores.length} jugador${jugadores.length != 1 ? 'es' : ''}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}