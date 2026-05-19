import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/arbitro.dart';
import '../../models/equipo.dart';
import '../../models/partido.dart';
import '../../services/arbitroService.dart';
import '../../services/partidoService.dart';

class CrearPartidoCompletoDialog extends StatefulWidget {
  final List<Equipo> equipos;
  final VoidCallback onPartidoCreado;
  final int? ligaIdInicial;
  final Partido? partidoToEdit;

  const CrearPartidoCompletoDialog({
    super.key,
    required this.equipos,
    required this.onPartidoCreado,
    this.ligaIdInicial,
    this.partidoToEdit,
  });

  @override
  State<CrearPartidoCompletoDialog> createState() =>
      _CrearPartidoCompletoDialogState();
}

class _CrearPartidoCompletoDialogState
    extends State<CrearPartidoCompletoDialog> {
  final _formKey = GlobalKey<FormState>();

  Equipo? _equipoLocal;
  Equipo? _equipoVisitante;
  Arbitro? _arbitro;
  List<Arbitro> _arbitros = [];
  bool _loadingArbitros = true;
  String? _errorArbitros;
  bool _esEdicion = false;

  final TextEditingController _pabellonIdaCtrl = TextEditingController();
  final TextEditingController _ubicacionIdaCtrl = TextEditingController();
  DateTime _fechaIda = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _horaIda = const TimeOfDay(hour: 18, minute: 0);
  int? _jornadaIda;
  int? _ligaId;

  bool _crearVuelta = true;
  final TextEditingController _pabellonVueltaCtrl = TextEditingController();
  DateTime? _fechaVuelta;
  TimeOfDay? _horaVuelta;
  int? _jornadaVuelta;
  int _diferenciaJornadas = 11;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ligaId = widget.ligaIdInicial;
    _cargarArbitros();
    _cargarDatosParaEdicion();
  }

  void _cargarDatosParaEdicion() {
    if (widget.partidoToEdit != null) {
      _esEdicion = true;
      final partido = widget.partidoToEdit!;

      _equipoLocal = widget.equipos.firstWhere(
            (e) => e.nombre == partido.nombreLocal,
        orElse: () => widget.equipos.firstWhere(
              (e) => e.id == partido.equipoLocalId,
          orElse: () => widget.equipos.first,
        ),
      );

      _equipoVisitante = widget.equipos.firstWhere(
            (e) => e.nombre == partido.nombreVisitante,
        orElse: () => widget.equipos.firstWhere(
              (e) => e.id == partido.equipoVisitanteId,
          orElse: () => widget.equipos.first,
        ),
      );

      _pabellonIdaCtrl.text = partido.pabellon;
      _ubicacionIdaCtrl.text = partido.direccionPabellon;
      _jornadaIda = partido.jornada;
      _crearVuelta = false;

      final fechaParseada = Partido.parseFecha(partido.fecha);
      if (fechaParseada != null) {
        _fechaIda = fechaParseada;
      }
      if (partido.hora.isNotEmpty && partido.hora.contains(':')) {
        final hParts = partido.hora.split(':');
        final h = int.tryParse(hParts[0]);
        final m = hParts.length > 1 ? int.tryParse(hParts[1]) : 0;
        if (h != null) {
          _horaIda = TimeOfDay(hour: h, minute: m ?? 0);
        }
      }
    }
  }

  @override
  void dispose() {
    _pabellonIdaCtrl.dispose();
    _ubicacionIdaCtrl.dispose();
    _pabellonVueltaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarArbitros() async {
    setState(() {
      _loadingArbitros = true;
      _errorArbitros = null;
    });

    try {
      List<Arbitro> arbitros = [];

      if (_esEdicion) {
        arbitros = await ArbitroService.listarArbitros();
        debugPrint(' [edición] Árbitros totales cargados: ${arbitros.length}');
      } else {
        try {
          arbitros = await ArbitroService.listarArbitrosDisponibles();
          debugPrint(' Árbitros disponibles cargados: ${arbitros.length}');
        } catch (e) {
          debugPrint(' Error cargando árbitros disponibles: $e');
        }
        if (arbitros.isEmpty) {

          arbitros = await ArbitroService.listarArbitros();
          debugPrint(' Fallback a listado completo: ${arbitros.length}');
        }
      }

      if (mounted) {
        setState(() {
          _arbitros = arbitros;
          _loadingArbitros = false;

          if (_esEdicion &&
              widget.partidoToEdit?.arbitroId != null &&
              _arbitro == null) {
            try {
              _arbitro = _arbitros.firstWhere(
                    (a) => a.id == widget.partidoToEdit!.arbitroId,
              );
            } catch (_) {
              _arbitro = null;
            }
          }
        });
      }
    } catch (e) {
      debugPrint(' Error fatal cargando árbitros: $e');
      if (mounted) {
        setState(() {
          _errorArbitros = 'No se pudieron cargar los árbitros: $e';
          _loadingArbitros = false;
        });
      }
    }
  }

  int? get _ligaEfectiva =>
      _ligaId ?? _equipoLocal?.ligaId ?? _equipoVisitante?.ligaId;

  List<Equipo> get _equiposPermitidos {
    final liga = _ligaEfectiva;
    if (liga == null) return widget.equipos;
    return widget.equipos.where((e) => e.ligaId == liga).toList();
  }

  void _onEquipoLocalChanged(Equipo? equipo) {
    setState(() {
      _equipoLocal = equipo;

      if (equipo != null &&
          _equipoVisitante != null &&
          _equipoVisitante!.ligaId != equipo.ligaId) {
        _equipoVisitante = null;
      }
      if (equipo != null) {
        _pabellonIdaCtrl.text = equipo.nombreEstadio.isNotEmpty
            ? equipo.nombreEstadio
            : '';
        _ubicacionIdaCtrl.text = equipo.ciudad.isNotEmpty
            ? equipo.ciudad
            : '';
      }
      if (_crearVuelta && _equipoVisitante != null) {
        _pabellonVueltaCtrl.text = _equipoVisitante!.nombreEstadio.isNotEmpty
            ? _equipoVisitante!.nombreEstadio
            : '';
      }
    });
  }

  void _onEquipoVisitanteChanged(Equipo? equipo) {
    setState(() {
      _equipoVisitante = equipo;

      if (equipo != null &&
          _equipoLocal != null &&
          _equipoLocal!.ligaId != equipo.ligaId) {
        _equipoLocal = null;
      }
      if (_crearVuelta && equipo != null) {
        _pabellonVueltaCtrl.text = equipo.nombreEstadio.isNotEmpty
            ? equipo.nombreEstadio
            : '';
      }
    });
  }

  void _onToggleVuelta(bool v) {
    setState(() {
      _crearVuelta = v;
      if (v) {
        if (_equipoVisitante != null) {
          _pabellonVueltaCtrl.text = _equipoVisitante!.nombreEstadio.isNotEmpty
              ? _equipoVisitante!.nombreEstadio
              : '';
        }
        _fechaVuelta = _fechaIda.add(Duration(days: _diferenciaJornadas * 7));
        _horaVuelta = _horaIda;
        if (_jornadaIda != null) {
          _jornadaVuelta = (_jornadaIda! + _diferenciaJornadas).clamp(1, 34);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(' Equipos'),
                      _buildEquiposRow(),
                      if (_equipoLocal != null &&
                          _equipoVisitante != null &&
                          _equipoLocal!.id == _equipoVisitante!.id)
                        _buildWarning(
                            'Un equipo no puede jugar contra sí mismo'),
                      const SizedBox(height: 16),
                      _buildSectionLabel(' Árbitro'),
                      _buildArbitroSelector(),
                      const SizedBox(height: 16),
                      _buildPartidoIda(),
                      if (!_esEdicion) ...[
                        const SizedBox(height: 16),
                        _buildSwitchVuelta(),
                        if (_crearVuelta) ...[
                          const SizedBox(height: 12),
                          _buildPartidoVuelta(),
                        ],
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: const BoxDecoration(
        gradient: AppColors.gradienteRojoNaranja,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_basketball, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _esEdicion ? 'Editar Partido' : 'Programar Partido',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.naranja,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquiposRow() {
    return Row(
      children: [
        Expanded(child: _buildEquipoDropdown('Local', _equipoLocal,
            _onEquipoLocalChanged, AppColors.rojoAragon)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const Icon(Icons.compare_arrows, color: AppColors.naranja, size: 28),
              Text(
                'VS',
                style: TextStyle(
                  color: AppColors.naranja,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildEquipoDropdown('Visitante', _equipoVisitante,
            _onEquipoVisitanteChanged, Colors.blue.shade700)),
      ],
    );
  }

  Widget _buildEquipoDropdown(
      String label,
      Equipo? value,
      Function(Equipo?) onChanged,
      Color accentColor,
      ) {

    final permitidos = _equiposPermitidos;

    final dropdownValue = (value != null && permitidos.contains(value))
        ? value
        : null;
    return DropdownButtonFormField<Equipo>(
      value: dropdownValue,
      isExpanded: true,
      dropdownColor: const Color(0xFF2A2A2A),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accentColor, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: const TextStyle(color: AppColors.blanco, fontSize: 13),
      items: permitidos
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(
          e.nombre,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.blanco, fontSize: 13),
        ),
      ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Requerido' : null,
    );
  }

  Widget _buildArbitroSelector() {
    if (_loadingArbitros) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: const Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: AppColors.naranja, strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text('Cargando árbitros...', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      );
    }

    if (_errorArbitros != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorArbitros!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _cargarArbitros,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Reintentar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    if (_arbitros.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No hay árbitros disponibles. Puedes crear el partido sin árbitro y asignarlo después.',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<Arbitro>(
      value: _arbitro,
      isExpanded: true,
      dropdownColor: const Color(0xFF2A2A2A),
      decoration: InputDecoration(
        labelText: 'Asignar Árbitro (opcional)',
        labelStyle: TextStyle(color: AppColors.blanco.withOpacity(0.7), fontSize: 13),
        prefixIcon: const Icon(Icons.sports, color: AppColors.naranja, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.blanco.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.naranja),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: const TextStyle(color: AppColors.blanco, fontSize: 13),
      items: [
        const DropdownMenuItem<Arbitro>(
          value: null,
          child: Text('Sin árbitro asignado',
              style: TextStyle(
                  color: AppColors.grisClaro,
                  fontSize: 13,
                  fontStyle: FontStyle.italic)),
        ),

        ..._arbitros.map((a) => DropdownMenuItem(
          value: a,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.naranja.withOpacity(0.2),
                child: Text(
                  a.iniciales,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.naranja,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.blanco, fontSize: 13),
                    ),
                    if ((a.email ?? '').isNotEmpty)
                      Text(
                        a.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.grisClaro, fontSize: 9, height: 1.1),
                      ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
      selectedItemBuilder: (context) => [
        const Text('Sin árbitro asignado',
            style: TextStyle(
                color: AppColors.grisClaro,
                fontSize: 13,
                fontStyle: FontStyle.italic)),
        ..._arbitros.map((a) => Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.naranja.withOpacity(0.2),
              child: Text(a.iniciales,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.naranja,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(a.nombreCompleto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.blanco, fontSize: 13)),
            ),
          ],
        )),
      ],
      onChanged: (v) => setState(() => _arbitro = v),
    );
  }

  Widget _buildPartidoIda() {
    return _buildPartidoCard(
      titulo: '→ Partido de Ida',
      subtitulo: _equipoLocal != null && _equipoVisitante != null
          ? '${_equipoLocal!.nombre} vs ${_equipoVisitante!.nombre}'
          : 'Local vs Visitante',
      color: AppColors.rojoAragon,
      children: [
        _buildJornadaDropdown(
          label: 'Jornada',
          value: _jornadaIda,
          onChanged: (v) {
            setState(() {
              _jornadaIda = v;
              if (_crearVuelta && v != null) {
                _jornadaVuelta = (v + _diferenciaJornadas).clamp(1, 34);
              }
            });
          },
        ),
        const SizedBox(height: 12),
        _buildFechaHoraRow(
          fecha: _fechaIda,
          hora: _horaIda,
          onFecha: (d) {
            setState(() {
              _fechaIda = d;
              if (_crearVuelta) {
                _fechaVuelta = d.add(Duration(days: _diferenciaJornadas * 7));
              }
            });
          },
          onHora: (h) => setState(() {
            _horaIda = h;
            if (_crearVuelta) _horaVuelta = h;
          }),
        ),
        const SizedBox(height: 12),
        _buildCampoTexto(
          controller: _pabellonIdaCtrl,
          label: 'Pabellón',
          icono: Icons.stadium,
          hint: 'Autocompletado por equipo local',
        ),
        const SizedBox(height: 8),
        _buildCampoTexto(
          controller: _ubicacionIdaCtrl,
          label: 'Dirección / Ciudad',
          icono: Icons.location_on_outlined,
          hint: 'Ej: C/ Mayor 1, Zaragoza',
        ),
      ],
    );
  }

  Widget _buildSwitchVuelta() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        title: const Text(
          'Crear partido de vuelta',
          style: TextStyle(
              color: AppColors.blanco,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _crearVuelta
              ? 'Se crearán ambos partidos: ${_equipoLocal?.nombre ?? "Local"} en casa y fuera'
              : 'Solo se creará el partido de ida',
          style: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
        ),
        value: _crearVuelta,
        activeColor: AppColors.naranja,
        onChanged: _onToggleVuelta,
      ),
    );
  }

  Widget _buildPartidoVuelta() {
    final fechaVuelta =
        _fechaVuelta ?? _fechaIda.add(Duration(days: _diferenciaJornadas * 7));
    final horaVuelta = _horaVuelta ?? _horaIda;

    return _buildPartidoCard(
      titulo: '← Partido de Vuelta',
      subtitulo: _equipoLocal != null && _equipoVisitante != null
          ? '${_equipoVisitante!.nombre} vs ${_equipoLocal!.nombre}'
          : 'Visitante vs Local (intercambiados)',
      color: Colors.blue.shade700,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _diferenciaJornadas,
                dropdownColor: const Color(0xFF2A2A2A),
                decoration: _inputDecoration('Diferencia jornadas',
                    Icons.swap_horiz),
                style: const TextStyle(
                    color: AppColors.blanco, fontSize: 13),
                items: List.generate(
                    14,
                        (i) => DropdownMenuItem(
                      value: i + 8,
                      child: Text(
                        '${i + 8} jornadas después',
                        style: const TextStyle(color: AppColors.blanco),
                      ),
                    )),
                onChanged: (v) {
                  setState(() {
                    _diferenciaJornadas = v!;
                    _fechaVuelta =
                        _fechaIda.add(Duration(days: _diferenciaJornadas * 7));
                    if (_jornadaIda != null) {
                      _jornadaVuelta =
                          (_jornadaIda! + _diferenciaJornadas).clamp(1, 34);
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildJornadaDropdown(
                label: 'Jornada Vuelta',
                value: _jornadaVuelta,
                onChanged: (v) => setState(() => _jornadaVuelta = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFechaHoraRow(
          fecha: fechaVuelta,
          hora: horaVuelta,
          onFecha: (d) => setState(() => _fechaVuelta = d),
          onHora: (h) => setState(() => _horaVuelta = h),
        ),
        const SizedBox(height: 12),
        _buildCampoTexto(
          controller: _pabellonVueltaCtrl,
          label: 'Pabellón Visitante',
          icono: Icons.stadium,
          hint: _equipoVisitante != null
              ? _equipoVisitante!.nombreEstadio
              : 'Autocompletado por eq. visitante',
        ),
        if (_equipoVisitante != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.naranja, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'El partido de vuelta es ${_equipoVisitante!.nombre} vs ${_equipoLocal?.nombre ?? "Local"} '
                        '(roles invertidos automáticamente)',
                    style: const TextStyle(
                        color: AppColors.grisClaro, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grisClaro,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _isLoading
                    ? null
                    : AppColors.gradienteRojoNaranja,
                color: _isLoading ? Colors.grey.shade700 : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _crearPartidos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 18),
                label: Text(
                  _isLoading
                      ? 'Creando...'
                      : _esEdicion
                      ? 'Actualizar Partido'
                      : _crearVuelta
                      ? 'Crear Ida + Vuelta'
                      : 'Crear Partido',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartidoCard({
    required String titulo,
    required String subtitulo,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Text(subtitulo,
                      style: const TextStyle(
                          color: AppColors.grisClaro, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildJornadaDropdown({
    required String label,
    required int? value,
    required Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: const Color(0xFF2A2A2A),
      decoration: _inputDecoration(label, Icons.format_list_numbered),
      style: const TextStyle(color: AppColors.blanco, fontSize: 13),
      items: List.generate(
          34,
              (i) => DropdownMenuItem(
            value: i + 1,
            child: Text('Jornada ${i + 1}',
                style: const TextStyle(color: AppColors.blanco)),
          )),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Selecciona jornada' : null,
    );
  }

  Widget _buildFechaHoraRow({
    required DateTime fecha,
    required TimeOfDay hora,
    required Function(DateTime) onFecha,
    required Function(TimeOfDay) onHora,
  }) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: fecha,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 730)),
                builder: (context, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.naranja,
                      surface: Color(0xFF2A2A2A),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (d != null) onFecha(d);
            },
            child: _buildChip(
              icono: Icons.calendar_today,
              texto: DateFormat('dd/MM/yyyy').format(fecha),
              color: AppColors.naranja,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final h = await showTimePicker(
                context: context,
                initialTime: hora,
                builder: (context, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.naranja,
                      surface: Color(0xFF2A2A2A),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (h != null) onHora(h);
            },
            child: _buildChip(
              icono: Icons.access_time,
              texto: hora.format(context),
              color: AppColors.naranja,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
      {required IconData icono, required String texto, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.blanco, fontSize: 13),
      decoration: _inputDecoration(label, icono).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle:
      TextStyle(color: AppColors.blanco.withOpacity(0.7), fontSize: 13),
      prefixIcon: Icon(icono, color: AppColors.naranja, size: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.naranja),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildWarning(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orangeAccent, size: 16),
          const SizedBox(width: 6),
          Text(texto,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _crearPartidos() async {
    if (!_formKey.currentState!.validate()) return;
    if (_equipoLocal?.id == _equipoVisitante?.id) {
      _showSnack('Un equipo no puede jugar contra sí mismo', isError: true);
      return;
    }

    if (_equipoLocal != null &&
        _equipoVisitante != null &&
        _equipoLocal!.ligaId != _equipoVisitante!.ligaId) {
      _showSnack('Los equipos deben pertenecer a la misma liga',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_esEdicion && widget.partidoToEdit != null) {

        final fechaHora = DateTime(
          _fechaIda.year, _fechaIda.month, _fechaIda.day,
          _horaIda.hour, _horaIda.minute,
        );

        final updateData = <String, dynamic>{
          'equipoLocalId': _equipoLocal!.id,
          'equipoVisitanteId': _equipoVisitante!.id,
          'fecha': fechaHora.toIso8601String(),
          'pabellon': _pabellonIdaCtrl.text.trim(),
          'ubicacion': _ubicacionIdaCtrl.text.trim(),
          'jornada': _jornadaIda,
          'ligaId': _ligaEfectiva,
        };
        if (_arbitro != null) {
          updateData['arbitroId'] = _arbitro!.id;
        }

        await PartidoService.actualizarPartido(
          widget.partidoToEdit!.id,
          updateData,
        );

        _showSnack(' Partido actualizado correctamente', isError: false);
      } else {

        final fechaHoraIda = DateTime(
          _fechaIda.year, _fechaIda.month, _fechaIda.day,
          _horaIda.hour, _horaIda.minute,
        );

        final data = <String, dynamic>{
          'equipoLocalId': _equipoLocal!.id,
          'equipoVisitanteId': _equipoVisitante!.id,
          'fechaIda': fechaHoraIda.toIso8601String(),
          'pabellonIda': _pabellonIdaCtrl.text.trim(),
          'ubicacionIda': _ubicacionIdaCtrl.text.trim(),
          'jornadaIda': _jornadaIda,
          'ligaId': _ligaEfectiva,
          'crearVuelta': _crearVuelta,
        };

        if (_arbitro != null) {
          data['arbitroId'] = _arbitro!.id;
        }

        if (_crearVuelta) {
          final fv = _fechaVuelta ??
              _fechaIda.add(Duration(days: _diferenciaJornadas * 7));
          final hv = _horaVuelta ?? _horaIda;
          final fechaHoraVuelta = DateTime(
            fv.year, fv.month, fv.day,
            hv.hour, hv.minute,
          );

          data['fechaVuelta'] = fechaHoraVuelta.toIso8601String();
          data['jornadaVuelta'] = _jornadaVuelta ??
              (_jornadaIda! + _diferenciaJornadas).clamp(1, 34);
          data['pabellonVuelta'] = _pabellonVueltaCtrl.text.trim().isNotEmpty
              ? _pabellonVueltaCtrl.text.trim()
              : _equipoVisitante?.nombreEstadio ?? '';
        }

        await PartidoService.crearPartidosConJornadas(data);

        _showSnack(
          _crearVuelta
              ? ' Partidos de ida y vuelta programados'
              : ' Partido programado correctamente',
          isError: false,
        );
      }

      widget.onPartidoCreado();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
