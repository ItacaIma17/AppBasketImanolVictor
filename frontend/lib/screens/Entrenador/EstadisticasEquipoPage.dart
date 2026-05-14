import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/EquipoEntrenador.dart';
import '../../models/jugador.dart';
import '../../models/partido.dart';
import '../../services/entrenadorService.dart';
import '../../services/equipoService.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import '../JugadorDetallePage.dart';

class EstadisticasEquipoPage extends StatefulWidget {
  const EstadisticasEquipoPage({super.key});

  @override
  State<EstadisticasEquipoPage> createState() => _EstadisticasEquipoPageState();
}

class _EstadisticasEquipoPageState extends State<EstadisticasEquipoPage> {
  EquipoEntrenador? _miEquipo;
  List<Jugador> _jugadores = [];
  List<Partido> _partidos = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final equipoData = await EntrenadorService.obtenerMiEquipo();
      final equipo = EquipoEntrenador.fromJson(equipoData);

      if (equipo.tieneEquipo) {
        final jugadores = await EquipoService.getJugadoresEquipo(equipo.equipoId);
        final partidos = await PartidoService.getPartidosByEquipo(equipo.equipoId);

        setState(() {
          _miEquipo = equipo;
          _jugadores = jugadores;
          _partidos = partidos;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => _isLoading = false);
    }
  }

  int get partidosJugados => _partidos.where((p) => p.estado == 'FINALIZADO').length;

  int get partidosGanados {
    return _partidos.where((p) {
      if (p.estado != 'FINALIZADO') return false;
      final esLocal = p.nombreLocal == _miEquipo?.nombreEquipo;
      if (esLocal) {
        return (p.puntosLocal ?? 0) > (p.puntosVisitante ?? 0);
      } else {
        return (p.puntosVisitante ?? 0) > (p.puntosLocal ?? 0);
      }
    }).length;
  }

  int get partidosPerdidos => partidosJugados - partidosGanados;

  double get porcentajeVictorias => partidosJugados > 0
      ? (partidosGanados / partidosJugados) * 100
      : 0;

