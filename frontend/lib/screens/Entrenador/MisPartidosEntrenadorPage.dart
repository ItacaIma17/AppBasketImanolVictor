import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../services/autenticacion_service.dart';
import '../../services/partidoService.dart';
import '../../widgets/MenuLateral.dart';
import 'PresentarAlinecionPage.dart';
import 'VerActaEntrenador.dart';
import 'VerAlineacionesEntrenadorPage.dart';

class MisPartidosEntrenadorPage extends StatefulWidget {
  const MisPartidosEntrenadorPage({super.key});

  @override
  State<MisPartidosEntrenadorPage> createState() => _MisPartidosEntrenadorPageState();
}

class _MisPartidosEntrenadorPageState extends State<MisPartidosEntrenadorPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String? _error;
  String _filtro = 'PROGRAMADO';
  int? _miEquipoId;

  static const _acento = AppColors.naranja;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _miEquipoId = AutenticacionService.entrenadorActual?.equipoId;
      final partidos = await PartidoService.getPartidosEntrenador();
      setState(() { _partidos = partidos; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Partido> get _partidosFiltrados {
    if (_filtro == 'TODOS') return _partidos;
    return _partidos.where((p) => p.estado == _filtro).toList();
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
          child: const SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(height: 48),
              Icon(Icons.history, color: AppColors.blanco, size: 32),
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
        _buildFiltroBtn('PROGRAMADO', 'Pendientes'),
        const SizedBox(width: 8),
        _buildFiltroBtn('FINALIZADO', 'Finalizados'),
        const SizedBox(width: 8),
        _buildFiltroBtn('TODOS', 'Todos'),
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
      child: SingleChildScrollView(
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
      ),
    );
  }

  DateTime? _parseFechaHora(String fecha, String hora) {
    try {
      final parts = fecha.split('/');
      if (parts.length == 3) {
        final d = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final y = int.parse(parts[2]);
        final hParts = hora.split(':');
        if (hParts.length == 2) {
          return DateTime(y, m, d, int.parse(hParts[0]), int.parse(hParts[1]));
        }
        return DateTime(y, m, d);
      }
    } catch (_) {}
    return null;
  }

  Widget _buildPartidoCard(Partido partido) {
    final fechaPartido = _parseFechaHora(partido.fecha, partido.hora);

    final tieneAlineacion = _miEquipoId != null
        ? partido.tieneAlineacionParaEquipo(_miEquipoId!)
        : (partido.tieneAlineacionLocal ?? false);
    final confirmada = _miEquipoId != null
        ? partido.alineacionConfirmadaParaEquipo(_miEquipoId!)
        : (partido.alineacionLocalConfirmada ?? false);
    final esLocal = _miEquipoId != null
        ? partido.esLocalParaEquipo(_miEquipoId!)
        : true;
    final partidoId = int.tryParse(partido.id.toString()) ?? 0;
    final equipoLocalId = int.tryParse(partido.equipoLocalId.toString()) ?? 0;
    final esFinalizado = partido.estado == 'FINALIZADO';

    Color chipColor;
    String chipLabel;
    if (esFinalizado) {
      chipColor = _acento;
      chipLabel = 'Finalizado';
    } else if (!tieneAlineacion) {
      chipColor = AppColors.rojoAragon;
      chipLabel = 'Pendiente';
    } else if (!confirmada) {
      chipColor = Colors.blue;
      chipLabel = 'En Espera';
    } else {
      chipColor = Colors.green;
      chipLabel = 'Confirmada';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (esFinalizado && partido.tieneActa == true) {
              _verActa(partidoId);
            } else if (!esFinalizado && !tieneAlineacion) {
              _presentarAlineacion(partido, esLocal);
            } else if (!esFinalizado && tieneAlineacion) {
              _verAlineacion(partidoId, _miEquipoId ?? equipoLocalId);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('${partido.nombreLocal} vs ${partido.nombreVisitante}',
                      style: const TextStyle(color: AppColors.blanco, fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: chipColor.withOpacity(0.4)),
                  ),
                  child: Text(chipLabel,
                      style: TextStyle(color: chipColor, fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 10),
              if (fechaPartido != null) ...[
                Row(children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.grisClaro),
                  const SizedBox(width: 6),
                  Text(DateFormat('dd/MM/yyyy').format(fechaPartido),
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
                  const SizedBox(width: 14),
                  const Icon(Icons.access_time, size: 14, color: AppColors.grisClaro),
                  const SizedBox(width: 6),
                  Text(DateFormat('HH:mm').format(fechaPartido),
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
                ]),
                const SizedBox(height: 4),
              ],
              if (partido.direccionPabellon != null && partido.direccionPabellon!.isNotEmpty)
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grisClaro),
                  const SizedBox(width: 6),
                  Expanded(child: Text(partido.direccionPabellon!,
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
                ]),
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

  void _presentarAlineacion(Partido partido, bool esLocal) {
    Navigator.push(context,
        MaterialPageRoute(
          builder: (_) => PresentarAlineacionPage(partido: partido, esLocal: esLocal),
        )).then((_) => _cargarPartidos());
  }

  void _verAlineacion(int partidoId, int equipoId) {
    Navigator.push(context,
        MaterialPageRoute(
          builder: (_) => VerAlineacionEntrenadorPage(
              partidoId: partidoId, equipoId: equipoId),
        ));
  }

  void _verActa(int partidoId) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => VerActaEntrenadorPage(partidoId: partidoId)));
  }
}