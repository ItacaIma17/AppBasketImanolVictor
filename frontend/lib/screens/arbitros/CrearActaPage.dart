import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/EventoForm.dart';
import '../../models/EventoPartido.dart';
import '../../models/partido.dart';
import '../../services/actaService.dart';
import '../../services/arbitroService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class CrearActaPage extends StatefulWidget {
  final Partido partido;

  const CrearActaPage({super.key, required this.partido});

  @override
  State<CrearActaPage> createState() => _CrearActaPageState();
}

class _CrearActaPageState extends State<CrearActaPage> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesController = TextEditingController();
  final _resultadoLocalCtrl = TextEditingController();
  final _resultadoVisitanteCtrl = TextEditingController();

  List<EventoPartido> _eventos = [];
  bool _isLoading = false;
  bool _cargandoAlineaciones = true;

  bool _alineacionesConfirmadas = false;
  bool _verificandoAlineaciones = true;

  Map<String, dynamic>? _alineaciones;
  List<Map<String, dynamic>> _jugadoresLocal = [];
  List<Map<String, dynamic>> _jugadoresVisitante = [];

  @override
  void initState() {
    super.initState();
    _verificarAlineaciones();
    _cargarAlineaciones();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _resultadoLocalCtrl.dispose();
    _resultadoVisitanteCtrl.dispose();
    super.dispose();
  }

  Future<void> _verificarAlineaciones() async {
    final estado = await ArbitroService.estadoAlineaciones(widget.partido.id);
    if (mounted) {
      setState(() {
        _alineacionesConfirmadas = estado['ambasConfirmadas'] == true;
        _verificandoAlineaciones = false;
      });
    }
  }

  Future<void> _cargarAlineaciones() async {
    setState(() => _cargandoAlineaciones = true);

    try {
      final alineaciones = await ArbitroService.getAlineacionesParaActa(
        widget.partido.id,
      );

      List<Map<String, dynamic>> _extraerJugadores(dynamic alineacion) {
        if (alineacion is! Map) return [];
        final raw = (alineacion['jugadores'] as List?) ?? const [];
        return raw
            .whereType<Map>()
            .map<Map<String, dynamic>>((m) => Map<String, dynamic>.from(m))
            .toList();
      }

      if (mounted) {
        setState(() {
          _alineaciones = alineaciones;
          _jugadoresLocal
            ..clear()
            ..addAll(_extraerJugadores(alineaciones['alineacionLocal']));
          _jugadoresVisitante
            ..clear()
            ..addAll(_extraerJugadores(alineaciones['alineacionVisitante']));
          _cargandoAlineaciones = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoAlineaciones = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando alineaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _agregarEvento() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EventoForm(
        equipos: [
          {
            'nombre': widget.partido.nombreLocal,
            'jugadores': _jugadoresLocal,
          },
          {
            'nombre': widget.partido.nombreVisitante,
            'jugadores': _jugadoresVisitante,
          },
        ],
        onGuardar: (evento) {
          setState(() => _eventos.add(evento));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _eliminarEvento(int index) {
    setState(() => _eventos.removeAt(index));
  }

  Future<void> _guardarActa() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final resLocal = int.tryParse(_resultadoLocalCtrl.text.trim());
    final resVisitante = int.tryParse(_resultadoVisitanteCtrl.text.trim());

    if (resLocal == null || resVisitante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un resultado numérico válido para ambos equipos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final actaData = {
        'partidoId': widget.partido.id,
        'resultadoLocal': resLocal,
        'resultadoVisitante': resVisitante,
        'observaciones': _observacionesController.text,
        'eventos': _eventos
            .map((e) => {
          'jugadorId': e.jugadorId,
          'nombreJugador': e.nombreJugador,
          'nombreEquipo': e.nombreEquipo,
          'minuto': e.minuto,
          'tipo': e.tipo,
          'descripcion': e.descripcion,
        })
            .toList(),
      };

      await ActaService.guardarActa(actaData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Acta guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Crear Acta"),
      body: SafeArea(
          child: _verificandoAlineaciones

              ? const Center(
            child: CircularProgressIndicator(color: AppColors.amarilloAragon),
          )

              : !_alineacionesConfirmadas
              ? _buildActaBloqueada()

              : _isLoading || _cargandoAlineaciones
              ? const Center(
            child: CircularProgressIndicator(
                color: AppColors.amarilloAragon),
          )
              : Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _buildInfoPartido(),
                        const SizedBox(height: 16),
                        _buildResultadoForm(),
                        const SizedBox(height: 16),
                        _buildEventosSection(),
                        const SizedBox(height: 16),
                        _buildObservacionesForm(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildBotonGuardar(),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildActaBloqueada() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_clock,
              size: 80,
              color: AppColors.amarilloAragon,
            ),
            const SizedBox(height: 20),
            const Text(
              'Acta bloqueada',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.blanco,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1 ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          'Ambos entrenadores deben haber subido sus alineaciones.',
                          style: TextStyle(
                              color: AppColors.grisClaro, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2 ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          'Debes confirmar las alineaciones desde la pantalla "Confirmar Alineaciones".',
                          style: TextStyle(
                              color: AppColors.grisClaro, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _verificandoAlineaciones = true);
                _verificarAlineaciones();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh, color: AppColors.blanco),
              label: const Text(
                'Verificar de nuevo',
                style: TextStyle(
                    color: AppColors.blanco, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPartido() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${widget.partido.nombreLocal} vs ${widget.partido.nombreVisitante}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.partido.fecha}  ·  ${widget.partido.hora}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              widget.partido.pabellon.isNotEmpty
                  ? widget.partido.pabellon
                  : 'Sin ubicación',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado del Partido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('acta_resultado_local'),
                    controller: _resultadoLocalCtrl,
                    autofillHints: const [],
                    decoration: InputDecoration(
                      labelText: widget.partido.nombreLocal,
                      border: const OutlineInputBorder(),
                      suffixText: 'pts',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Requerido' : null,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('-', style: TextStyle(fontSize: 24)),
                ),
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('acta_resultado_visitante'),
                    controller: _resultadoVisitanteCtrl,
                    autofillHints: const [],
                    decoration: InputDecoration(
                      labelText: widget.partido.nombreVisitante,
                      border: const OutlineInputBorder(),
                      suffixText: 'pts',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Eventos del Partido',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _agregarEvento,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_eventos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No hay eventos registrados')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _eventos.length,
                itemBuilder: (context, index) =>
                    _buildEventoCard(_eventos[index], index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventoCard(EventoPartido evento, int index) {
    final Color color;
    final String icono;

    switch (evento.tipo) {
      case 'CANASTA':
        color = Colors.green;
        icono = '';
        break;
      case 'TIRO_LIBRE':
        color = Colors.green;
        icono = '⬜';
        break;
      case 'TIRO_3PUNTOS':
        color = Colors.green;
        icono = '3';
        break;
      case 'FALTA':
        color = Colors.orange;
        icono = '';
        break;
      case 'TECNICA':
        color = Colors.orange;
        icono = '';
        break;
      case 'EXPULSION':
        color = Colors.red;
        icono = '';
        break;
      default:
        color = Colors.blue;
        icono = '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(icono, style: const TextStyle(fontSize: 20)),
        ),
        title: Text('${evento.nombreJugador} · ${evento.nombreEquipo}'),
        subtitle: Text(
            'Min. ${evento.minuto}: ${evento.descripcion ?? evento.tipo}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _eliminarEvento(index),
        ),
      ),
    );
  }

  Widget _buildObservacionesForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Observaciones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const ValueKey('acta_observaciones'),
              controller: _observacionesController,
              autofillHints: const [],
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Incidencias, expulsiones, lesiones, etc.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonGuardar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isLoading ? null : _guardarActa,
          child: _isLoading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          )
              : const Text(
            'Guardar Acta',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
