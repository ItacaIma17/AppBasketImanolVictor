// lib/screens/Equipos/DetalleEquipoPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

import '../../models/equipo.dart';

class DetalleEquipoPage extends StatelessWidget {
  final Equipo equipo;

  const DetalleEquipoPage({super.key, required this.equipo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(equipo.nombre),
        backgroundColor: AppColors.naranja,
        foregroundColor: AppColors.blanco,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildInfoCard(),
                const SizedBox(height: 20),
                _buildEstadisticasCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradienteNaranjaAmarillo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.blanco.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.sports_basketball, size: 50, color: AppColors.blanco),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            equipo.nombre,
            style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            equipo.nombreLiga ?? 'Sin liga',
            style: const TextStyle(color: AppColors.blanco, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: AppColors.naranja),
                SizedBox(width: 8),
                Text('Información', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            _buildInfoRow(Icons.stadium, 'Estadio', equipo.nombreEstadio),
            _buildInfoRow(Icons.location_city, 'Ciudad', equipo.ciudad),
            _buildInfoRow(Icons.calendar_today, 'Fundación', '${equipo.anoFundacion}'),
            _buildInfoRow(Icons.person, 'Entrenador', equipo.nombreEntrenador ?? 'Sin asignar'),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.naranja),
                SizedBox(width: 8),
                Text('Estadísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            _buildInfoRow(Icons.people, 'Jugadores', '${equipo.numeroJugadores}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.naranja),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}