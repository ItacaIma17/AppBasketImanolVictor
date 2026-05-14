import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/EquipoEntrenador.dart';
import '../../models/partido.dart';
import '../../services/entrenadorService.dart';
import '../../services/partidoService.dart';
import '../../widgets/MenuLateral.dart';
import 'PresentarAlinecionPage.dart';
import '../DetallesPartido.dart';

class ProximosPartidosPage extends StatefulWidget {
  const ProximosPartidosPage({super.key});

  @override
  State<ProximosPartidosPage> createState() => _ProximosPartidosPageState();
}

class _ProximosPartidosPageState extends State<ProximosPartidosPage> {
  List<Partido> _partidos = [];
  EquipoEntrenador? _miEquipo;
  bool _isLoading = true;
  String _filtro = 'PROXIMOS';
  String? _error;

  static const _acento = AppColors.naranja;

  DateTime? _parseFecha(String s) {
    if (s.isEmpty) return null;
    try {
      final p = s.split('/');
      if (p.length == 3) return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {}
    return null;
  }

  int _compareFechas(String a, String b) {
    final da = _parseFecha(a), db = _parseFecha(b);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

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
        final partidos = await PartidoService.getPartidosByEquipo(equipo.equipoId);
        setState(() { _miEquipo = equipo; _partidos = partidos; _isLoading = false; });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Partido> get _partidosFiltrados {
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    switch (_filtro) {
      case 'PROXIMOS':
        return _partidos.where((p) {
          final f = _parseFecha(p.fecha);
          return p.estado != 'FINALIZADO' && f != null && !f.isBefore(hoy);
        }).toList()..sort((a, b) => _compareFechas(a.fecha, b.fecha));
      case 'FINALIZADOS':
        return _partidos.where((p) => p.estado == 'FINALIZADO').toList()
          ..sort((a, b) => _compareFechas(b.fecha, a.fecha));
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
                  onRefresh: _cargarDatos,
                  color: _acento,
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverHeader(),
                      SliverToBoxAdapter(child: _buildFiltros()),
                      _miEquipo == null
                          ? const SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sports, size: 64, color: AppColors.grisClaro),
                                    SizedBox(height: 16),
                                    Text('No tienes un equipo asignado',
                                        style: TextStyle(color: AppColors.grisClaro)),
                                  ],
                                ),
                              ),
                            )
                          : _partidosFiltrados.isEmpty
                              ? SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _filtro == 'PROXIMOS'
                                              ? Icons.calendar_today
                                              : Icons.history,
                                          size: 64, color: AppColors.grisClaro),
                                        const SizedBox(height: 16),
                                        Text(
                                          _filtro == 'PROXIMOS'
                                              ? 'No hay próximos partidos'
                                              : 'No hay partidos finalizados',
                                          style: const TextStyle(color: AppColors.grisClaro)),
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
      backgroundColor: _acento,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradienteEntrenador),
          child: SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 48),
              Text(
                _miEquipo != null ? _miEquipo!.nombreEquipo : 'Partidos',
                style: const TextStyle(color: AppColors.blanco, fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text('Próximos Partidos',
                  style: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 13)),
            ]),
          ),
        ),
        title: const Text('Próximos Partidos',
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
          onPressed: _cargarDatos,
          style: ElevatedButton.styleFrom(backgroundColor: _acento),
          child: const Text('Reintentar'),
        ),
      ]),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final esLocal = partido.nombreLocal == _miEquipo?.nombreEquipo;
    final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;
    final tieneAlineacion = esLocal
        ? partido.tieneAlineacionLocal ?? false
        : partido.tieneAlineacionVisitante ?? false;

    final fechaParsed = _parseFecha(partido.fecha);
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final isToday = fechaParsed != null &&
        fechaParsed.year == now.year &&
        fechaParsed.month == now.month &&
        fechaParsed.day == now.day;
    final isPast = fechaParsed != null && fechaParsed.isBefore(hoy);
    final esFinalizado = partido.estado == 'FINALIZADO';

    Color estadoColor;
    String estadoTexto;
    IconData estadoIcono;
    if (esFinalizado) {
      estadoColor = _acento; estadoTexto = 'Finalizado'; estadoIcono = Icons.check_circle_outline;
    } else if (isToday) {
      estadoColor = AppColors.amarilloAragon; estadoTexto = 'Hoy'; estadoIcono = Icons.today;
    } else if (isPast) {
      estadoColor = AppColors.rojoAragon; estadoTexto = 'No jugado'; estadoIcono = Icons.cancel_outlined;
    } else {
      estadoColor = _acento; estadoTexto = 'Programado'; estadoIcono = Icons.event;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isToday ? _acento.withOpacity(0.08) : AppColors.superficie1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? _acento.withOpacity(0.4) : Colors.white.withOpacity(0.07)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => DetallePartidoPage(partido: partido))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('vs $rival',
                      style: const TextStyle(color: AppColors.blanco, fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: estadoColor.withOpacity(0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(estadoIcono, size: 12, color: estadoColor),
                    const SizedBox(width: 4),
                    Text(estadoTexto,
                        style: TextStyle(color: estadoColor, fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.grisClaro),
                const SizedBox(width: 6),
                Text(partido.fecha,
                    style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
                if (partido.hora.isNotEmpty) ...[
                  const SizedBox(width: 14),
                  const Icon(Icons.access_time, size: 14, color: AppColors.grisClaro),
                  const SizedBox(width: 6),
                  Text(partido.hora,
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
                ],
              ]),
              if (partido.pabellon.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grisClaro),
                  const SizedBox(width: 6),
                  Expanded(child: Text(partido.pabellon,
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
                ]),
              ],
              if (!esFinalizado && !isPast) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: tieneAlineacion ? _acento : AppColors.rojoAragon,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tieneAlineacion ? 'Alineación presentada' : 'Alineación pendiente',
                      style: TextStyle(
                          color: tieneAlineacion ? _acento : AppColors.rojoAragon,
                          fontSize: 12),
                    ),
                  ),
                  if (!tieneAlineacion)
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                            builder: (_) => PresentarAlineacionPage(
                                partido: partido, esLocal: esLocal),
                          )).then((_) => _cargarDatos()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _acento.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _acento.withOpacity(0.5)),
                        ),
                        child: const Text('Presentar',
                            style: TextStyle(color: _acento, fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ]),
              ],
              if (esFinalizado && partido.puntosLocal != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _acento.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _acento.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.emoji_events, color: _acento, size: 18),
                    const SizedBox(width: 8),
                    Text('${partido.puntosLocal} - ${partido.puntosVisitante}',
                        style: const TextStyle(color: AppColors.blanco,
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}