import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/arbitro.dart';
import '../../models/partido.dart';
import '../../services/arbitroService.dart';
import '../../services/autenticacion_service.dart';
import '../../widgets/MenuLateral.dart';
import '../Partidos/SeleccionarPartidoPage.dart';
import 'CrearActaPage.dart';
import 'MisPartidosArbitroPage.dart';
import 'SeleccionarPartidoActaPage.dart';
import 'VerActaArbitroPage.dart';

class PanelArbitroPage extends StatefulWidget {
  const PanelArbitroPage({super.key});

  @override
  State<PanelArbitroPage> createState() => _PanelArbitroPageState();
}

class _PanelArbitroPageState extends State<PanelArbitroPage> {
  Arbitro? _arbitro;
  List<Partido> _partidos = [];
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
      final arbitro = AutenticacionService.arbitroActual;
      if (arbitro != null) {
        final partidos = await ArbitroService.getMisPartidos();
        setState(() {
          _arbitro = arbitro;
          _partidos = partidos;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
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
          : _arbitro == null
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
                            _buildKpiRow(),
                            const SizedBox(height: 24),
                            _buildSeccionTitulo('Acciones Rápidas', Icons.flash_on),
                            const SizedBox(height: 12),
                            _buildMenuAcciones(),
                            const SizedBox(height: 24),
                            if (_proximosPendientes.isNotEmpty) ...[
                              _buildSeccionTitulo('Próximas Designaciones', Icons.assignment),
                              const SizedBox(height: 12),
                              ..._proximosPendientes.take(3).map(_buildPartidoCard),
                            ],
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  List<Partido> get _proximosPendientes =>
      _partidos.where((p) => p.estado != 'FINALIZADO').toList();

  Widget _buildSinPerfil() {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(),
        const SliverFillRemaining(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.gavel, size: 80, color: AppColors.grisClaro),
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
    final nombre = _arbitro?.nombreCompleto ?? 'Árbitro';
    final codigo = _arbitro?.codigoArbitro ?? 'N/A';

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
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 48),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.gavel, size: 36, color: AppColors.blanco),
              ),
              const SizedBox(height: 10),
              Text(nombre, style: const TextStyle(color: AppColors.blanco, fontSize: 18,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('ÁRBITRO', style: TextStyle(color: AppColors.blanco, fontSize: 11,
                      letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                  if (_arbitro != null) ...[
                    const SizedBox(width: 6),
                    const Text('·', style: TextStyle(color: AppColors.blanco)),
                    const SizedBox(width: 6),
                    Text(codigo, style: const TextStyle(color: AppColors.blanco, fontSize: 11,
                        fontWeight: FontWeight.w600)),
                  ],
                ]),
              ),
            ]),
          ),
        ),
        title: const Text('Árbitro', style: TextStyle(color: AppColors.blanco, fontSize: 16,
            fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildKpiRow() {
    final pendientes = _partidos.where((p) => p.estado != 'FINALIZADO').length;
    final finalizados = _partidos.where((p) => p.estado == 'FINALIZADO').length;
    final total = _partidos.length;

    return Row(children: [
      _buildKpi(Icons.pending_actions, '$pendientes', 'Pendientes', _acento),
      const SizedBox(width: 10),
      _buildKpi(Icons.check_circle_outline, '$finalizados', 'Finalizados', AppColors.naranja),
      const SizedBox(width: 10),
      _buildKpi(Icons.calendar_month, '$total', 'Total', AppColors.rojoAragon),
    ]);
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

  Widget _buildMenuAcciones() {
    final acciones = [
      _AccionData(Icons.calendar_today, 'Mis Partidos', _acento, () => _nav(const MisPartidosArbitroPage())),
      _AccionData(Icons.people_outline, 'Ver Alineaciones', AppColors.naranja, () => _nav(const SeleccionarPartidoPage())),
      _AccionData(Icons.description, 'Subir Acta', _acento, () => _nav(const SeleccionarPartidoActaPage())),
      _AccionData(Icons.how_to_reg, 'Confirmar Alineaciones', AppColors.naranja, () => _nav(const MisPartidosArbitroPage())),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
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
            Text(a.label,
                style: const TextStyle(color: AppColors.blanco, fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center, maxLines: 2),
          ]),
        ),
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final alinListas = (partido.tieneAlineacionLocal ?? false) && (partido.tieneAlineacionVisitante ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _acento.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.sports_basketball, color: _acento, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${partido.nombreLocal} vs ${partido.nombreVisitante}',
              style: const TextStyle(color: AppColors.blanco, fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          Text('${partido.fecha} · ${partido.hora}',
              style: const TextStyle(color: AppColors.grisClaro, fontSize: 11)),
          if (!alinListas)
            const Text('Esperando alineaciones',
                style: TextStyle(color: AppColors.naranja, fontSize: 11)),
        ])),
        const SizedBox(width: 8),
        partido.tieneActa == true
            ? _buildChipAccion('Ver Acta', AppColors.naranja,
                () => _nav(VerActaArbitroPage(partido: partido)))
            : alinListas
                ? _buildChipAccion('Crear Acta', _acento,
                    () => _nav(CrearActaPage(partido: partido)))
                : const SizedBox.shrink(),
      ]),
    );
  }

  Widget _buildChipAccion(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
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