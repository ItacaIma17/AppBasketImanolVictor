import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/widgets/AlineacionEquipo.dart';

class MostrarRevisionAlineaciones extends StatelessWidget {
  final Map<String, dynamic> partido;
  final Map<String, dynamic>? alineacionLocal;
  final Map<String, dynamic>? alineacionVisitante;
  final VoidCallback onConfirmar;

  const MostrarRevisionAlineaciones({
    super.key,
    required this.partido,
    required this.alineacionLocal,
    required this.alineacionVisitante,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [

          _buildHeader(context),

          Expanded(
            child: _buildContenido(),
          ),

          _buildBotonConfirmar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppColors.gradienteAragon,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Alineaciones del Partido',
                  style: TextStyle(
                    color: AppColors.blanco,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.blanco),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${partido['equipoLocal']} vs ${partido['equipoVisitante']}',
            style: TextStyle(
              color: AppColors.blancoOpacidad70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          AlineacionEquipoWidget(
            alineacion: alineacionLocal,
            esLocal: true,
          ),

          const SizedBox(height: 20),

          _buildSeparadorVS(),

          const SizedBox(height: 20),

          AlineacionEquipoWidget(
            alineacion: alineacionVisitante,
            esLocal: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSeparadorVS() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisClaro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'VS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBotonConfirmar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {

            if (alineacionLocal == null || alineacionVisitante == null) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ambos equipos deben presentar sus alineaciones'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            _mostrarDialogoConfirmacion(context);
          },
          icon: const Icon(Icons.check_circle, color: AppColors.blanco),
          label: const Text(
            'Confirmar Alineaciones',
            style: TextStyle(
              color: AppColors.blanco,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Alineaciones'),
        content: const Text(
          '¿Estás seguro de confirmar las alineaciones?\n\n'
          'Una vez confirmadas, los entrenadores no podrán modificarlas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              onConfirmar();
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: AppColors.blanco),
            ),
          ),
        ],
      ),
    );
  }

  static void mostrar({
    required BuildContext context,
    required Map<String, dynamic> partido,
    required Map<String, dynamic>? alineacionLocal,
    required Map<String, dynamic>? alineacionVisitante,
    required VoidCallback onConfirmar,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MostrarRevisionAlineaciones(
        partido: partido,
        alineacionLocal: alineacionLocal,
        alineacionVisitante: alineacionVisitante,
        onConfirmar: onConfirmar,
      ),
    );
  }
}
