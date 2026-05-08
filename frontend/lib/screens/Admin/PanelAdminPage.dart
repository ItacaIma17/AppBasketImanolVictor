// lib/screens/Admin/PanelAdminPage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../services/EstadisticasService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'GestionPartidos.dart';

// Importar las páginas que existen
import 'GestionPartidosPage.dart' hide GestionPartidosPage;
import 'GestionUsuariosPage.dart';
import 'GestionEntrenadoresPage.dart';
import 'GestionEquiposPage.dart';
import 'GestionLigaPage.dart';

class PanelAdminPage extends StatefulWidget {
  const PanelAdminPage({super.key});

  @override
  State<PanelAdminPage> createState() => _PanelAdminPageState();
}

class _PanelAdminPageState extends State<PanelAdminPage> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _cargarEstadisticas(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _cargarEstadisticas({bool refresh = false}) async {
    if (!refresh) {
      setState(() => _isLoading = true);
    }

    try {
      final stats = await EstadisticasService.getEstadisticasGenerales();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Panel de Administración"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
            onRefresh: () => _cargarEstadisticas(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBotonCrearPartido(),
                  const SizedBox(height: 16),
                  _buildHeaderStats(),
                  const SizedBox(height: 16),
                  _buildMenuGestion(),
                  const SizedBox(height: 16),
                  _buildPartidosStats(),
                  const SizedBox(height: 16),
                  _buildUltimosPartidos(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonCrearPartido() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.gradienteNaranjaAmarillo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.naranja.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GestionPartidosPage(),
            ),
          );
        },
        icon: const Icon(Icons.add_circle_outline, size: 32),
        label: const Text(
          'Crear Nuevo Partido',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarEstadisticas,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Resumen General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('EN VIVO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem('Usuarios', _stats['totalUsuarios']?.toString() ?? '0', Icons.people, Colors.blue),
                _buildStatItem('Equipos', _stats['totalEquipos']?.toString() ?? '0', Icons.sports_basketball, Colors.green),
                _buildStatItem('Ligas', _stats['totalLigas']?.toString() ?? '0', Icons.emoji_events, Colors.orange),
                _buildStatItem('Partidos', _stats['totalPartidos']?.toString() ?? '0', Icons.calendar_today, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String titulo, String valor, IconData icono, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icono, size: 28, color: color),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuGestion() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GESTIÓN RÁPIDA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildMenuCard('Usuarios', Icons.people, Colors.blue, () => _navigateTo(const GestionUsuariosPage())),
                _buildMenuCard('Entrenadores', Icons.person_outline, Colors.orange, () => _navigateTo(const GestionEntrenadoresPage())),
                _buildMenuCard('Equipos', Icons.shield, Colors.teal, () => _navigateTo(const GestionEquiposPage())),
                _buildMenuCard('Ligas', Icons.emoji_events, Colors.red, () => _navigateTo(const GestionLigasPage())),
                _buildMenuCard('Partidos', Icons.calendar_today, Colors.indigo, () => _navigateTo(const GestionPartidosPage())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String titulo, IconData icono, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 36, color: color),
              const SizedBox(height: 8),
              Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartidosStats() {
    final partidosHoy = _stats['partidosHoy'] ?? 0;
    final partidosProgramados = _stats['partidosProgramados'] ?? 0;
    final partidosFinalizados = _stats['partidosFinalizados'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ESTADO DE PARTIDOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEstadoItem('HOY', partidosHoy.toString(), Colors.orange),
                _buildEstadoItem('PROGRAMADOS', partidosProgramados.toString(), Colors.blue),
                _buildEstadoItem('FINALIZADOS', partidosFinalizados.toString(), Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoItem(String label, String valor, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUltimosPartidos() {
    final ultimosPartidos = _stats['ultimosPartidos'] as List? ?? [];

    if (ultimosPartidos.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ÚLTIMOS PARTIDOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...ultimosPartidos.take(3).map((partido) => _buildUltimoPartidoItem(partido)),
          ],
        ),
      ),
    );
  }

  Widget _buildUltimoPartidoItem(dynamic partido) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.naranja.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.sports_basketball, color: AppColors.naranja),
      ),
      title: Text(
        '${partido['nombreLocal']} vs ${partido['nombreVisitante']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(partido['fecha'] ?? 'Fecha por confirmar'),
      trailing: Chip(
        label: Text(partido['estado'] ?? 'PROGRAMADO'),
        backgroundColor: partido['estado'] == 'FINALIZADO' ? Colors.green : Colors.orange,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        _navigateTo(const GestionPartidosPage());
      },
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}