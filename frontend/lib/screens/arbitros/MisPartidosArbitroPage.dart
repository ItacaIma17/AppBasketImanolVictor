import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/partido.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';
import '../../models/actaPartido.dart';
import '../../services/actaService.dart';
import '../../services/arbitroService.dart';
import '../../utils/descarga_pdf.dart';
import 'ConfirmarAlineaciones.dart';
import 'CrearActaPage.dart';
import 'verActaArbitroPage.dart';

class MisPartidosArbitroPage extends StatefulWidget {
  const MisPartidosArbitroPage({super.key});

  @override
  State<MisPartidosArbitroPage> createState() => _MisPartidosArbitroPageState();
}

class _MisPartidosArbitroPageState extends State<MisPartidosArbitroPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Partido> _todosPartidos = [];
  bool _cargando = true;
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
      return null;
    }
  }

  DateTime? _parseHoraConFecha(String fechaStr, String horaStr) {
    final fecha = _parseFecha(fechaStr);
    if (fecha == null) return null;
    try {
      final parts = horaStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(fecha.year, fecha.month, fecha.day, hour, minute);
      }
      return fecha;
    } catch (e) {
      return fecha;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _cargarPartidos();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargarPartidos() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final partidos = await ArbitroService.getMisPartidos();
      if (mounted) setState(() { _todosPartidos = partidos; _cargando = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _cargando = false; });
    }
  }

  List<Partido> get _proximos {
    final ahora = DateTime.now();
    final lista = _todosPartidos
        .where((p) => p.estado == 'PROGRAMADO' || p.estado == 'EN_CURSO')
        .toList();

    lista.sort((a, b) {
      final fechaHoraA = _parseHoraConFecha(a.fecha, a.hora);
      final fechaHoraB = _parseHoraConFecha(b.fecha, b.hora);
      if (fechaHoraA == null && fechaHoraB == null) return 0;
      if (fechaHoraA == null) return 1;
      if (fechaHoraB == null) return -1;
      return fechaHoraA.compareTo(fechaHoraB);
    });

    return lista;
  }

  List<Partido> get _finalizados {
    final lista = _todosPartidos
        .where((p) => p.estado == 'FINALIZADO')
        .toList();

    lista.sort((a, b) {
      final fechaA = _parseFecha(a.fecha);
      final fechaB = _parseFecha(b.fecha);
      if (fechaA == null && fechaB == null) return 0;
      if (fechaA == null) return 1;
      if (fechaB == null) return -1;
      return fechaB.compareTo(fechaA);
    });

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final arbitro = AutenticacionService.arbitroActual;

    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(arbitro?.nombreCompleto ?? 'Árbitro'),
            _buildTabs(),
            Expanded(
              child: _cargando
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.amarilloAragon))
                  : _error != null
                  ? _buildError()
                  : TabBarView(
                controller: _tabs,
                children: [
                  _buildLista(_proximos, esProximo: true),
                  _buildLista(_finalizados, esProximo: false),
                  _buildLista(_todosPartidos, esProximo: null),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BarraInferior(selectedIndex: 4),
    );
  }

  Widget _buildHeader(String nombre) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.blanco),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mis Partidos',
                  style: TextStyle(
                      color: AppColors.blanco,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(nombre,
                  style: const TextStyle(
                      color: AppColors.grisClaro, fontSize: 13)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.blanco),
            onPressed: _cargarPartidos,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabs,
        indicator: BoxDecoration(
          gradient: AppColors.gradienteRojoNaranja,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: AppColors.blanco,
        unselectedLabelColor: AppColors.grisClaro,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'Próximos (${_proximos.length})'),
          Tab(text: 'Historial (${_finalizados.length})'),
          Tab(text: 'Todos (${_todosPartidos.length})'),
        ],
      ),
    );
  }

  Widget _buildLista(List<Partido> partidos, {required bool? esProximo}) {
    if (partidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_basketball_outlined,
                size: 64, color: AppColors.blancoOpacidad70),
            const SizedBox(height: 16),
            const Text('No hay partidos',
                style: TextStyle(color: AppColors.blanco, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              esProximo == true
                  ? 'No tienes partidos asignados próximamente'
                  : esProximo == false
                  ? 'Aún no has arbitrado ningún partido'
                  : 'No hay partidos registrados',
              style: const TextStyle(color: AppColors.grisClaro, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarPartidos,
      color: AppColors.naranja,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: partidos.length,
        itemBuilder: (context, i) =>
            _buildTarjetaPartido(partidos[i]),
      ),
    );
  }

  Widget _buildTarjetaPartido(Partido partido) {
    final esProximo = partido.estado == 'PROGRAMADO';
    final enCurso = partido.estado == 'EN_CURSO';
    final finalizado = partido.estado == 'FINALIZADO';

    Color estadoColor = esProximo
        ? AppColors.amarilloAragon
        : enCurso
        ? AppColors.naranja
        : AppColors.naranja;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estadoColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: estadoColor.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  esProximo
                      ? Icons.schedule
                      : enCurso
                      ? Icons.play_circle
                      : Icons.check_circle,
                  color: estadoColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  esProximo
                      ? 'PROGRAMADO'
                      : enCurso
                      ? 'EN CURSO'
                      : 'FINALIZADO',
                  style: TextStyle(
                      color: estadoColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const Spacer(),
                if (partido.jornada != null)
                  Text(
                    'Jornada ${partido.jornada}',
                    style: const TextStyle(
                        color: AppColors.grisClaro, fontSize: 11),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [

                Row(
                  children: [
                    Expanded(
                        child: _buildEquipoMini(partido.nombreLocal)),
                    Column(
                      children: [
                        if (finalizado)
                          Text(
                            '${partido.puntosLocal} - ${partido.puntosVisitante}',
                            style: const TextStyle(
                              color: AppColors.amarilloAragon,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          const Text(
                            'vs',
                            style: TextStyle(
                                color: AppColors.blanco,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),

                        Text(
                          '${partido.fecha} · ${partido.hora}',
                          style: const TextStyle(
                              color: AppColors.grisClaro, fontSize: 11),
                        ),
                      ],
                    ),
                    Expanded(
                      child: _buildEquipoMini(partido.nombreVisitante),
                    ),
                  ],
                ),

                if (partido.pabellon.isNotEmpty) ...[
                  const Divider(color: Colors.white12, height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.naranja, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          partido.pabellon,
                          style: const TextStyle(
                              color: AppColors.grisClaro, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                _buildBotonesAccion(partido),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipoMini(String nombre) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.rojoAragon.withOpacity(0.3),
          child: Text(
            nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
            style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          nombre,
          style: const TextStyle(color: AppColors.blanco, fontSize: 12),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _descargarPdf(Partido partido) async {
    try {
      final bytes = await ActaService.descargarActaPdf(partido.id);
      await guardarYAbrirPdf(bytes, 'acta_partido_${partido.id}.pdf');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error descargando PDF: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _navegarAEditarActa(Partido partido) async {
    try {
      final ActaPartido acta = await ActaService.obtenerActaPorPartido(partido.id);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CrearActaPage(partido: partido, actaExistente: acta),
        ),
      );
      _cargarPartidos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando acta: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildBotonesAccion(Partido partido) {
    final esFinalizado = partido.estado == 'FINALIZADO';
    final tieneActa = partido.tieneActa == true;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [

        if (!esFinalizado)
          _buildBotonAccion(
            icono: Icons.checklist,
            label: 'Confirmar Alineaciones',
            color: AppColors.amarilloAragon,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ConfirmarAlineacionesDetallePage(partido: partido),
              ),
            ).then((_) => _cargarPartidos()),
          ),

        if (tieneActa) ...[
          _buildBotonAccion(
            icono: Icons.description_outlined,
            label: 'Ver Acta',
            color: AppColors.naranja,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerActaArbitroPage(partido: partido),
              ),
            ).then((_) => _cargarPartidos()),
          ),
          _buildBotonAccion(
            icono: Icons.picture_as_pdf,
            label: 'Descargar PDF',
            color: AppColors.naranja,
            onTap: () => _descargarPdf(partido),
          ),
          _buildBotonAccion(
            icono: Icons.edit_document,
            label: 'Editar Acta',
            color: AppColors.amarilloAragon,
            onTap: () => _navegarAEditarActa(partido),
          ),
        ] else
          _buildBotonAccion(
            icono: Icons.edit_document,
            label: 'Subir Acta',
            color: AppColors.amarilloAragon,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CrearActaPage(partido: partido),
              ),
            ).then((_) => _cargarPartidos()),
          ),
      ],
    );
  }

  Widget _buildBotonAccion({
    required IconData icono,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.rojoAragon, size: 48),
          const SizedBox(height: 16),
          const Text('Error cargando partidos',
              style: TextStyle(color: AppColors.blanco, fontSize: 16)),
          const SizedBox(height: 8),
          Text(_error ?? '',
              style: const TextStyle(
                  color: AppColors.grisClaro, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargarPartidos,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rojoAragon),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
