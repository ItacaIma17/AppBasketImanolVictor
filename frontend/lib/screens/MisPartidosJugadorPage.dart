import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../models/partido.dart';
import '../services/partidoService.dart';
import '../widgets/MenuLateral.dart';

class MisPartidosJugadorPage extends StatefulWidget {
  const MisPartidosJugadorPage({super.key});

  @override
  State<MisPartidosJugadorPage> createState() => _MisPartidosJugadorPageState();
}

class _MisPartidosJugadorPageState extends State<MisPartidosJugadorPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String _filtro = 'PROXIMOS';
  String? _error;

  static const _acento = AppColors.naranja;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    setState(() => _isLoading = true);
    try {
      final partidos = await PartidoService.getPartidosByJugador();
      setState(() { _partidos = partidos; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Partido> get _partidosFiltrados {
    final now = DateTime.now();
    switch (_filtro) {
      case 'PROXIMOS':
        return _partidos
            .where((p) => DateTime.parse(p.fecha).isAfter(now) && p.estado != 'FINALIZADO')
            .toList()
          ..sort((a, b) => DateTime.parse(a.fecha).compareTo(DateTime.parse(b.fecha)));
      case 'FINALIZADOS':
        return _partidos
            .where((p) => p.estado == 'FINALIZADO')
            .toList()
          ..sort((a, b) => DateTime.parse(b.fecha).compareTo(DateTime.parse(a.fecha)));
      default:
        return _partidos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _acento))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _cargarPartidos,
                  color: _acento,
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverHeader(),
                      SliverToBoxAdapter(child: _buildFiltros()),
                      _partidosFiltrados.isEmpty
                          ? const SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sports_basketball_outlined,
                                        size: 64, color: AppColors.grisClaro),
                                    SizedBox(height: 16),
                                    Text('No hay partidos en esta categoría',
                                        style: TextStyle(color: AppColors.grisClaro)),
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (_, i) => _buildPartidoCard(_partidosFiltrados[i]),
                                  childCount: _partidosFiltrados.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.rojoAragon,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradienteJugador),
          child: const SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(height: 48),
              Icon(Icons.calendar_today, color: AppColors.blanco, size: 32),
              SizedBox(height: 8),
              Text('Mis Partidos',
                  style: TextStyle(color: AppColors.blanco, fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
        title: const Text('Mis Partidos',
            style: TextStyle(color: AppColors.blanco, fontSize: 16,
                fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        _buildFiltroBtn('PROXIMOS', 'Próximos'),
        const SizedBox(width: 8),
        _buildFiltroBtn('TODOS', 'Todos'),
        const SizedBox(width: 8),
        _buildFiltroBtn('FINALIZADOS', 'Finalizados'),
      ]),
    );
  }

  Widget _buildFiltroBtn(String valor, String label) {
    final activo = _filtro == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filtro = valor),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? _acento : _acento.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: activo ? _acento : _acento.withOpacity(0.3)),
          ),
          child: Text(label,
              style: TextStyle(
                  color: activo ? AppColors.negro : AppColors.grisClaro,
                  fontSize: 12,
                  fontWeight: activo ? FontWeight.bold : FontWeight.normal),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 64, color: AppColors.rojoAragon),
        const SizedBox(height: 16),
        Text(_error!, style: const TextStyle(color: AppColors.blanco),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _cargarPartidos,
          style: ElevatedButton.styleFrom(backgroundColor: _acento),
          child: const Text('Reintentar'),
        ),
      ]),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final fechaPartido = DateTime.parse(partido.fecha);
    final now = DateTime.now();
    final isToday = fechaPartido.year == now.year &&
        fechaPartido.month == now.month &&
        fechaPartido.day == now.day;
    final isPast = fechaPartido.isBefore(now);

    Color estadoColor;
    String estadoTexto;
    IconData estadoIcono;

    if (partido.estado == 'FINALIZADO') {
      estadoTexto = 'Finalizado';
      estadoColor = AppColors.naranja;
      estadoIcono = Icons.check_circle_outline;
    } else if (isToday) {
      estadoTexto = 'Hoy';
      estadoColor = AppColors.amarilloAragon;
      estadoIcono = Icons.today;
    } else if (isPast) {
      estadoTexto = 'No jugado';
      estadoColor = AppColors.rojoAragon;
      estadoIcono = Icons.cancel_outlined;
    } else {
      estadoTexto = 'Programado';
      estadoColor = _acento;
      estadoIcono = Icons.event;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isToday ? _acento.withOpacity(0.08) : AppColors.superficie1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? _acento.withOpacity(0.4) : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: estadoColor.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14), topRight: Radius.circular(14)),
          ),
          child: Row(children: [
            Icon(estadoIcono, color: estadoColor, size: 14),
            const SizedBox(width: 6),
            Text(estadoTexto.toUpperCase(),
                style: TextStyle(color: estadoColor, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${partido.nombreLocal} vs ${partido.nombreVisitante}',
                style: const TextStyle(color: AppColors.blanco, fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.grisClaro),
              const SizedBox(width: 6),
              Text(DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(fechaPartido),
                  style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.grisClaro),
              const SizedBox(width: 6),
              Text(DateFormat('HH:mm').format(fechaPartido),
                  style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
            ]),
            if (partido.direccionPabellon != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grisClaro),
                const SizedBox(width: 6),
                Expanded(child: Text(partido.direccionPabellon!,
                    style: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
                    overflow: TextOverflow.ellipsis)),
              ]),
            ],
            if (partido.estado == 'FINALIZADO' && partido.puntosLocal != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.naranja.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.naranja.withOpacity(0.3)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.emoji_events, color: AppColors.naranja, size: 18),
                  const SizedBox(width: 8),
                  Text('${partido.puntosLocal} - ${partido.puntosVisitante}',
                      style: const TextStyle(color: AppColors.blanco,
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}