import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

class PartidoArbitroCard extends StatelessWidget {
  final Map<String, dynamic> partido;
  final VoidCallback onRevisar;

  const PartidoArbitroCard({
    super.key,
    required this.partido,
    required this.onRevisar,
  });

  @override
  Widget build(BuildContext context) {
    final bool confirmadas = partido['alineacionesConfirmadas'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildHeader(confirmadas),

          _buildBotonRevisar(confirmadas),
        ],
      ),
    );
  }

  Widget _buildHeader(bool confirmadas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: confirmadas
            ? const LinearGradient(colors: [Colors.green, Colors.teal])
            : AppColors.gradienteRojoNaranja,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            confirmadas ? Icons.check_circle : Icons.pending,
            color: AppColors.blanco,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${partido['equipoLocal']} vs ${partido['equipoVisitante']}',
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${partido['categoria']} • ${partido['fecha']} ${partido['hora']}',
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildBadgeEstado(confirmadas),
        ],
      ),
    );
  }

  Widget _buildBadgeEstado(bool confirmadas) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: confirmadas ? Colors.white : AppColors.blanco.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        confirmadas ? 'CONFIRMADAS' : 'PENDIENTE',
        style: TextStyle(
          color: confirmadas ? Colors.green : AppColors.blanco,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBotonRevisar(bool confirmadas) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmadas ? Colors.grey : AppColors.naranja,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: confirmadas ? null : onRevisar,
          icon: Icon(
            confirmadas ? Icons.visibility : Icons.edit_note,
            color: AppColors.blanco,
          ),
          label: Text(
            confirmadas ? 'Alineaciones Confirmadas' : 'Revisar Alineaciones',
            style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
