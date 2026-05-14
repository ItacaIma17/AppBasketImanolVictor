import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/partido.dart';
import 'package:tfg_appfede/services/alineacionService.dart';

class ConfirmarAlineacionesDetallePage extends StatefulWidget {
  final Partido partido;
  const ConfirmarAlineacionesDetallePage({super.key, required this.partido});

  @override
  State<ConfirmarAlineacionesDetallePage> createState() =>
      _ConfirmarAlineacionesDetallePageState();
}

class _ConfirmarAlineacionesDetallePageState
    extends State<ConfirmarAlineacionesDetallePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  Map<String, dynamic>? _alineacionLocal;
  Map<String, dynamic>? _alineacionVisitante;
  bool _cargando = true;
  bool _confirmando = false;
  String? _error;

  bool get _ambasListas =>
      _alineacionLocal != null && _alineacionVisitante != null;

  bool get _localConfirmada =>
      _alineacionLocal?['confirmada'] == true;

  bool get _visitanteConfirmada =>
      _alineacionVisitante?['confirmada'] == true;

  bool get _ambasConfirmadas => _localConfirmada && _visitanteConfirmada;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _cargarAlineaciones();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargarAlineaciones() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final data = await AlineacionService.getAlineacionesPartido(widget.partido.id);
      if (mounted) {
        setState(() {

          _alineacionLocal = data['local'];
          _alineacionVisitante = data['visitante'];
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _cargando = false; });
    }
  }

  Future<void> _confirmarAlineacion(bool esLocal) async {
    final alineacion = esLocal ? _alineacionLocal : _alineacionVisitante;
    if (alineacion == null) return;

    setState(() => _confirmando = true);
    try {
      await AlineacionService.confirmarAlineacion(
          alineacion['id'] as int);
      await _cargarAlineaciones();
      if (mounted) {
        _showSnack(
          ' Alineación de ${esLocal ? widget.partido.nombreLocal : widget.partido.nombreVisitante} confirmada',
          isError: false,
        );
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _confirmando = false);
    }
  }

  Future<void> _confirmarAmbas() async {
    setState(() => _confirmando = true);
    try {
      if (_alineacionLocal != null && !_localConfirmada) {
        await AlineacionService.confirmarAlineacion(
            _alineacionLocal!['id'] as int);
      }
      if (_alineacionVisitante != null && !_visitanteConfirmada) {
        await AlineacionService.confirmarAlineacion(
            _alineacionVisitante!['id'] as int);
      }
      await _cargarAlineaciones();
      _showSnack(' Ambas alineaciones confirmadas. ¡El partido puede comenzar!',
          isError: false);
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _confirmando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (!_cargando) _buildResumenEstado(),
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
                  _buildAlineacionTab(
                      esLocal: true,
                      alineacion: _alineacionLocal,
                      nombreEquipo:
                      widget.partido.nombreLocal ??
                          'Equipo Local',
                    ),
                    _buildAlineacionTab(
                      esLocal: false,
                      alineacion: _alineacionVisitante,
                      nombreEquipo:
                      widget.partido.nombreVisitante ??
                          'Equipo Visitante',
                    ),
                  ],
                ),
              ),
              if (!_cargando && _ambasListas && !_ambasConfirmadas)
                _buildBotonConfirmarAmbas(),
            ],
          ),
        ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Confirmar Alineaciones',
                    style: TextStyle(
                        color: AppColors.blanco,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(
                  '${widget.partido.nombreLocal ?? "Local"} vs ${widget.partido.nombreVisitante ?? "Visitante"}',
                  style: const TextStyle(
                      color: AppColors.grisClaro, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.blanco),
            onPressed: _cargarAlineaciones,
          ),
        ],
      ),
    );
  }

  Widget _buildResumenEstado() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _ambasConfirmadas
            ? Colors.green.shade900.withOpacity(0.5)
            : Colors.orange.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _ambasConfirmadas
              ? Colors.green.shade600
              : Colors.orange.shade600,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _ambasConfirmadas ? Icons.check_circle : Icons.pending,
            color: _ambasConfirmadas ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _ambasConfirmadas
                  ? '¡Ambas alineaciones confirmadas! El partido puede comenzar.'
                  : _ambasListas
                  ? 'Faltan confirmar ${!_localConfirmada && !_visitanteConfirmada ? "ambas" : (!_localConfirmada ? "la alineación local" : "la alineación visitante")}'
                  : 'Esperando que los entrenadores presenten las alineaciones',
              style: TextStyle(
                color: _ambasConfirmadas ? Colors.green.shade300 : Colors.orange.shade300,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final localOk = _localConfirmada;
    final visitanteOk = _visitanteConfirmada;
    final localPresent = _alineacionLocal != null;
    final visitantePresent = _alineacionVisitante != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
        labelStyle:
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  localPresent
                      ? (localOk ? Icons.check_circle : Icons.radio_button_unchecked)
                      : Icons.hourglass_empty,
                  size: 14,
                  color: localPresent
                      ? (localOk ? Colors.green.shade300 : Colors.orange)
                      : AppColors.grisClaro,
                ),
                const SizedBox(width: 6),
                const Text('Local'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  visitantePresent
                      ? (visitanteOk ? Icons.check_circle : Icons.radio_button_unchecked)
                      : Icons.hourglass_empty,
                  size: 14,
                  color: visitantePresent
                      ? (visitanteOk ? Colors.green.shade300 : Colors.orange)
                      : AppColors.grisClaro,
                ),
                const SizedBox(width: 6),
                const Text('Visitante'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlineacionTab({
    required bool esLocal,
    required Map<String, dynamic>? alineacion,
    required String nombreEquipo,
  }) {
    if (alineacion == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty,
                  color: AppColors.grisClaro, size: 48),
              const SizedBox(height: 16),
              Text(
                'El entrenador de $nombreEquipo\naún no ha presentado la alineación',
                style: const TextStyle(color: AppColors.blanco, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Contacta con el entrenador para que la presente desde la app',
                style: TextStyle(color: AppColors.grisClaro, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final confirmada = alineacion['confirmada'] == true;
    final jugadores =
        (alineacion['jugadores'] as List<dynamic>?) ?? [];
    final titulares = jugadores.where((j) => j['esTitular'] == true).toList();
    final suplentes = jugadores.where((j) => j['esTitular'] == false).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: confirmada
                  ? Colors.green.shade900.withOpacity(0.3)
                  : Colors.orange.shade900.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: confirmada
                      ? Colors.green.shade700
                      : Colors.orange.shade700),
            ),
            child: Row(
              children: [
                Icon(
                  confirmada ? Icons.verified : Icons.pending_outlined,
                  color: confirmada ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        confirmada ? 'Alineación confirmada' : 'Pendiente de confirmación',
                        style: TextStyle(
                          color: confirmada ? Colors.green.shade300 : Colors.orange.shade300,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${titulares.length} titulares · ${suplentes.length} suplentes',
                        style: const TextStyle(
                            color: AppColors.grisClaro, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (!confirmada)
                  ElevatedButton(
                    onPressed: _confirmando
                        ? null
                        : () => _confirmarAlineacion(esLocal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rojoAragon,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _confirmando
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('Confirmar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildSubseccion('Titulares', titulares, isTitular: true),
          const SizedBox(height: 12),

          _buildSubseccion('Suplentes', suplentes, isTitular: false),
        ],
      ),
    );
  }

  Widget _buildSubseccion(
      String titulo, List jugadores, {required bool isTitular}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: isTitular ? AppColors.naranja : AppColors.grisClaro,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$titulo (${jugadores.length})',
              style: TextStyle(
                color: isTitular ? AppColors.blanco : AppColors.grisClaro,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (jugadores.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 8),
            child: Text('Sin jugadores',
                style: TextStyle(color: AppColors.grisClaro, fontSize: 12)),
          )
        else
          ...jugadores.map((j) => _buildFichaJugador(j, isTitular: isTitular)),
      ],
    );
  }

  Widget _buildFichaJugador(Map<String, dynamic> jugador,
      {required bool isTitular}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTitular
                  ? AppColors.naranja.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${jugador['dorsal'] ?? '?'}',
                style: TextStyle(
                  color: isTitular ? AppColors.naranja : AppColors.grisClaro,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${jugador['nombre'] ?? ''} ${jugador['apellido'] ?? ''}',
                  style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                if (jugador['posicion'] != null)
                  Text(
                    jugador['posicion'],
                    style: const TextStyle(
                        color: AppColors.grisClaro, fontSize: 11),
                  ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isTitular
                  ? AppColors.naranja.withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isTitular ? 'Titular' : 'Suplente',
              style: TextStyle(
                color: isTitular ? AppColors.naranja : AppColors.grisClaro,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonConfirmarAmbas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.gradienteRojoNaranja,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton.icon(
          onPressed: _confirmando ? null : _confirmarAmbas,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          icon: _confirmando
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.verified, color: Colors.white),
          label: Text(
            _confirmando
                ? 'Confirmando...'
                : 'Confirmar Ambas Alineaciones',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_error ?? 'Error desconocido',
              style: const TextStyle(color: AppColors.blanco),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarAlineaciones,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rojoAragon),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

