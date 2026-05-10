import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/common/resources/colores.dart';
import 'EventoPartido.dart';

class EventoForm extends StatefulWidget {
  final List<Map<String, dynamic>> equipos;
  final Function(EventoPartido) onGuardar;

  const EventoForm({
    super.key,
    required this.equipos,
    required this.onGuardar,
  });

  @override
  State<EventoForm> createState() => _EventoFormState();
}

class _EventoFormState extends State<EventoForm> {
  final _formKey = GlobalKey<FormState>();

  String? _equipoSeleccionado;
  Map<String, dynamic>? _jugadorSeleccionado;
  String? _tipoEvento;
  String? _minuto;
  String? _descripcion;

  final List<String> _tiposEvento = [
    'CANASTA',
    'TIRO_3PUNTOS',
    'TIRO_LIBRE',
    'FALTA',
    'TECNICA',
    'EXPULSION',
  ];

  final Map<String, String> _tiposDisplay = {
    'CANASTA': ' Canasta (2 puntos)',
    'TIRO_3PUNTOS': '3 Triple (3 puntos)',
    'TIRO_LIBRE': '⬜ Tiro Libre (1 punto)',
    'FALTA': ' Falta',
    'TECNICA': ' Falta Técnica',
    'EXPULSION': ' Expulsión',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Agregar Evento',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Equipo',
                  border: OutlineInputBorder(),
                ),
                value: _equipoSeleccionado,
                items: widget.equipos.map<DropdownMenuItem<String>>((equipo) {
                  return DropdownMenuItem<String>(
                    value: equipo['nombre'] as String,
                    child: Text(equipo['nombre'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _equipoSeleccionado = value;
                    _jugadorSeleccionado = null;
                  });
                },
                validator: (v) => v == null ? 'Selecciona un equipo' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: const InputDecoration(
                  labelText: 'Jugador',
                  border: OutlineInputBorder(),
                ),
                value: _jugadorSeleccionado,
                items: _equipoSeleccionado != null
                    ? (widget.equipos
                    .firstWhere((e) => e['nombre'] == _equipoSeleccionado)['jugadores'] as List)
                    .map<DropdownMenuItem<Map<String, dynamic>>>((jugador) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: jugador,
                    child: Text('${jugador['dorsal']} - ${jugador['nombreCompleto']}'),
                  );
                }).toList()
                    : [],
                onChanged: (value) {
                  setState(() {
                    _jugadorSeleccionado = value;
                  });
                },
                validator: (v) => v == null ? 'Selecciona un jugador' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Evento',
                  border: OutlineInputBorder(),
                ),
                value: _tipoEvento,
                items: _tiposEvento.map<DropdownMenuItem<String>>((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(_tiposDisplay[tipo] ?? tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoEvento = value;
                  });
                },
                validator: (v) => v == null ? 'Selecciona un tipo de evento' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Minuto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _minuto = value,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) return 'Número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => _descripcion = value,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                    ),
                    onPressed: _agregarEvento,
                    child: const Text('Agregar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _agregarEvento() {
    if (_formKey.currentState!.validate()) {
      final evento = EventoPartido(
        id: null,
        jugadorId: _jugadorSeleccionado!['jugadorId'],
        nombreJugador: _jugadorSeleccionado!['nombreCompleto'],
        nombreEquipo: _equipoSeleccionado!,
        minuto: int.parse(_minuto!),
        tipo: _tipoEvento!,
        descripcion: _descripcion,
        puntos: _calcularPuntos(),
      );
      widget.onGuardar(evento);
    }
  }

  int? _calcularPuntos() {
    switch (_tipoEvento) {
      case 'CANASTA':
        return 2;
      case 'TIRO_3PUNTOS':
        return 3;
      case 'TIRO_LIBRE':
        return 1;
      default:
        return null;
    }
  }
}
