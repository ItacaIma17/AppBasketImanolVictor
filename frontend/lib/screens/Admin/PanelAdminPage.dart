import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../services/EstadisticasService.dart';
import '../../widgets/MenuLateral.dart';
import 'GestionPartidos.dart';
import 'GestionPartidosPage.dart' hide GestionPartidosPage;
import 'GestionUsuariosPage.dart';
import 'GestionEntrenadoresPage.dart';
import 'GestionEquiposPage.dart';
import 'GestionLigaPage.dart';
import 'GestionArbitrosPage.dart';
import 'GestionJugadoresPage.dart';

class PanelAdminPage extends StatefulWidget {
  const PanelAdminPage({super.key});

  @override
  State<PanelAdminPage> createState() => _PanelAdminPageState();
}

class _PanelAdminPageState extends State<PanelAdminPage> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _cargarEstadisticas(refresh: true);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _cargarEstadisticas({bool refresh = false}) async {
    if (!refresh) setState(() => _isLoading = true);
    try {
      final stats = await EstadisticasService.getEstadisticasGenerales();
      if (mounted) setState(() { _stats = stats; _isLoading = false; _error = null; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _cargarEstadisticas,
                  color: AppColors.naranja,
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverHeader(),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildKpiRow(),
                            const SizedBox(height: 24),
                            _buildBotonCrearPartido(),
                            const SizedBox(height: 24),
                            _buildSeccionTitulo('Gestión del Sistema', Icons.settings),
                            const SizedBox(height: 12),
                            _buildMenuGestion(),
                            const SizedBox(height: 24),
                            _buildSeccionTitulo('Estado de Partidos', Icons.sports_basketball),
                            const SizedBox(height: 12),
                            _buildPartidosStats(),
                            const SizedBox(height: 24),
                            _buildUltimosPartidos(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLoading() => const Scaffold(
    backgroundColor: AppColors.negro,
    body: Center(child: CircularProgressIndicator(color: AppColors.naranja)),
  );

  Widget _buildError() => Scaffold(
    backgroundColor: AppColors.negro,
    body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 64, color: AppColors.naranja),
        const SizedBox(height: 16),
        Text(_error!, style: const TextStyle(color: AppColors.blanco)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _cargarEstadisticas,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
          child: const Text('Reintentar'),
        ),
      ]),
    ),
  );

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 200,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 38, color: AppColors.blanco),
                ),
                const SizedBox(height: 12),
                const Text('Panel de Administración',
                    style: TextStyle(color: AppColors.blanco, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('ADMINISTRADOR FAB',
                      style: TextStyle(color: AppColors.blanco, fontSize: 11, letterSpacing: 1.2,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        title: const Text('Admin', style: TextStyle(color: AppColors.blanco, fontSize: 16,
            fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildKpiRow() {
    final kpis = [
      _KpiData('Usuarios', _stats['totalUsuarios']?.toString() ?? '0', Icons.people, AppColors.naranja),
      _KpiData('Equipos', _stats['totalEquipos']?.toString() ?? '0', Icons.shield, AppColors.amarilloAragon),
      _KpiData('Ligas', _stats['totalLigas']?.toString() ?? '0', Icons.emoji_events, AppColors.naranja),
      _KpiData('Partidos', _stats['totalPartidos']?.toString() ?? '0', Icons.calendar_today, AppColors.grisClaro),
    ];
    return Row(
      children: kpis.map((k) => Expanded(child: _buildKpiCard(k))).toList(),
    );
  }

  Widget _buildKpiCard(_KpiData k) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: k.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: k.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(k.icon, color: k.color, size: 22),
          const SizedBox(height: 6),
          Text(k.valor,
              style: TextStyle(color: k.color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(k.label,
              style: const TextStyle(color: AppColors.grisClaro, fontSize: 9),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBotonCrearPartido() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradienteNaranjaAmarillo,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.naranja.withOpacity(0.40), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _nav(const GestionPartidosPage()),
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 28, color: AppColors.blanco),
                SizedBox(width: 12),
                Text('Crear Nuevo Partido',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.blanco)),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.blancoOpacidad70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGestion() {
    final items = [
      _MenuItemData('Usuarios', Icons.people, AppColors.naranja, () => _nav(const GestionUsuariosPage())),
      _MenuItemData('Equipos', Icons.shield, AppColors.amarilloAragon, () => _nav(const GestionEquiposPage())),
      _MenuItemData('Ligas', Icons.emoji_events, AppColors.naranja, () => _nav(const GestionLigasPage())),
      _MenuItemData('Partidos', Icons.calendar_today, AppColors.naranja, () => _nav(const GestionPartidosPage())),
      _MenuItemData('Entrenadores', Icons.sports, AppColors.amarilloAragon, () => _nav(const GestionEntrenadoresPage())),
      _MenuItemData('Árbitros', Icons.gavel, AppColors.naranja, () => _nav(const GestionArbitrosPage())),
      _MenuItemData('Jugadores', Icons.sports_basketball, AppColors.amarilloAragon, () => _nav(const GestionJugadoresPage())),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: items.map(_buildMenuItemCard).toList(),
    );
  }

  Widget _buildMenuItemCard(_MenuItemData item) {
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
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 20, color: item.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.label,
                    style: const TextStyle(color: AppColors.blanco, fontSize: 13,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.chevron_right, size: 16, color: item.color.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartidosStats() {
    final hoy = _stats['partidosHoy'] ?? 0;
    final prog = _stats['partidosProgramados'] ?? 0;
    final fin = _stats['partidosFinalizados'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          _buildEstadoStat('HOY', hoy.toString(), AppColors.naranja),
          _buildSep(),
          _buildEstadoStat('PROGRAMADOS', prog.toString(), AppColors.amarilloAragon),
          _buildSep(),
          _buildEstadoStat('FINALIZADOS', fin.toString(), AppColors.rojoAragon),
        ],
      ),
    );
  }

  Widget _buildEstadoStat(String label, String valor, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(valor, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grisClaro)),
        ],
      ),
    );
  }

  Widget _buildSep() => Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1));

  Widget _buildUltimosPartidos() {
    final lista = _stats['ultimosPartidos'] as List? ?? [];
    if (lista.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSeccionTitulo('Últimos Partidos', Icons.history),
        const SizedBox(height: 12),
        ...lista.take(4).map((p) => _buildPartidoItem(p)),
      ],
    );
  }

  Widget _buildPartidoItem(dynamic p) {
    final estado = p['estado'] ?? 'PROGRAMADO';
    final color = estado == 'FINALIZADO' ? AppColors.amarilloAragon : AppColors.naranja;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.naranja.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports_basketball, color: AppColors.naranja, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p['nombreLocal']} vs ${p['nombreVisitante']}',
                  style: const TextStyle(color: AppColors.blanco, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
              Text(p['fecha'] ?? '', style: const TextStyle(color: AppColors.grisClaro, fontSize: 11)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(estado,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo, IconData icono) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            color: AppColors.naranja,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icono, color: AppColors.naranja, size: 17),
        const SizedBox(width: 8),
        Text(titulo,
            style: const TextStyle(color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _nav(Widget p) => Navigator.push(context, MaterialPageRoute(builder: (_) => p));
}

class _KpiData {
  final String label, valor;
  final IconData icon;
  final Color color;
  _KpiData(this.label, this.valor, this.icon, this.color);
}

class _MenuItemData {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _MenuItemData(this.label, this.icon, this.color, this.onTap);
}