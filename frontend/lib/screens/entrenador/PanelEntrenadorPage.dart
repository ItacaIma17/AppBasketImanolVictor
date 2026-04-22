// lib/screens/Entrenador/PanelEntrenadorPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';

import '../../models/entrenadorEquipo.dart';
import '../../services/entrenadorService.dart';

class PanelEntrenadorPage extends StatefulWidget {
  const PanelEntrenadorPage({super.key});

  @override
  State<PanelEntrenadorPage> createState() => _PanelEntrenadorPageState();
}

class _PanelEntrenadorPageState extends State<PanelEntrenadorPage> {
  late Future<EntrenadorEquipo> _miEquipoFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    _miEquipoFuture = EntrenadorService.obtenerMiEquipo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Panel de Entrenador"),
      bottomNavigationBar: const BarraInferior(selectedIndex: 4),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: FutureBuilder<EntrenadorEquipo>(
            future: _miEquipoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.amarilloAragon),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildSinEquipo();
              }

              if (!snapshot.hasData) {
                return _buildSinEquipo();
              }

              final equipo = snapshot.data!;
              return _buildPanelConEquipo(equipo);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSinEquipo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_basketball, size: 80, color: AppColors.blancoOpacidad70),
          const SizedBox(height: 20),
          const Text(
            'Sin equipo asignado',
            style: TextStyle(color: AppColors.blanco, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Aún no tienes un equipo asignado.\nContacta con el administrador.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.naranja,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: () {
              _cargarDatos();
              setState(() {});
            },
            icon: const Icon(Icons.refresh, color: AppColors.blanco),
            label: const Text('Reintentar', style: TextStyle(color: AppColors.blanco)),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelConEquipo(EntrenadorEquipo equipo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderEquipo(equipo),
          const SizedBox(height: 20),
          _buildSeccion(
            titulo: 'Mi Información',
            icono: Icons.person,
            children: [
              _buildInfoRow(Icons.person, 'Nombre', equipo.nombreCompletoEntrenador),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.email, 'Email', equipo.email),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.alternate_email, 'Username', equipo.username),
            ],
          ),
          const SizedBox(height: 20),
          _buildSeccion(
            titulo: 'Información del Equipo',
            icono: Icons.sports_basketball,
            children: [
              _buildInfoRow(Icons.emoji_events, 'Liga', equipo.nombreLiga),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.stadium, 'Estadio', equipo.nombreEstadio),
            ],
          ),
          const SizedBox(height: 20),
          _buildSeccion(
            titulo: 'Acciones',
            icono: Icons.dashboard,
            children: [
              _buildAccionButton(
                icon: Icons.people,
                label: 'Gestionar Jugadores',
                color: Colors.blue,
                onTap: () {
                  // TODO: Navegar a gestión de jugadores
                },
              ),
              const SizedBox(height: 12),
              _buildAccionButton(
                icon: Icons.calendar_today,
                label: 'Calendario de Partidos',
                color: Colors.green,
                onTap: () {
                  // TODO: Navegar a calendario
                },
              ),
              const SizedBox(height: 12),
              _buildAccionButton(
                icon: Icons.bar_chart,
                label: 'Estadísticas del Equipo',
                color: Colors.orange,
                onTap: () {
                  // TODO: Navegar a estadísticas
                },
              ),
              const SizedBox(height: 12),
              _buildAccionButton(
                icon: Icons.message,
                label: 'Comunicados',
                color: Colors.purple,
                onTap: () {
                  // TODO: Navegar a comunicados
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderEquipo(EntrenadorEquipo equipo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradienteNaranjaAmarillo,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
        ],
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
            equipo.nombreEquipo,
            style: const TextStyle(color: AppColors.blanco, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            equipo.nombreLiga,
            style: const TextStyle(color: AppColors.blanco, fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion({required String titulo, required IconData icono, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: AppColors.naranja),
            const SizedBox(width: 8),
            Text(titulo, style: const TextStyle(color: AppColors.blanco, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.naranja, size: 20),
        const SizedBox(width: 12),
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildAccionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}