  List<Jugador> get topAnotadores {
    final copia = List<Jugador>.from(_jugadores);
    copia.sort((a, b) => b.promedioPuntos.compareTo(a.promedioPuntos));
    return copia.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Estadísticas del Equipo"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
          : _miEquipo == null
              ? _buildSinEquipo()
              : Column(
                  children: [
                    _buildHeader(),
                    _buildTabs(),
                    Expanded(
                      child: _selectedTab == 0
                          ? _buildEstadisticasGenerales()
                          : _selectedTab == 1
                              ? _buildRankingJugadores()
                              : _buildPartidosEstadisticas(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSinEquipo() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_basketball, size: 80, color: AppColors.grisClaro),
          SizedBox(height: 16),
          Text('No tienes un equipo asignado', style: TextStyle(color: AppColors.grisClaro)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradienteEntrenador,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _miEquipo!.nombreEquipo,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                color: AppColors.blanco),
          ),
          const SizedBox(height: 8),
          Text(
            _miEquipo!.nombreLiga ?? 'Liga no especificada',
            style: const TextStyle(color: AppColors.blancoOpacidad70),
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
          _buildTab('General', 0, Icons.assessment),
          const SizedBox(width: 8),
          _buildTab('Jugadores', 1, Icons.people),
          const SizedBox(width: 8),
          _buildTab('Partidos', 2, Icons.calendar_today),
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
              Icon(icon, color: isSelected ? AppColors.negro : AppColors.grisClaro, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.negro : AppColors.grisClaro,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticasGenerales() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.superficie1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                const Text('Rendimiento General',
                    style: TextStyle(color: AppColors.blanco, fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEstadisticaItem('PJ', partidosJugados.toString(), AppColors.naranja),
                    _buildEstadisticaItem('PG', partidosGanados.toString(), AppColors.amarilloAragon),
                    _buildEstadisticaItem('PP', partidosPerdidos.toString(), AppColors.rojoAragon),
                    _buildEstadisticaItem('%', '${porcentajeVictorias.toStringAsFixed(1)}%', AppColors.naranja),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.superficie1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                const Text('Promedios del Equipo',
                    style: TextStyle(color: AppColors.blanco, fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildPromedioItem('Puntos por partido', _calcularPromedioPuntosEquipo().toStringAsFixed(1)),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildPromedioItem('Rebotes por partido', _calcularPromedioRebotesEquipo().toStringAsFixed(1)),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildPromedioItem('Asistencias por partido', _calcularPromedioAsistenciasEquipo().toStringAsFixed(1)),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildPromedioItem('Robos por partido', _calcularPromedioRobosEquipo().toStringAsFixed(1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grisClaro)),
      ],
    );
  }

  Widget _buildPromedioItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: AppColors.blanco)),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
            color: AppColors.naranja)),
      ],
    );
  }

  double _calcularPromedioPuntosEquipo() {
    if (_jugadores.isEmpty) return 0;
    double total = 0;
    for (var j in _jugadores) {
      total += j.promedioPuntos;
    }
    return total / _jugadores.length;
  }

  double _calcularPromedioRebotesEquipo() {
    if (_jugadores.isEmpty) return 0;
    double total = 0;
    for (var j in _jugadores) {
      total += j.promedioRebotes;
    }
    return total / _jugadores.length;
  }

  double _calcularPromedioAsistenciasEquipo() {
    if (_jugadores.isEmpty) return 0;
    double total = 0;
    for (var j in _jugadores) {
      total += j.promedioAsistencias;
    }
    return total / _jugadores.length;
  }

  double _calcularPromedioRobosEquipo() {
    if (_jugadores.isEmpty) return 0;
    double total = 0;
    for (var j in _jugadores) {
      total += j.promedioRobos;
    }
    return total / _jugadores.length;
  }

  Widget _buildRankingJugadores() {
    if (_jugadores.isEmpty) {
      return const Center(
        child: Text('No hay jugadores en el equipo',
            style: TextStyle(color: AppColors.grisClaro)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topAnotadores.length,
      itemBuilder: (context, index) {
        final jugador = topAnotadores[index];
        return _buildJugadorRankingCard(jugador, index + 1);
      },
    );
  }

  Widget _buildJugadorRankingCard(Jugador jugador, int posicion) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JugadorDetallePage(
              jugador: jugador,
              equipoNombre: _miEquipo!.nombreEquipo,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.superficie1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: posicion <= 3 ? AppColors.naranja.withOpacity(0.15)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('$posicion',
                    style: TextStyle(
                      color: posicion <= 3 ? AppColors.naranja : AppColors.grisClaro,
                      fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jugador.nombreCompleto,
                      style: const TextStyle(color: AppColors.blanco,
                          fontWeight: FontWeight.bold)),
                  Text(jugador.posicion,
                      style: const TextStyle(fontSize: 12, color: AppColors.grisClaro)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${jugador.promedioPuntos.toStringAsFixed(1)} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        color: AppColors.naranja)),
                Text('${jugador.promedioRebotes.toStringAsFixed(1)} reb',
                    style: const TextStyle(fontSize: 12, color: AppColors.grisClaro)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartidosEstadisticas() {
    final partidosFinalizados = _partidos.where((p) => p.estado == 'FINALIZADO').toList();

    if (partidosFinalizados.isEmpty) {
      return const Center(
        child: Text('No hay partidos finalizados',
            style: TextStyle(color: AppColors.grisClaro)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: partidosFinalizados.length,
      itemBuilder: (context, index) {
        final partido = partidosFinalizados[index];
        final esLocal = partido.nombreLocal == _miEquipo!.nombreEquipo;
        final puntosFavor = esLocal ? partido.puntosLocal : partido.puntosVisitante;
        final puntosContra = esLocal ? partido.puntosVisitante : partido.puntosLocal;
        final esVictoria = (puntosFavor ?? 0) > (puntosContra ?? 0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.superficie1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${partido.nombreLocal} vs ${partido.nombreVisitante}',
                      style: const TextStyle(color: AppColors.blanco,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (esVictoria ? AppColors.naranja : AppColors.rojoAragon)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (esVictoria ? AppColors.naranja : AppColors.rojoAragon)
                            .withOpacity(0.4)),
                    ),
                    child: Text(
                      esVictoria ? 'Victoria' : 'Derrota',
                      style: TextStyle(
                          color: esVictoria ? AppColors.naranja : AppColors.rojoAragon,
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${puntosFavor ?? 0}',
                      style: const TextStyle(color: AppColors.blanco,
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  const Text('-',
                      style: TextStyle(color: AppColors.grisClaro, fontSize: 24)),
                  const SizedBox(width: 16),
                  Text('${puntosContra ?? 0}',
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 24)),
                ],
              ),
              const SizedBox(height: 8),
              Text(_formatearFechaSegura(partido.fecha),
                  style: const TextStyle(fontSize: 12, color: AppColors.grisClaro)),
            ],
          ),
        );
      },
    );
  }

  String _formatearFechaSegura(String fechaStr) {
    if (fechaStr.isEmpty) return '';

    final dt = Partido.parseFecha(fechaStr);
    if (dt == null) return fechaStr;
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
  }
}
