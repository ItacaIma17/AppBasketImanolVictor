import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/jugador.dart';
import 'package:tfg_appfede/models/partido.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/services/equipoService.dart';
import 'package:tfg_appfede/services/alineacionService.dart';

class PresentarAlineacionPage extends StatefulWidget {
  final Partido partido;
  final bool esLocal;

  const PresentarAlineacionPage({
    super.key,
    required this.partido,
    required this.esLocal,
  });

  @override
  State<PresentarAlineacionPage> createState() => _PresentarAlineacionPageState();
}

class _PresentarAlineacionPageState extends State<PresentarAlineacionPage> {
  List<Jugador> _plantilla = [];
  final Set<int> _titularesIds = {};
  final Set<int> _suplentesIds = {};
  bool _cargando = true;
  bool _enviando = false;
  bool _alineacionEnviada = false;
  bool _confirmadaPorArbitro = false;
  bool _alineacionFija = false;
  Map<String, dynamic>? _alineacionExistente;
  int? _equipoId;

  static const int MAX_TITULARES = 5;
  static const int MAX_SUPLENTES = 7;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final entrenador = AutenticacionService.entrenadorActual;

      if (entrenador == null || entrenador.equipoId == null) {
        if (mounted) setState(() => _cargando = false);
        return;
      }

      _equipoId = entrenador.equipoId;
      final equipoIdEntrenador = _equipoId!;

      final equipoIdPartido = widget.esLocal
          ? widget.partido.equipoLocalId
          : widget.partido.equipoVisitanteId;

      if (equipoIdPartido == null || equipoIdPartido != equipoIdEntrenador) {
        if (mounted) setState(() => _cargando = false);
        return;
      }

      final jugadores = await EquipoService.getJugadoresEquipo(equipoIdEntrenador);

      Map<String, dynamic>? alineacionExistente;
      bool enviada = false;
      bool confirmada = false;

      try {
        alineacionExistente = await AlineacionService.getAlineacionEquipo(
          widget.partido.id,
          equipoIdEntrenador,
        );
        enviada = alineacionExistente != null;
        confirmada = alineacionExistente?['confirmada'] == true;
      } catch (e) {
        print('Error obteniendo alineación existente: $e');
      }

      final prefs = await SharedPreferences.getInstance();
      final fijaJson = prefs.getString('alineacion_fija_equipo_$equipoIdEntrenador');
      final esFija = prefs.getBool('alineacion_fija_activa_$equipoIdEntrenador') ?? false;

