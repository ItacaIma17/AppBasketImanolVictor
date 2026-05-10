import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import 'package:tfg_appfede/models/equipo.dart';
import 'package:tfg_appfede/models/jugador.dart';
import 'package:tfg_appfede/models/partido.dart';
import 'package:tfg_appfede/screens/Jugadores.dart';

import 'package:tfg_appfede/services/PartidoService.dart';
import 'package:tfg_appfede/services/equipoService.dart';
import 'package:tfg_appfede/services/jugadorService.dart';
import 'package:tfg_appfede/widgets/tarjetas/TarjetaEntidad.dart';

class EquipoPage extends StatefulWidget {
  final int equipoId;

  const EquipoPage({
    super.key,
    required this.equipoId,
  });

  @override
  State<EquipoPage> createState() => _EquipoPageState();
}

class _EquipoPageState extends State<EquipoPage> {
  bool _esFavorito = false;
  Equipo? _equipo;
  List<Jugador> _jugadores = [];
  List<Partido> _partidos = [];
  int _victorias = 0;
  int _derrotas = 0;
  double _puntosAFavor = 0.0;
  double _puntosEnContra = 0.0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
  try {
    // Cargar equipo desde backend
    final equipo = await EquipoService.obtenerEquipo(widget.equipoId);

    // Cargar jugadores del equipo
    final jugadores = await JugadorService.listarJugadoresPorEquipo(widget.equipoId);

    // Cargar partidos del equipo
    final local = await PartidoService.obtenerPartidosPorEquipoLocal(widget.equipoId);
    final visitante = await PartidoService.obtenerPartidosPorEquipoVisitante(widget.equipoId);

    // Unificar sin duplicados
    final Set<Partido> partidosSet = {};
    partidosSet.addAll(local);
    partidosSet.addAll(visitante);
    final partidos = partidosSet.toList();

    // Calcular estadísticas
    int victorias = 0;
    int derrotas = 0;
    double totalPuntosAFavor = 0;
    double totalPuntosEnContra = 0;
    int partidosJugados = 0;

    for (final partido in partidos) {
      if (partido.estado == 'PROGRAMADO') continue;

      partidosJugados++;

      final esLocal = partido.equipoLocalId == widget.equipoId;

      if (esLocal) {
        totalPuntosAFavor += partido.puntosLocal;
        totalPuntosEnContra += partido.puntosVisitante;

        if (partido.puntosLocal > partido.puntosVisitante) victorias++;
        else derrotas++;
      } else {
        totalPuntosAFavor += partido.puntosVisitante;
        totalPuntosEnContra += partido.puntosLocal;

        if (partido.puntosVisitante > partido.puntosLocal) victorias++;
        else derrotas++;
      }
    }

    final divisor = partidosJugados > 0 ? partidosJugados : 1;
    final puntosAFavor = totalPuntosAFavor / divisor;
    final puntosEnContra = totalPuntosEnContra / divisor;

    // ============================
    // 5. Actualizar estado
    // ============================
    setState(() {
      _equipo = equipo;
      _jugadores = jugadores;
      _partidos = partidos;
      _victorias = victorias;
      _derrotas = derrotas;
      _puntosAFavor = puntosAFavor;
      _puntosEnContra = puntosEnContra;
      _cargando = false;
    });

    // ============================
    // 6. Favoritos
    // ============================
    if (equipo != null) {
      _esFavorito = FavoritosManager().esEquipoFavorito(equipo.nombre);
    }

  } catch (e) {
    print("Error cargando datos del equipo: $e");
    setState(() => _cargando = false);
  }
}


  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.gradienteAragon,
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.blanco),
          ),
        ),
      );
    }

    if (_equipo == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.gradienteAragon,
          ),
          child: const Center(
            child: Text(
              'Equipo no encontrado',
              style: TextStyle(color: AppColors.blanco, fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInfoEquipo(),
                      const SizedBox(height: 16),
                      _buildUltimosResultados(),
                      const SizedBox(height: 16),
                      _buildPlantilla(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.negro,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              _equipo?.nombre ?? 'Equipo',
              style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _esFavorito ? Icons.star : Icons.star_border,
              color: _esFavorito ? AppColors.amarilloAragon : AppColors.blanco,
              size: 28,
            ),
            onPressed: () {
              if (_equipo != null) {
                FavoritosManager().toggleEquipoFavorito(_equipo!.nombre);

                setState(() {
                  _esFavorito = FavoritosManager().esEquipoFavorito(_equipo!.nombre);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _esFavorito
                          ? 'Equipo añadido a favoritos'
                          : 'Equipo eliminado de favoritos',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// INFO DEL EQUIPO
  Widget _buildInfoEquipo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.gradienteNaranjaAmarillo,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, size: 60, color: AppColors.blanco),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Victorias', '$_victorias', Colors.green),
              _buildStatColumn('Derrotas', '$_derrotas', Colors.red),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Pts a favor', _puntosAFavor.toStringAsFixed(1), AppColors.naranja),
              _buildStatColumn('Pts en contra', _puntosEnContra.toStringAsFixed(1), AppColors.naranja),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  /// ÚLTIMOS RESULTADOS (mock)
  Widget _buildUltimosResultados() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Últimos Resultados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text("⚠ Próximamente conectado al backend"),
        ],
      ),
    );
  }

  /// PLANTILLA
  Widget _buildPlantilla() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plantilla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_jugadores.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay jugadores registrados'),
              ),
            )
          else
            ..._jugadores.map((j) => _buildJugadorCard(j)),
        ],
      ),
    );
  }

  Widget _buildJugadorCard(Jugador jugador) {
    return TarjetaEntidad(
      tipo: TipoEntidad.jugador,
      titulo: '${jugador.nombre} ${jugador.apellido}',
      subtitulo: _equipo?.nombre ?? '',
      chips: [
        TarjetaChip('${jugador.promedioPuntos ?? 0} PTS',
            icono: Icons.sports_basketball),
        TarjetaChip('${jugador.promedioRebotes ?? 0} REB',
            icono: Icons.swap_vert),
        TarjetaChip('${jugador.promedioAsistencias ?? 0} AST',
            icono: Icons.handshake),
      ],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JugadorPage(
              nombreJugador: '${jugador.nombre} ${jugador.apellido}',
              nombreEquipo: _equipo?.nombre ?? '',
            ),
          ),
        );
      },
    );
  }
}
