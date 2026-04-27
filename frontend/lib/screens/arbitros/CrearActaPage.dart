// lib/screens/Arbitro/CrearActaPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _resultadoLocal = '';
  String _resultadoVisitante = '';
  List<EventoPartido> _eventos = [];
  bool _isLoading = false;
  bool _cargandoAlineaciones = true;

  Map<String, dynamic>? _alineaciones;
  List<Map<String, dynamic>> _jugadoresLocal = [];
  List<Map<String, dynamic>> _jugadoresVisitante = [];

  @override
  void initState() {
    super.initState();
    _cargarAlineaciones();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarAlineaciones() async {
    setState(() {
      _cargandoAlineaciones = true;
    });

    try {
      // Usar el ArbitroService correctamente
      final alineaciones = await ArbitroService.getAlineacionesPartido(
        widget.partido.id,
      );
      setState(() {
        _alineaciones = alineaciones;

        // Procesar jugadores locales
        if (alineaciones['alineacionLocal'] != null) {
          final local = alineaciones['alineacionLocal'];
          _jugadoresLocal.clear();
          _jugadoresLocal.addAll([
            ...(local['titulares'] as List)
                .map((j) => Map<String, dynamic>.from(j)),
            ...(local['suplentes'] as List)
                .map((j) => Map<String, dynamic>.from(j)),
          ]);
        }

        // Procesar jugadores visitantes
        if (alineaciones['alineacionVisitante'] != null) {
          final visitante = alineaciones['alineacionVisitante'];
          _jugadoresVisitante.clear();
          _jugadoresVisitante.addAll([
            ...(visitante['titulares'] as List)
                .map((j) => Map<String, dynamic>.from(j)),
            ...(visitante['suplentes'] as List)
                .map((j) => Map<String, dynamic>.from(j)),
          ]);
        }

        _cargandoAlineaciones = false;
      });
    } catch (e) {
      setState(() {
        _cargandoAlineaciones = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando alineaciones: $e'), backgroundColor: Colors.red),
      );
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
          {'nombre': widget.partido.nombreLocal, 'jugadores': _jugadoresLocal},
          {'nombre': widget.partido.nombreVisitante, 'jugadores': _jugadoresVisitante},
        ],
        onGuardar: (evento) {
          setState(() {
            _eventos.add(evento);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _eliminarEvento(int index) {
    setState(() {
      _eventos.removeAt(index);
    });
  }

  Future<void> _guardarActa() async {
    if (!_formKey.currentState!.validate()) return;

    if (_resultadoLocal.isEmpty || _resultadoVisitante.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el resultado del partido'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final actaData = {
        'partidoId': widget.partido.id,
        'resultadoLocal': _resultadoLocal,
        'resultadoVisitante': _resultadoVisitante,
        'observaciones': _observacionesController.text,
        'eventos': _eventos.map((e) => {
          'jugadorId': e.jugadorId,
          'nombreJugador': e.nombreJugador,
          'nombreEquipo': e.nombreEquipo,
          'minuto': e.minuto,
          'tipo': e.tipo,
          'descripcion': e.descripcion,
        }).toList(),
      };

      await ActaService.guardarActa(actaData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Acta guardada exitosamente'), backgroundColor: Colors.green),
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
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Crear Acta"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: _isLoading || _cargandoAlineaciones
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.partido.fecha} ${widget.partido.hora}',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 4),
            Text(
              widget.partido.direccionPabellon ?? 'Sin ubicación',
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
                    decoration: InputDecoration(
                      labelText: widget.partido.nombreLocal,
                      border: const OutlineInputBorder(),
                      suffixText: 'pts',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _resultadoLocal = value,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 16),
                const Text('-', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: widget.partido.nombreVisitante,
                      border: const OutlineInputBorder(),
                      suffixText: 'pts',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _resultadoVisitante = value,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
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
                  label: const Text('Agregar Evento'),
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
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No hay eventos registrados'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _eventos.length,
                itemBuilder: (context, index) {
                  final evento = _eventos[index];
                  return _buildEventoCard(evento, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventoCard(EventoPartido evento, int index) {
    Color color;
    switch (evento.tipo) {
      case 'CANASTA':
      case 'TIRO_LIBRE':
      case 'TIRO_3PUNTOS':
        color = Colors.green;
        break;
      case 'FALTA':
      case 'TECNICA':
        color = Colors.orange;
        break;
      case 'EXPULSION':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    String icono;
    switch (evento.tipo) {
      case 'CANASTA':
        icono = '🏀';
        break;
      case 'TIRO_LIBRE':
        icono = '⬜';
        break;
      case 'TIRO_3PUNTOS':
        icono = '3️⃣';
        break;
      case 'FALTA':
        icono = '⚠️';
        break;
      case 'TECNICA':
        icono = '📋';
        break;
      case 'EXPULSION':
        icono = '🚫';
        break;
      default:
        icono = '📌';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(icono, style: const TextStyle(fontSize: 20)),
        ),
        title: Text('${evento.nombreJugador} - ${evento.nombreEquipo}'),
        subtitle: Text('Minuto ${evento.minuto}: ${evento.descripcion ?? evento.tipo}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
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
              controller: _observacionesController,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _guardarActa,
          child: const Text('Guardar Acta', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}