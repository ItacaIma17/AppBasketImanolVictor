// lib/screens/EquipoDetallePage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../data/gestorFavoritos.dart';
import '../../models/equipo.dart';
import '../../models/jugador.dart';
import '../../models/partido.dart';
import '../../services/equipoService.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import '../JugadorDetallePage.dart';


class EquipoDetallePage extends StatefulWidget {
  final Equipo equipo;

  const EquipoDetallePage({super.key, required this.equipo});

  @override
  State<EquipoDetallePage> createState() => _EquipoDetallePageState();
}

class _EquipoDetallePageState extends State<EquipoDetallePage> {
  List<Jugador> _jugadores = [];
  List<Partido> _partidos = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ✅ CORRECCIÓN 1: Cargar datos por separado (recomendado)
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      // Cargar jugadores y partidos por separado
      final jugadores = await EquipoService.getJugadoresEquipo(widget.equipo.id!);
      final partidos = await PartidoService.getPartidosByEquipo(widget.equipo.id!);

      setState(() {
        _jugadores = jugadores;
        _partidos = partidos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => _isLoading = false);
    }
  }

  // ✅ CORRECCIÓN 2: Usar Future.wait con casting explícito (alternativa)
  Future<void> _cargarDatosAlternativo() async {
    setState(() => _isLoading = true);

    try {
      final resultados = await Future.wait([
        EquipoService.getJugadoresEquipo(widget.equipo.id!),
        PartidoService.getPartidosByEquipo(widget.equipo.id!),
      ]);

      // ✅ CASTING EXPLÍCITO
      final List<Jugador> jugadores = resultados[0] as List<Jugador>;
      final List<Partido> partidos = resultados[1] as List<Partido>;

      setState(() {
        _jugadores = jugadores;
        _partidos = partidos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esFavorito = FavoritosManager().esEquipoFavorito(widget.equipo.nombre);

    return Scaffold(
      drawer: const MenuLateral(),
      appBar: HeaderApp(
        titulo: widget.equipo.nombre,
        actions: [
          IconButton(
            icon: Icon(
              esFavorito ? Icons.star : Icons.star_border,
              color: esFavorito ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              setState(() {
                FavoritosManager().toggleEquipoFavorito(widget.equipo.nombre);
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              _buildInfoEquipo(),
              _buildTabs(),
              Expanded(
                child: _selectedTab == 0
                    ? _buildJugadoresList()
                    : _buildPartidosList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoEquipo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradienteNaranjaAmarillo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_basketball, size: 50, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.equipo.nombre,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Liga: ${widget.equipo.nombreLiga ?? "Sin liga"}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Estadio: ${widget.equipo.nombreEstadio}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Ciudad: ${widget.equipo.ciudad}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTab('Jugadores', 0, Icons.people),
          const SizedBox(width: 8),
          _buildTab('Partidos', 1, Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.naranja : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.naranja : Colors.white24),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJugadoresList() {
    if (_jugadores.isEmpty) {
      return const Center(
        child: Text('No hay jugadores en este equipo', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jugadores.length,
      itemBuilder: (context, index) {
        final jugador = _jugadores[index];
        return _buildJugadorCard(jugador);
      },
    );
  }

  Widget _buildJugadorCard(Jugador jugador) {
    final esJugadorFavorito = FavoritosManager().esJugadorFavorito(jugador.nombreCompleto);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JugadorDetallePage(
              jugador: jugador,
              equipoNombre: widget.equipo.nombre,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.naranja.withOpacity(0.2),
                child: Text(
                  jugador.dorsal.toString(),
                  style: const TextStyle(color: AppColors.naranja, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jugador.nombreCompleto,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${jugador.posicion} | Altura: ${jugador.altura}m | Peso: ${jugador.peso}kg',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  esJugadorFavorito ? Icons.star : Icons.star_border,
                  color: esJugadorFavorito ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (esJugadorFavorito) {
                      FavoritosManager().eliminarJugadorFavorito(jugador.nombreCompleto);
                    } else {
                      FavoritosManager().agregarJugadorFavorito(jugador.nombreCompleto);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartidosList() {
    if (_partidos.isEmpty) {
      return const Center(
        child: Text('No hay partidos programados', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _partidos.length,
      itemBuilder: (context, index) {
        final partido = _partidos[index];
        final esLocal = partido.nombreLocal == widget.equipo.nombre;
        final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;
        final resultado = partido.puntosLocal != null
            ? '${partido.puntosLocal} - ${partido.puntosLocal}'
            : 'vs $rival';

        return Card(
          child: ListTile(
            leading: const Icon(Icons.sports_basketball, color: AppColors.naranja),
            title: Text(resultado),
            subtitle: Text(
              '${DateTime.parse(partido.fecha).day}/${DateTime.parse(partido.fecha).month}/${DateTime.parse(partido.fecha).year} - ${partido.direccionPabellon ?? "Sin ubicación"}',
            ),
            trailing: partido.estado == 'FINALIZADO'
                ? const Chip(label: Text('Finalizado'), backgroundColor: Colors.green)
                : const Chip(label: Text('Programado'), backgroundColor: Colors.orange),
          ),
        );
      },
    );
  }
}