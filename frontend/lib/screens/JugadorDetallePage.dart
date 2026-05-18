import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../models/jugador.dart';
import '../data/gestorFavoritos.dart';
import '../widgets/MenuLateral.dart';

class JugadorDetallePage extends StatefulWidget {
  final Jugador jugador;
  final String? equipoNombre;

  const JugadorDetallePage({super.key, required this.jugador, this.equipoNombre});

  @override
  State<JugadorDetallePage> createState() => _JugadorDetallePageState();
}

class _JugadorDetallePageState extends State<JugadorDetallePage> {
  bool _esFavorito = false;
  bool _cargandoFavorito = true;

  static const _acento = AppColors.naranja;

  @override
  void initState() {
    super.initState();
    _verificarFavorito();
  }

  Future<void> _verificarFavorito() async {
    try {
      await FavoritosManager().cargarFavoritos();
      final esFav = FavoritosManager().esJugadorFavorito(widget.jugador.id!);
      if (mounted) setState(() { _esFavorito = esFav; _cargandoFavorito = false; });
    } catch (_) {
      if (mounted) setState(() => _cargandoFavorito = false);
    }
  }

  Future<void> _toggleFavorito() async {
    if (widget.jugador.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID inválido'), backgroundColor: AppColors.rojoAragon));
      return;
    }
    setState(() {
      FavoritosManager().toggleJugadorFavorito(widget.jugador.id!);
      _esFavorito = FavoritosManager().esJugadorFavorito(widget.jugador.id!);
      _cargandoFavorito = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_esFavorito ? 'Añadido a favoritos' : 'Eliminado de favoritos'),
        backgroundColor: _esFavorito ? AppColors.naranja : AppColors.superficie1,
        duration: const Duration(seconds: 1),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.jugador;
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(j),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildEstadisticas(j),
                const SizedBox(height: 16),
                _buildDatosFisicos(j),
                if ((widget.equipoNombre ?? j.nombreEquipo) != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoEquipo(widget.equipoNombre ?? j.nombreEquipo!),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(Jugador j) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.rojoAragon,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
      actions: [
        if (j.id != null)
          _cargandoFavorito
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanco)))
              : IconButton(
                  icon: Icon(
                    _esFavorito ? Icons.star : Icons.star_border,
                    color: _esFavorito ? AppColors.amarilloAragon : AppColors.blanco,
                  ),
                  onPressed: _toggleFavorito,
                ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradienteJugador),
          child: SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 48),
              Stack(alignment: Alignment.bottomRight, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2.5),
                  ),
                  child: Center(
                    child: Text(j.iniciales,
                        style: const TextStyle(color: AppColors.blanco, fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.amarilloAragon,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.negro, width: 2),
                  ),
                  child: Center(
                    child: Text('#${j.dorsal}',
                        style: const TextStyle(color: AppColors.negro, fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Text(j.nombreCompleto,
                  style: const TextStyle(color: AppColors.blanco, fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('JUGADOR', style: TextStyle(color: AppColors.blanco, fontSize: 11,
                      letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  const Text('·', style: TextStyle(color: AppColors.blancoOpacidad70)),
                  const SizedBox(width: 6),
                  Text(j.posicion.toUpperCase(),
                      style: const TextStyle(color: AppColors.blanco, fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
        ),
        title: Text(j.nombreCompleto,
            style: const TextStyle(color: AppColors.blanco, fontSize: 16,
                fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildEstadisticas(Jugador j) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.bar_chart, color: _acento, size: 18),
          SizedBox(width: 8),
          Text('Estadísticas de la Temporada',
              style: TextStyle(color: AppColors.blanco, fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _buildStat(j.promedioPuntos.toStringAsFixed(1), 'PTS', AppColors.rojoAragon),
          _buildSep(),
          _buildStat(j.promedioRebotes.toStringAsFixed(1), 'REB', _acento),
          _buildSep(),
          _buildStat(j.promedioAsistencias.toStringAsFixed(1), 'AST', AppColors.amarilloAragon),
          _buildSep(),
          _buildStat(j.promedioRobos.toStringAsFixed(1), 'ROB', AppColors.rojoAragon),
        ]),
        const SizedBox(height: 12),
        Divider(color: Colors.white.withOpacity(0.08)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildInfoSmall('Partidos Jugados', j.partidosJugados.toString()),
          _buildInfoSmall('Puntos Totales', j.puntosTotales.toString()),
        ]),
      ]),
    );
  }

  Widget _buildStat(String valor, String label, Color color) {
    return Expanded(
      child: Column(children: [
        Text(valor, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.grisClaro, fontSize: 10,
            letterSpacing: 0.5)),
      ]),
    );
  }

  Widget _buildSep() =>
      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.1));

  Widget _buildInfoSmall(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
          color: _acento)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grisClaro),
          overflow: TextOverflow.ellipsis, maxLines: 1),
    ]);
  }

  Widget _buildDatosFisicos(Jugador j) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.straighten, color: _acento, size: 17),
          SizedBox(width: 8),
          Text('Datos Físicos', style: TextStyle(color: AppColors.blanco,
              fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _buildDatoFisico('Dorsal', '#${j.dorsal}'),
          _buildDatoFisico('Altura', j.alturaFormateada),
          _buildDatoFisico('Peso', j.pesoFormateado),
          _buildDatoFisico('Posición', j.posicion),
        ]),
      ]),
    );
  }

  Widget _buildDatoFisico(String label, String valor) {
    return Expanded(
      child: Column(children: [
        Text(valor, style: const TextStyle(color: AppColors.blanco, fontSize: 15,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.grisClaro, fontSize: 10)),
      ]),
    );
  }

  Widget _buildInfoEquipo(String equipo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _acento.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _acento.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.gradienteJugador,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.sports_basketball, color: AppColors.blanco, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Equipo Actual',
              style: TextStyle(color: AppColors.grisClaro, fontSize: 11)),
          const SizedBox(height: 2),
          Text(equipo, style: const TextStyle(color: AppColors.blanco,
              fontSize: 16, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }
}