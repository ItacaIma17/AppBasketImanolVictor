import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  String _periodoSeleccionado = 'Mensual';
  final List<String> _periodos = ['Diario', 'Semanal', 'Mensual', 'Anual'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas y Reportes',
            style: TextStyle(color: AppColors.blanco, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('Período:', style: TextStyle(color: AppColors.blanco)),
              const SizedBox(width: 12),
              ..._periodos.map((periodo) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(periodo),
                  selected: _periodoSeleccionado == periodo,
                  onSelected: (selected) {
                    if (selected) setState(() => _periodoSeleccionado = periodo);
                  },
                  backgroundColor: AppColors.blanco.withOpacity(0.1),
                  selectedColor: AppColors.naranja,
                  labelStyle: TextStyle(color: _periodoSeleccionado == periodo ? AppColors.blanco : AppColors.blancoOpacidad70),
                ),
              )),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: [
                _buildStatSection('USUARIOS', [
                  _buildStatRow('Total usuarios', '156', Colors.blue),
                  _buildStatRow('Nuevos usuarios', '23', Colors.green),
                  _buildStatRow('Usuarios activos', '142', Colors.orange),
                ]),
                const SizedBox(height: 16),
                _buildStatSection('PARTIDOS', [
                  _buildStatRow('Total partidos', '48', Colors.blue),
                  _buildStatRow('Partidos jugados', '32', Colors.green),
                  _buildStatRow('Partidos pendientes', '16', Colors.orange),
                ]),
                const SizedBox(height: 16),
                _buildStatSection('EQUIPOS', [
                  _buildStatRow('Total equipos', '24', Colors.blue),
                  _buildStatRow('Equipos con entrenador', '18', Colors.green),
                  _buildStatRow('Equipos sin entrenador', '6', Colors.orange),
                ]),
                const SizedBox(height: 16),
                _buildStatSection('LIGAS', [
                  _buildStatRow('Total ligas', '4', Colors.blue),
                  _buildStatRow('Ligas activas', '4', Colors.green),
                ]),
                const SizedBox(height: 16),
                _buildStatSection('ENTRENADORES', [
                  _buildStatRow('Total entrenadores', '12', Colors.blue),
                  _buildStatRow('Con equipo asignado', '8', Colors.green),
                  _buildStatRow('Sin equipo', '4', Colors.orange),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSection(String titulo, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.naranja),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