      if (mounted) {
        setState(() {
          _plantilla = jugadores;
          _alineacionExistente = alineacionExistente;
          _alineacionEnviada = enviada;
          _confirmadaPorArbitro = confirmada;
          _alineacionFija = esFija;

          if (alineacionExistente != null) {

            final titulares = (alineacionExistente['titulares'] as List?) ?? const [];
            final suplentes = (alineacionExistente['suplentes'] as List?) ?? const [];

            for (final j in titulares) {
              final id = (j is Map ? j['jugadorId'] : null);
              if (id is int) _titularesIds.add(id);
              else if (id is num) _titularesIds.add(id.toInt());
            }
            for (final j in suplentes) {
              final id = (j is Map ? j['jugadorId'] : null);
              if (id is int) _suplentesIds.add(id);
              else if (id is num) _suplentesIds.add(id.toInt());
            }
          } else if (fijaJson != null) {

            try {
              final fija = jsonDecode(fijaJson) as Map<String, dynamic>;
              final tits = (fija['titulares'] as List<dynamic>?) ?? [];
              final sups = (fija['suplentes'] as List<dynamic>?) ?? [];
              _titularesIds.addAll(tits.cast<int>());
              _suplentesIds.addAll(sups.cast<int>());
              _alineacionFija = true;
            } catch (e) {
              print('Error cargando alineación fija: $e');
            }
          }

          _cargando = false;
        });
      }
    } catch (e) {
      print('Error cargando datos: $e');
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _enviarAlineacion() async {
    if (_titularesIds.length != MAX_TITULARES) {
      _showSnack('Debes seleccionar exactamente $MAX_TITULARES titulares', isError: true);
      return;
    }

    if (_equipoId == null) {
      _showSnack('Error: No se pudo identificar tu equipo', isError: true);
      return;
    }

    setState(() => _enviando = true);

    try {

      Map<String, dynamic> _toJugadorPayload(int id, bool titular) {
        final jugador = _plantilla.firstWhere((j) => j.id == id);

        final nombreCompleto = jugador.nombreCompleto.trim();
        final partes = nombreCompleto.split(' ');
        final nombre = partes.isNotEmpty ? partes.first : nombreCompleto;
        final apellido = partes.length > 1 ? partes.sublist(1).join(' ') : '';
        return {
          'jugadorId': id,
          'nombre': nombre,
          'apellido': apellido,
          'dorsal': jugador.dorsal,
          'posicion': jugador.posicion,
          'titular': titular,
        };
      }

      final titulares = _titularesIds.map((id) => _toJugadorPayload(id, true)).toList();
      final suplentes = _suplentesIds.map((id) => _toJugadorPayload(id, false)).toList();

      final data = <String, dynamic>{
        'partidoId': widget.partido.id,
        'equipoId': _equipoId,
        'titulares': titulares,
        'suplentes': suplentes,
        'confirmada': false,
      };

      print(' Enviando alineación: ${jsonEncode(data)}');

      await AlineacionService.presentarAlineacion(data);

      final prefs = await SharedPreferences.getInstance();
      final fijaData = {
        'titulares': _titularesIds.toList(),
        'suplentes': _suplentesIds.toList(),
      };
      await prefs.setString('alineacion_fija_equipo_$_equipoId', jsonEncode(fijaData));
      await prefs.setBool('alineacion_fija_activa_$_equipoId', true);

      if (mounted) {
        setState(() {
          _alineacionEnviada = true;
          _enviando = false;
        });
        _showSnack(' Alineación enviada correctamente', isError: false);

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      print(' Error enviando alineación: $e');
      _showSnack('Error al enviar: $e', isError: true);
      if (mounted) setState(() => _enviando = false);
    }
  }

  Map<String, dynamic> _getJugadorData(int id) {
    final jugador = _plantilla.firstWhere((j) => j.id == id);
    return {
      'jugadorId': id,
      'dorsal': jugador.dorsal,
      'posicion': jugador.posicion,
      'nombre': jugador.nombreCompleto,
    };
  }

  @override
  Widget build(BuildContext context) {
    final miEquipo = widget.esLocal ? widget.partido.nombreLocal : widget.partido.nombreVisitante;
    final rival = widget.esLocal ? widget.partido.nombreVisitante : widget.partido.nombreLocal;

    return Scaffold(
      backgroundColor: AppColors.negro,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(miEquipo, rival),
            if (_alineacionFija && !_alineacionEnviada) _buildAvisoAlineacionFija(),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
                  : _alineacionEnviada
                  ? _buildAlineacionEnviadaView()
                  : _buildFormularioAlineacion(),
            ),
            if (!_alineacionEnviada) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String miEquipo, String rival) {
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
                const Text('Presentar Alineación',
                    style: TextStyle(
                        color: AppColors.blanco,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(
                  '$miEquipo vs $rival${widget.partido.jornada != null ? " · J${widget.partido.jornada}" : ""}',
                  style: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvisoAlineacionFija() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.naranja.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.naranja.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high, color: AppColors.naranja, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Alineación autocompletada desde tu alineación fija.',
              style: TextStyle(color: AppColors.naranja, fontSize: 11),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final eq = AutenticacionService.entrenadorActual?.equipoId;
              if (eq != null) {
                await prefs.setBool('alineacion_fija_activa_$eq', false);
              }
              setState(() {
                _alineacionFija = false;
                _titularesIds.clear();
                _suplentesIds.clear();
              });
            },
            child: const Text('Limpiar',
                style: TextStyle(
                    color: AppColors.naranja,
                    fontSize: 11,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioAlineacion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContadorBadges(),
          const SizedBox(height: 16),
          _buildSeccionJugadores('⭐ Titulares', _plantilla,
              seleccionados: _titularesIds,
              otros: _suplentesIds,
              isTitular: true,
              max: MAX_TITULARES),
          const SizedBox(height: 16),
          _buildSeccionJugadores(' Suplentes', _plantilla,
              seleccionados: _suplentesIds,
              otros: _titularesIds,
              isTitular: false,
              max: MAX_SUPLENTES),
        ],
      ),
    );
  }

  Widget _buildContadorBadges() {
    return Row(
      children: [
        _buildBadge(
          '${_titularesIds.length}/$MAX_TITULARES',
          'Titulares',
          _titularesIds.length == MAX_TITULARES ? Colors.green.shade600 : AppColors.naranja,
        ),
        const SizedBox(width: 12),
        _buildBadge(
          '${_suplentesIds.length}/$MAX_SUPLENTES',
          'Suplentes',
          Colors.blue.shade600,
        ),
      ],
    );
  }

  Widget _buildBadge(String valor, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(valor, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppColors.grisClaro, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionJugadores(
      String titulo,
      List<Jugador> jugadores, {
        required Set<int> seleccionados,
        required Set<int> otros,
        required bool isTitular,
        required int max,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: isTitular ? AppColors.naranja : Colors.blue.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(titulo,
                style: const TextStyle(color: AppColors.blanco, fontSize: 14, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('Máximo $max', style: const TextStyle(color: AppColors.grisClaro, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        ...jugadores.map((j) {
          if (j.id == null) return const SizedBox.shrink();
          final id = j.id!;
          final esteSeleccionado = seleccionados.contains(id);
          final enOtro = otros.contains(id);

          return _buildFilaJugador(
            jugador: j,
            seleccionado: esteSeleccionado,
            deshabilitado: enOtro,
            isTitular: isTitular,
            onTap: enOtro
                ? null
                : () {
              setState(() {
                if (esteSeleccionado) {
                  seleccionados.remove(id);
                } else {
                  if (seleccionados.length < max) {
                    seleccionados.add(id);
                  } else {
                    _showSnack('Máximo $max ${isTitular ? "titulares" : "suplentes"}', isError: true);
                  }
                }
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildFilaJugador({
    required Jugador jugador,
    required bool seleccionado,
    required bool deshabilitado,
    required bool isTitular,
    required VoidCallback? onTap,
  }) {
    final color = isTitular ? AppColors.naranja : Colors.blue.shade600;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withOpacity(0.15)
              : deshabilitado
              ? Colors.white.withOpacity(0.02)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado
                ? color.withOpacity(0.5)
                : deshabilitado
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: seleccionado ? color.withOpacity(0.25) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: seleccionado ? color : AppColors.grisClaro, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '${jugador.dorsal}',
                  style: TextStyle(
                      color: seleccionado ? color : AppColors.grisClaro,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jugador.nombreCompleto,
                    style: TextStyle(
                      color: deshabilitado ? AppColors.grisClaro.withOpacity(0.5) : AppColors.blanco,
                      fontSize: 13,
                      fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    jugador.posicion,
                    style: TextStyle(
                        color: AppColors.grisClaro.withOpacity(deshabilitado ? 0.4 : 0.8),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
            if (deshabilitado)
              Text(
                isTitular ? 'Suplente' : 'Titular',
                style: const TextStyle(color: AppColors.grisClaro, fontSize: 10),
              )
            else
              Icon(
                seleccionado ? Icons.check_circle : Icons.radio_button_unchecked,
                color: seleccionado ? color : AppColors.grisClaro,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlineacionEnviadaView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Alineación enviada',
              style: TextStyle(color: AppColors.blanco, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _confirmadaPorArbitro
                  ? 'El árbitro ya ha confirmado tu alineación.'
                  : 'Tu alineación ha sido enviada correctamente.\nQueda a la espera de confirmación por el árbitro.',
              style: const TextStyle(color: AppColors.grisClaro, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (_confirmadaPorArbitro) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 16),
                    SizedBox(width: 6),
                    Text('Confirmada por árbitro', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _buildResumenAlineacion(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenAlineacion() {
    if (_titularesIds.isEmpty) return const SizedBox.shrink();
    final titulares = _plantilla
        .where((j) => j.id != null && _titularesIds.contains(j.id!))
        .toList();
    final suplentes = _plantilla
        .where((j) => j.id != null && _suplentesIds.contains(j.id!))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Titulares:',
            style: TextStyle(color: AppColors.naranja, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...titulares.map((j) => Text('• ${j.dorsal}. ${j.nombreCompleto}',
            style: const TextStyle(color: AppColors.blanco, fontSize: 12))),
        const SizedBox(height: 8),
        if (suplentes.isNotEmpty) ...[
          const Text('Suplentes:',
              style: TextStyle(color: AppColors.grisClaro, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...suplentes.map((j) => Text('• ${j.dorsal}. ${j.nombreCompleto}',
              style: const TextStyle(color: AppColors.grisClaro, fontSize: 12))),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    final listo = _titularesIds.length == MAX_TITULARES;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: listo ? AppColors.gradienteRojoNaranja : null,
          color: listo ? null : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton.icon(
          onPressed: (listo && !_enviando) ? _enviarAlineacion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: _enviando
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send, color: Colors.white),
          label: Text(
            _enviando
                ? 'Enviando...'
                : listo
                ? 'Enviar Alineación'
                : 'Selecciona ${MAX_TITULARES - _titularesIds.length} titular(es) más',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
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
