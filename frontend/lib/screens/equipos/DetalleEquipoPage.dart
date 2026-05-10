import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import '../../models/equipo.dart';
import '../../models/jugador.dart';
import '../../models/partido.dart';
import '../../services/equipoService.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import '../JugadorDetallePage.dart';

class EquipoDetallePage extends StatefulWidget {
final Equipo? equipo;
  final int? equipoId;

 const EquipoDetallePage({
    super.key,
    this.equipo,
    this.equipoId,
  }) : assert(equipo != null || equipoId != null,
            'Debes pasar equipo o equipoId');

  @override
  State<EquipoDetallePage> createState() => _EquipoDetallePageState();
}

class _EquipoDetallePageState extends State<EquipoDetallePage> {
  Equipo? _equipo;
  List<Jugador> _jugadores = [];
  List<Partido> _partidos = [];
  bool _cargando = true;
  int _selectedTab = 0;
  String? _error;

  DateTime? _parseFecha(String fechaStr) {
    if (fechaStr.isEmpty) return null;
    try {
      final parts = fechaStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      print('Error parseando fecha: $fechaStr - $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _equipo = widget.equipo;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {

      if (_equipo == null) {
        _equipo = await EquipoService.obtenerEquipo(widget.equipoId!);
      }
      final jugadores = await EquipoService.getJugadoresEquipo(_equipo!.id!);
      final partidos = await PartidoService.getPartidosByEquipo(_equipo!.id!);
      setState(() {
        _jugadores = jugadores;
        _partidos = partidos;
        _cargando = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.blanco),
          ),
        ),
      );
    }

    if (_equipo == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
          child: const Center(
            child: Text(
              'Equipo no encontrado',
              style: TextStyle(color: AppColors.blanco, fontSize: 18),
            ),
          ),
        ),
      );
    }

    final esFavorito = FavoritosManager().esEquipoFavorito(_equipo!.id!);
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: HeaderApp(
        titulo: _equipo!.nombre,
        actions: [
          IconButton(
            icon: Icon(
              esFavorito ? Icons.star : Icons.star_border,
              color: esFavorito ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              setState(() {
                          FavoritosManager().toggleEquipoFavorito(_equipo!.id!);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              FavoritosManager().esEquipoFavorito(_equipo!.id!)
                                  ? 'Equipo añadido a favoritos'
                                  : 'Equipo eliminado de favoritos',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                body: Container(
                  decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildInfoEquipo(),
                        _buildTabs(),
                        Expanded(
                          child: _selectedTab == 0
                              ? _buildJugadoresList()
                              : _buildSeccionPartidos(),
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
                  _equipo!.nombre,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Liga: ${_equipo!.nombreLiga ?? "Sin liga"}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Estadio: ${_equipo!.nombreEstadio ?? "Sin estadio"}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Ciudad: ${_equipo!.ciudad ?? "Sin ciudad"}',
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
            border: Border.all(
                color: isSelected ? AppColors.naranja : Colors.white24),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : Colors.white70, size: 20),
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
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionJugadores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.naranja,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Jugadores',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_jugadores.length} jugadores',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_jugadores.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay jugadores en este equipo',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _jugadores.length,
            itemBuilder: (context, index) {
              final jugador = _jugadores[index];
              return _buildJugadorCard(jugador);
            },
          ),
      ],
    );
  }

Widget _buildJugadoresList() {
    if (_jugadores.isEmpty) {
      return const Center(
        child: Text('No hay jugadores en este equipo',
            style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jugadores.length,
      itemBuilder: (context, index) {
        return _buildJugadorCard(_jugadores[index]);
      },
    );
  }

   Widget _buildJugadorCard(Jugador jugador) {
    final esJugadorFavorito = FavoritosManager().esJugadorFavorito(jugador.id!);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JugadorDetallePage(
              jugador: jugador,
              equipoNombre: _equipo!.nombre,
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
                  style: const TextStyle(
                      color: AppColors.naranja, fontWeight: FontWeight.bold),
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
                      '${jugador.posicion} | ${jugador.altura}m | ${jugador.peso}kg',
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
                    FavoritosManager().toggleJugadorFavorito(jugador.id!);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionPartidos() {

    final proximosPartidos = _partidos
        .where((p) => p.estado != 'FINALIZADO')
        .toList()
      ..sort((a, b) {
        final fechaA = _parseFecha(a.fecha);
        final fechaB = _parseFecha(b.fecha);
        if (fechaA == null || fechaB == null) return 0;
        return fechaA.compareTo(fechaB);
      });

    final finalizados = _partidos
        .where((p) => p.estado == 'FINALIZADO')
        .toList()
      ..sort((a, b) {
        final fechaA = _parseFecha(a.fecha);
        final fechaB = _parseFecha(b.fecha);
        if (fechaA == null || fechaB == null) return 0;
        return fechaB.compareTo(fechaA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.naranja,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Próximos Partidos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (proximosPartidos.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay próximos partidos',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ...proximosPartidos.map((p) => _buildPartidoCard(p, esProximo: true)),

        const SizedBox(height: 24),

        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.naranja,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Partidos Finalizados',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (finalizados.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay partidos finalizados',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ...finalizados.map((p) => _buildPartidoCard(p, esProximo: false)),
      ],
    );
  }

  Widget _buildPartidoCard(Partido partido, {required bool esProximo}) {
    final esLocal = partido.equipoLocalId == widget.equipoId;
    final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;
    final resultado = esLocal
        ? '${partido.puntosLocal} - ${partido.puntosVisitante}'
        : '${partido.puntosVisitante} - ${partido.puntosLocal}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esProximo ? AppColors.naranja.withOpacity(0.3) : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'vs $rival',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: esProximo ? AppColors.naranja.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  esProximo ? 'PROGRAMADO' : 'FINALIZADO',
                  style: TextStyle(
                    color: esProximo ? AppColors.naranja : Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                '${partido.fecha} - ${partido.hora}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  partido.pabellon,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!esProximo) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Resultado: $resultado',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
