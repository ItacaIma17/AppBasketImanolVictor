import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../models/jugador.dart';
import '../models/equipo.dart';
import '../services/autenticacion_service.dart';
import '../services/equipoService.dart';
import '../widgets/MenuLateral.dart';
import 'MisPartidosJugadorPage.dart';
import 'equipos/DetalleEquipoPage.dart';
import 'JugadorDetallePage.dart';

class PanelJugadorPage extends StatefulWidget {
  const PanelJugadorPage({super.key});

  @override
  State<PanelJugadorPage> createState() => _PanelJugadorPageState();
}

class _PanelJugadorPageState extends State<PanelJugadorPage> {
  Jugador? _jugador;
  Equipo? _equipo;
  bool _isLoading = true;

  static const _acento = AppColors.naranja;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final jugador = AutenticacionService.jugadorActual;
      if (jugador != null && jugador.equipoId != null) {
        final equipo = await EquipoService.obtenerEquipo(jugador.equipoId!);
        setState(() { _jugador = jugador; _equipo = equipo; _isLoading = false; });
      } else {
        setState(() { _jugador = jugador; _isLoading = false; });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _acento))
          : _jugador == null
              ? _buildSinPerfil()
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  color: _acento,
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverHeader(),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildStatsCard(),
                            const SizedBox(height: 20),
                            if (_equipo != null) ...[
                              _buildEquipoCard(),
                              const SizedBox(height: 20),
                            ],
                            _buildSeccionTitulo('Mis Acciones', Icons.flash_on),
                            const SizedBox(height: 12),
                            _buildMenuAcciones(),
                            const SizedBox(height: 24),
                            _buildInfoFisica(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSinPerfil() {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(),
        const SliverFillRemaining(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.person_outline, size: 80, color: AppColors.grisClaro),
              SizedBox(height: 16),
              Text('No hay información de perfil disponible',
                  style: TextStyle(color: AppColors.grisClaro)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverHeader() {
    final nombre = _jugador?.nombreCompleto ?? 'Jugador';
    final posicion = _jugador?.posicion ?? '';
    final dorsal = _jugador?.dorsal ?? 0;

    return SliverAppBar(
      expandedHeight: 210,
      pinned: true,
      backgroundColor: AppColors.rojoAragon,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.blanco),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: [
        if (_jugador != null)
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.blanco),
            onPressed: () => _nav(JugadorDetallePage(jugador: _jugador!)),
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
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2.5),
                  ),
                  child: Center(
                    child: Text(_jugador?.iniciales ?? '',
                        style: const TextStyle(color: AppColors.blanco, fontSize: 28, fontWeight: FontWeight.bold)),
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
                    child: Text('#$dorsal',
                        style: const TextStyle(color: AppColors.negro, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Text(nombre, style: const TextStyle(color: AppColors.blanco, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  if (posicion.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    const Text('·', style: TextStyle(color: AppColors.blancoOpacidad70)),
                    const SizedBox(width: 6),
                    Text(posicion.toUpperCase(), style: const TextStyle(color: AppColors.blanco,
                        fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ]),
              ),
            ]),
          ),
        ),
        title: Text(nombre, style: const TextStyle(color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildStatsCard() {
    final j = _jugador!;
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
          Text('Mis Estadísticas', style: TextStyle(color: AppColors.blanco, fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _buildStat('${j.promedioPuntos.toStringAsFixed(1)}', 'PTS', AppColors.rojoAragon),
          _buildSepVertical(),
          _buildStat('${j.promedioRebotes.toStringAsFixed(1)}', 'REB', _acento),
          _buildSepVertical(),
          _buildStat('${j.promedioAsistencias.toStringAsFixed(1)}', 'AST', AppColors.amarilloAragon),
          _buildSepVertical(),
          _buildStat('${j.promedioRobos.toStringAsFixed(1)}', 'ROB', AppColors.rojoAragon),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _acento.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.sports_basketball, color: _acento, size: 14),
            const SizedBox(width: 6),
            Text('${j.partidosJugados} partidos jugados',
                style: const TextStyle(color: _acento, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStat(String valor, String label, Color color) {
    return Expanded(
      child: Column(children: [
        Text(valor, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.grisClaro, fontSize: 10, letterSpacing: 0.5)),
      ]),
    );
  }

  Widget _buildSepVertical() =>
      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.1));

  Widget _buildEquipoCard() {
    return GestureDetector(
      onTap: () => _nav(EquipoDetallePage(equipo: _equipo!)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _acento.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _acento.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.gradienteJugador,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_basketball, color: AppColors.blanco, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_equipo!.nombre, style: const TextStyle(color: AppColors.blanco, fontSize: 16,
                fontWeight: FontWeight.bold)),
            if (_equipo!.nombreLiga != null)
              Row(children: [
                const Icon(Icons.emoji_events, size: 12, color: AppColors.grisClaro),
                const SizedBox(width: 4),
                Text(_equipo!.nombreLiga!, style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
              ]),
          ])),
          const Icon(Icons.arrow_forward_ios, color: _acento, size: 16),
        ]),
      ),
    );
  }

  Widget _buildMenuAcciones() {
    final acciones = [
      _AccionData(Icons.calendar_today, 'Mis Partidos', _acento,
          () => _nav(const MisPartidosJugadorPage())),
      _AccionData(Icons.sports_basketball, 'Mi Equipo', AppColors.amarilloAragon,
          () { if (_equipo != null) _nav(EquipoDetallePage(equipo: _equipo!)); }),
      _AccionData(Icons.bar_chart, 'Estadísticas', AppColors.rojoAragon,
          () => _nav(JugadorDetallePage(jugador: _jugador!))),
      _AccionData(Icons.people, 'Compañeros', AppColors.amarilloAragon,
          () { if (_equipo != null) _nav(EquipoDetallePage(equipo: _equipo!)); }),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: acciones.map(_buildAccionCard).toList(),
    );
  }

  Widget _buildAccionCard(_AccionData a) {
    return Material(
      color: a.color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: a.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: a.color.withOpacity(0.3)),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(a.icon, color: a.color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(a.label, style: const TextStyle(color: AppColors.blanco, fontSize: 12,
                fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  Widget _buildInfoFisica() {
    final j = _jugador!;
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
          Text('Datos Físicos', style: TextStyle(color: AppColors.blanco, fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _buildDatoFisico('Dorsal', '#${j.dorsal}'),
          _buildDatoFisico('Altura', '${j.altura} m'),
          _buildDatoFisico('Peso', '${j.peso} kg'),
          _buildDatoFisico('Posición', j.posicion),
        ]),
      ]),
    );
  }

  Widget _buildDatoFisico(String label, String valor) {
    return Expanded(
      child: Column(children: [
        Text(valor, style: const TextStyle(color: AppColors.blanco, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.grisClaro, fontSize: 10)),
      ]),
    );
  }

  Widget _buildSeccionTitulo(String titulo, IconData icono) {
    return Row(children: [
      Container(width: 4, height: 20,
          decoration: BoxDecoration(color: _acento, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Icon(icono, color: _acento, size: 17),
      const SizedBox(width: 8),
      Text(titulo, style: const TextStyle(color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  void _nav(Widget p) => Navigator.push(context, MaterialPageRoute(builder: (_) => p));
}

class _AccionData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _AccionData(this.icon, this.label, this.color, this.onTap);
}