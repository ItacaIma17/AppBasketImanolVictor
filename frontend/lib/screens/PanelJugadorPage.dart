// lib/screens/Jugador/PanelJugadorPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/jugador.dart';
import '../../models/equipo.dart';
import '../../services/autenticacion_service.dart';
import '../../services/equipoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'equipos/DetalleEquipoPage.dart';

class PanelJugadorPage extends StatefulWidget {
  const PanelJugadorPage({super.key});

  @override
  State<PanelJugadorPage> createState() => _PanelJugadorPageState();
}

class _PanelJugadorPageState extends State<PanelJugadorPage> {
  Jugador? _jugador;
  Equipo? _equipo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final jugador = AutenticacionService.jugadorActual;
      if (jugador != null && jugador.equipoId != null) {
        final equipo = await EquipoService.obtenerEquipo(jugador.equipoId!);
        setState(() {
          _jugador = jugador;
          _equipo = equipo;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Mi Perfil"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _jugador == null
              ? _buildSinPerfil()
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPerfilJugador(),
                const SizedBox(height: 16),
                if (_equipo != null) _buildInfoEquipo(),
                const SizedBox(height: 16),
                _buildEstadisticas(),
                const SizedBox(height: 16),
                _buildMenuAcciones(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSinPerfil() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.white54),
          SizedBox(height: 16),
          Text('No hay información de perfil disponible', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildPerfilJugador() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradienteNaranjaAmarillo,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  _jugador!.iniciales,
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _jugador!.nombreCompleto,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(_jugador!.posicion),
                backgroundColor: Colors.white.withOpacity(0.3),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem('Dorsal', _jugador!.dorsal.toString()),
                  _buildInfoItem('Altura', '${_jugador!.altura}m'),
                  _buildInfoItem('Peso', '${_jugador!.peso}kg'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildInfoEquipo() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EquipoDetallePage(equipo: _equipo!)),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.sports_basketball, size: 40, color: AppColors.naranja),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_equipo!.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(_equipo!.nombreLiga ?? "Sin liga", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticas() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mis Estadísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildEstadisticaItem('Puntos', _jugador!.promedioPuntos.toString()),
                _buildEstadisticaItem('Rebotes', _jugador!.promedioRebotes.toString()),
                _buildEstadisticaItem('Asistencias', _jugador!.promedioAsistencias.toString()),
                _buildEstadisticaItem('Robos', _jugador!.promedioRobos.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.naranja)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuAcciones() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Acciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.people, color: AppColors.naranja),
              title: const Text('Ver mi equipo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (_equipo != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EquipoDetallePage(equipo: _equipo!)),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppColors.naranja),
              title: const Text('Mis partidos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}