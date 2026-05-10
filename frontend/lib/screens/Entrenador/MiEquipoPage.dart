import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/EquipoEntrenador.dart';
import '../../models/jugador.dart';
import '../../models/partido.dart';
import '../../services/entrenadorService.dart';
import '../../services/equipoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class MiEquipoPage extends StatefulWidget {
  const MiEquipoPage({super.key});

  @override
  State<MiEquipoPage> createState() => _MiEquipoPageState();
}

class _MiEquipoPageState extends State<MiEquipoPage> {
  bool _isLoading = true;
  EquipoEntrenador? _miEquipo;
  List<Jugador> _jugadores = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {

      final equipoData = await EntrenadorService.obtenerMiEquipo();
      final equipo = EquipoEntrenador.fromJson(equipoData);

      if (equipo.tieneEquipo) {

        final jugadores = await EquipoService.getJugadoresEquipo(equipo.equipoId);
        setState(() {
          _miEquipo = equipo;
          _jugadores = jugadores;
          _isLoading = false;
        });
        print(' Cargados ${jugadores.length} jugadores para ${equipo.nombreEquipo}');
      } else {
        setState(() {
          _error = "No tienes un equipo asignado";
          _isLoading = false;
        });
      }
    } catch (e) {
      print(' Error cargando datos: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gradienteAragon.colors.last,
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Mi Equipo"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : _miEquipo == null
              ? _buildSinEquipoWidget()
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarDatos,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSinEquipoWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'No tienes un equipo asignado',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEquipoInfo(),
            const SizedBox(height: 16),
            _buildJugadoresList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipoInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, size: 50, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                _miEquipo!.nombreEquipo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_miEquipo!.nombreLiga != null)
                Text(
                  _miEquipo!.nombreLiga!,
                  style: const TextStyle(color: Colors.white70),
                ),
              if (_miEquipo!.nombreEstadio != null)
                Text(
                  _miEquipo!.nombreEstadio!,
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Entrenador: ${_miEquipo!.nombreCompletoEntrenador}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJugadoresList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jugadores del Equipo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_jugadores.length} jugadores',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_jugadores.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No hay jugadores en este equipo'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _jugadores.length,
                itemBuilder: (context, index) {
                  final jugador = _jugadores[index];
                  return _buildJugadorItem(jugador);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJugadorItem(Jugador jugador) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.naranja.withOpacity(0.2),
        child: Text(
          jugador.dorsal?.toString() ?? '?',
          style: const TextStyle(color: AppColors.naranja, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(jugador.nombreCompleto),
      subtitle: Text(jugador.posicion),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Altura: ${jugador.altura}m',
          style: const TextStyle(fontSize: 12, color: Colors.blue),
        ),
      ),
    );
  }
}
