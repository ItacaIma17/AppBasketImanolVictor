import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/EquipoEntrenador.dart';
import '../../models/jugador.dart';
import '../../services/entrenadorService.dart';
import '../../services/equipoService.dart';
import '../../widgets/MenuLateral.dart';

class MiEquipoPage extends StatefulWidget {
  const MiEquipoPage({super.key});

  @override
  State<MiEquipoPage> createState() => _MiEquipoPageState();
}

class _MiEquipoPageState extends State<MiEquipoPage> {
  bool _isLoading = true;
  EquipoEntrenador? _miEquipo;
  List<Jugador> _jugadores = [];
  String? _error;

  static const _acento = AppColors.naranja;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final equipoData = await EntrenadorService.obtenerMiEquipo();
      final equipo = EquipoEntrenador.fromJson(equipoData);
      if (equipo.tieneEquipo) {
        final jugadores = await EquipoService.getJugadoresEquipo(equipo.equipoId);
        setState(() { _miEquipo = equipo; _jugadores = jugadores; _isLoading = false; });
      } else {
        setState(() { _error = 'No tienes un equipo asignado'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
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
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildEquipoInfo(),
                            const SizedBox(height: 16),
                            _buildJugadoresList(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 160,
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
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(Icons.shield, color: AppColors.blanco, size: 30),
              ),
              const SizedBox(height: 10),
              Text(_miEquipo?.nombreEquipo ?? 'Mi Equipo',
                  style: const TextStyle(color: AppColors.blanco, fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
        title: Text(_miEquipo?.nombreEquipo ?? 'Mi Equipo',
            style: const TextStyle(color: AppColors.blanco, fontSize: 16,
                fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildEquipoInfo() {
    final e = _miEquipo!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _acento.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _acento.withOpacity(0.3)),
      ),
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.gradienteEntrenador,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.emoji_events, size: 34, color: AppColors.blanco),
        ),
        const SizedBox(height: 14),
        Text(e.nombreEquipo,
            style: const TextStyle(color: AppColors.blanco, fontSize: 20,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        if (e.nombreLiga != null)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.emoji_events, size: 13, color: AppColors.grisClaro),
            const SizedBox(width: 4),
            Text(e.nombreLiga!,
                style: const TextStyle(color: AppColors.grisClaro, fontSize: 13)),
          ]),
        if (e.nombreEstadio != null) ...[
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.stadium, size: 13, color: AppColors.grisClaro),
            const SizedBox(width: 4),
            Text(e.nombreEstadio!,
                style: const TextStyle(color: AppColors.grisClaro, fontSize: 13)),
          ]),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Text('Entrenador: ${e.nombreCompletoEntrenador}',
              style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _buildJugadoresList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [
            Container(width: 4, height: 20,
                decoration: BoxDecoration(color: _acento, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            const Icon(Icons.people, color: _acento, size: 17),
            const SizedBox(width: 8),
            const Text('Jugadores del Equipo',
                style: TextStyle(color: AppColors.blanco, fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${_jugadores.length}',
                style: const TextStyle(color: AppColors.grisClaro, fontSize: 13)),
          ]),
        ),
        const Divider(color: Colors.white12, height: 1),
        if (_jugadores.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No hay jugadores en este equipo',
                  style: TextStyle(color: AppColors.grisClaro)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _jugadores.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
            itemBuilder: (_, i) => _buildJugadorItem(_jugadores[i]),
          ),
      ]),
    );
  }

  Widget _buildJugadorItem(Jugador j) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _acento.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(j.dorsal?.toString() ?? '?',
                style: const TextStyle(color: _acento, fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(j.nombreCompleto,
              style: const TextStyle(color: AppColors.blanco, fontSize: 14,
                  fontWeight: FontWeight.w600)),
          Text(j.posicion,
              style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _acento.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _acento.withOpacity(0.3)),
          ),
          child: Text('${j.altura}m',
              style: const TextStyle(color: _acento, fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _buildError() {
    final sinEquipo = _error == 'No tienes un equipo asignado';
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(sinEquipo ? Icons.sports : Icons.error_outline,
            size: 64, color: sinEquipo ? _acento : AppColors.rojoAragon),
        const SizedBox(height: 16),
        Text(_error!, style: const TextStyle(color: AppColors.blanco, fontSize: 14),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: sinEquipo ? () => Navigator.pop(context) : _cargarDatos,
          style: ElevatedButton.styleFrom(backgroundColor: _acento),
          child: Text(sinEquipo ? 'Volver' : 'Reintentar'),
        ),
      ]),
    );
  }
}