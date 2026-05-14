import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/EquipoEntrenador.dart';
import '../../models/jugador.dart';
import '../../models/partido.dart';
import '../../services/autenticacion_service.dart';
import '../../services/entrenadorService.dart';
import '../../services/equipoService.dart';
import '../../services/partidoService.dart';
import '../../widgets/MenuLateral.dart';
import '../equipos/ConfiguracionPage.dart';
import 'JugadoresEquipoPage.dart';
import '../equipos/SolicitarEquipoPage.dart';
import 'MiEquipoPage.dart';
import 'PresentarAlinecionPage.dart';
import 'SeleccionarPartidoEntrenadorPage.dart';
import 'ProximosPartidosPage.dart';
import 'EstadisticasEquipoPage.dart';
import 'MisPartidosEntrenadorPage.dart';
import 'VerAlineacionesEntrenadorPage.dart';

class PanelEntrenadorPage extends StatefulWidget {
  const PanelEntrenadorPage({super.key});

  @override
  State<PanelEntrenadorPage> createState() => _PanelEntrenadorPageState();
}

class _PanelEntrenadorPageState extends State<PanelEntrenadorPage> {
  bool _isLoading = true;
  bool _tieneEquipo = false;
  EquipoEntrenador? _miEquipo;
  List<Jugador> _jugadores = [];
  List<Partido> _proximosPartidos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  DateTime? _parseFecha(String s) {
    try {
      final p = s.split('/');
      if (p.length == 3) return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {}
    return null;
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final equipoData = await EntrenadorService.obtenerMiEquipo();
      final equipo = EquipoEntrenador.fromJson(equipoData);

      if (equipo.tieneEquipo) {
        final jugadores = await EquipoService.getJugadoresEquipo(equipo.equipoId);
        final partidos = await PartidoService.getProximosPartidosEquipo(equipo.equipoId);
        partidos.sort((a, b) {
          final da = _parseFecha(a.fecha), db = _parseFecha(b.fecha);
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return da.compareTo(db);
        });
        setState(() {
          _miEquipo = equipo;
          _jugadores = jugadores;
          _proximosPartidos = partidos;
          _tieneEquipo = true;
          _isLoading = false;
        });
      } else {
        setState(() { _tieneEquipo = false; _isLoading = false; });
      }
    } catch (_) {
      setState(() { _tieneEquipo = false; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
          : _tieneEquipo && _miEquipo != null
              ? _buildConEquipo()
              : _buildSinEquipo(),
    );
  }

  Widget _buildSinEquipo() {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(sinEquipo: true),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.naranja.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.naranja.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.sports, size: 60, color: AppColors.naranja),
                ),
                const SizedBox(height: 24),
                const Text('Sin equipo asignado',
                    style: TextStyle(color: AppColors.blanco, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Solicita un equipo para acceder\na todas las funcionalidades.',
                    style: TextStyle(color: AppColors.grisClaro, fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                _buildBotonPrimario(
                  Icons.vpn_key, 'Solicitar Equipo',
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SolicitarEquipoPage()))
                      .then((_) => _cargarDatos()),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConEquipo() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: AppColors.naranja,
      child: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildEquipoHero(),
                const SizedBox(height: 20),
                _buildKpiRow(),
                const SizedBox(height: 24),
                _buildSeccionTitulo('Gestión del Equipo', Icons.sports),
                const SizedBox(height: 12),
                _buildMenuGestion(),
                const SizedBox(height: 24),
                if (_proximosPartidos.isNotEmpty) ...[
                  _buildSeccionTitulo('Próximos Partidos', Icons.calendar_today),
                  const SizedBox(height: 12),
                  ..._proximosPartidos.take(3).map(_buildPartidoCard),
                ],
                const SizedBox(height: 24),
                _buildAccionesRapidas(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader({bool sinEquipo = false}) {
    final entrenador = AutenticacionService.usuarioActual;
    final nombre = entrenador?.nombre ?? 'Entrenador';

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.naranja,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.blanco),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradienteEntrenador),
          child: SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 48),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'E',
                      style: const TextStyle(color: AppColors.blanco, fontSize: 26, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              Text(nombre, style: const TextStyle(color: AppColors.blanco, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('ENTRENADOR', style: TextStyle(color: AppColors.blanco, fontSize: 11,
                    letterSpacing: 1.2, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
        title: const Text('Entrenador', style: TextStyle(color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildEquipoHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.naranja.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.naranja.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.gradienteEntrenador,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.emoji_events, size: 30, color: AppColors.blanco),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_miEquipo!.nombreEquipo,
                  style: const TextStyle(color: AppColors.blanco, fontSize: 18, fontWeight: FontWeight.bold)),
              if (_miEquipo!.nombreLiga != null) ...[
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.emoji_events, size: 12, color: AppColors.naranja),
                  const SizedBox(width: 4),
                  Text(_miEquipo!.nombreLiga!,
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
                ]),
              ],
              if (_miEquipo!.nombreEstadio != null) ...[
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.stadium, size: 12, color: AppColors.grisClaro),
                  const SizedBox(width: 4),
                  Text(_miEquipo!.nombreEstadio!,
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
                ]),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        _buildKpi(Icons.people, '${_jugadores.length}', 'Jugadores', AppColors.naranja),
        const SizedBox(width: 10),
        _buildKpi(Icons.calendar_today, '${_proximosPartidos.length}', 'Partidos', AppColors.amarilloAragon),
        const SizedBox(width: 10),
        _buildKpi(Icons.emoji_events, '${_miEquipo?.victorias ?? 0}', 'Victorias', AppColors.rojoAragon),
      ],
    );
  }

  Widget _buildKpi(IconData icon, String valor, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(valor, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.grisClaro, fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _buildMenuGestion() {
    final items = [
      _Item('Mi Equipo', Icons.people, AppColors.naranja, () => _nav(const MiEquipoPage())),
      _Item('Jugadores', Icons.sports_basketball, AppColors.amarilloAragon,
          () => _nav(JugadoresEquipoPage(equipoId: _miEquipo!.equipoId))),
      _Item('Partidos', Icons.calendar_today, AppColors.naranja, () => _nav(const ProximosPartidosPage())),
      _Item('Alineación', Icons.line_style, AppColors.rojoAragon,
          () => _nav(const SeleccionarPartidoEntrenadorPage())),
      _Item('Estadísticas', Icons.bar_chart, AppColors.amarilloAragon,
          () => _nav(const EstadisticasEquipoPage())),
      _Item('Mis Partidos', Icons.history, AppColors.naranja,
          () => _nav(const MisPartidosEntrenadorPage())),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: items.map(_buildItemCard).toList(),
    );
  }

  Widget _buildItemCard(_Item item) {
    return Material(
      color: item.color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: item.color.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 19, color: item.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item.label,
                  style: const TextStyle(color: AppColors.blanco, fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Icon(Icons.chevron_right, size: 15, color: item.color.withOpacity(0.7)),
          ]),
        ),
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final esLocal = partido.nombreLocal == _miEquipo!.nombreEquipo;
    final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;
    final ubicacion = partido.pabellon.isNotEmpty ? partido.pabellon : 'Sin ubicación';

    final hoy = DateTime.now();
    final f = _parseFecha(partido.fecha);
    final esHoy = f != null && f.day == hoy.day && f.month == hoy.month && f.year == hoy.year;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esHoy ? AppColors.naranja.withOpacity(0.12) : AppColors.superficie1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esHoy ? AppColors.naranja.withOpacity(0.5) : Colors.white.withOpacity(0.07)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.naranja.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.sports_basketball, color: AppColors.naranja, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('vs $rival', style: const TextStyle(color: AppColors.blanco, fontSize: 14,
              fontWeight: FontWeight.bold)),
          Text('${partido.fecha} · ${partido.hora}',
              style: const TextStyle(color: AppColors.grisClaro, fontSize: 11)),
          Text(ubicacion, style: const TextStyle(color: AppColors.grisClaro, fontSize: 11),
              overflow: TextOverflow.ellipsis),
        ])),
        if (esHoy)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.naranja,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('HOY', style: TextStyle(color: AppColors.blanco, fontSize: 10,
                fontWeight: FontWeight.bold)),
          )
        else
          GestureDetector(
            onTap: () => _nav(PresentarAlineacionPage(partido: partido, esLocal: esLocal)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.naranja.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.naranja.withOpacity(0.5)),
              ),
              child: const Text('Alineación',
                  style: TextStyle(color: AppColors.naranja, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
      ]),
    );
  }

  Widget _buildAccionesRapidas() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSeccionTitulo('Acciones Rápidas', Icons.flash_on),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _buildBotonPrimario(Icons.line_style, 'Enviar Alineación',
            () => _nav(const SeleccionarPartidoEntrenadorPage()))),
        const SizedBox(width: 10),
        Expanded(child: _buildBotonSecundario(Icons.bar_chart, 'Estadísticas',
            () => _nav(const EstadisticasEquipoPage()))),
      ]),
    ]);
  }

  Widget _buildBotonPrimario(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.gradienteEntrenador,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.naranja.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: AppColors.blanco, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.blanco, fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBotonSecundario(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: AppColors.naranja.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.naranja.withOpacity(0.4)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: AppColors.naranja, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.naranja, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo, IconData icono) {
    return Row(children: [
      Container(width: 4, height: 20,
          decoration: BoxDecoration(color: AppColors.naranja, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Icon(icono, color: AppColors.naranja, size: 17),
      const SizedBox(width: 8),
      Text(titulo, style: const TextStyle(color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  void _nav(Widget p) => Navigator.push(context, MaterialPageRoute(builder: (_) => p));
}

class _Item {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _Item(this.label, this.icon, this.color, this.onTap);
}