// lib/screens/Admin/GestionPartidosPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/partido.dart';

import '../../services/equipoService.dart';
import '../../services/PartidoService.dart';


class GestionPartidosPage extends StatefulWidget {
  const GestionPartidosPage({super.key});

  @override
  State<GestionPartidosPage> createState() => _GestionPartidosPageState();
}

class _GestionPartidosPageState extends State<GestionPartidosPage> {
  List<Partido> _partidos = [];
  List<Map<String, dynamic>> _equipos = [];
  bool _isLoading = true;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  int? _equipoLocalId;
  int? _equipoVisitanteId;
  DateTime _fechaPartido = DateTime.now();
  TimeOfDay _horaPartido = TimeOfDay.now();
  String _ubicacion = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final partidos = await PartidoService.listarPartidos();
      final equipos = await EquipoService.listarEquipos();

      setState(() {
        _partidos = partidos;
        _equipos = equipos.map((e) => {'id': e.id, 'nombre': e.nombre}).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _crearPartido() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final nuevoPartido = await PartidoService.crearPartido({
        'id_local': _equipoLocalId,
        'id_visitante': _equipoVisitanteId,
        'fecha': DateTime(
          _fechaPartido.year,
          _fechaPartido.month,
          _fechaPartido.day,
          _horaPartido.hour,
          _horaPartido.minute,
        ).toIso8601String(),
        'pabellon': _ubicacion,
      });

      if (nuevoPartido != null) {
        _limpiarFormulario();
        await _cargarDatos();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Partido creado exitosamente'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        _mostrarError('Error al crear el partido');
      }
    } catch (e) {
      _mostrarError('Error al crear partido: $e');
    }
  }

  Future<void> _actualizarResultado(Partido partido) async {
    final resultadoLocalCtrl = TextEditingController(text: partido.puntosLocal.toString());
    final resultadoVisitanteCtrl = TextEditingController(text: partido.puntosVisitante.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Resultado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: resultadoLocalCtrl,
              decoration: const InputDecoration(labelText: 'Resultado Local'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: resultadoVisitanteCtrl,
              decoration: const InputDecoration(labelText: 'Resultado Visitante'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await PartidoService.actualizarResultado(
                int.tryParse(partido.id) ?? 0,
                {
                  'puntosLocal': int.tryParse(resultadoLocalCtrl.text),
                  'puntosVisitante': int.tryParse(resultadoVisitanteCtrl.text),
                },
              );

              if (success) {
                Navigator.pop(context);
                await _cargarDatos();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarPartido(Partido partido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar el partido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar == true) {
      final success = await PartidoService.eliminarPartido(
        int.tryParse(partido.id) ?? 0,
      );
      if (success) {
        await _cargarDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Partido eliminado'), backgroundColor: Colors.green),
          );
        }
      } else {
        _mostrarError('Error al eliminar el partido');
      }
    }
  }

  void _mostrarDialogoCrear() {
    _limpiarFormulario();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Programar Nuevo Partido'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _equipoLocalId,
                  decoration: const InputDecoration(labelText: 'Equipo Local'),
                  items: _equipos.map<DropdownMenuItem<int>>((e) {  // ← Especificar el tipo genérico
                    return DropdownMenuItem<int>(
                      value: e['id'] as int,  // ← Asegurar tipo int
                      child: Text(e['nombre']),
                    );
                  }).toList(),
                  onChanged: (v) => _equipoLocalId = v,
                  validator: (v) => v == null ? 'Requerido' : null,
                ),

                DropdownButtonFormField<int>(
                  value: _equipoVisitanteId,
                  decoration: const InputDecoration(labelText: 'Equipo Visitante'),
                  items: _equipos.map<DropdownMenuItem<int>>((e) {  // ← Especificar el tipo genérico
                    return DropdownMenuItem<int>(
                      value: e['id'] as int,  // ← Asegurar tipo int
                      child: Text(e['nombre']),
                    );
                  }).toList(),
                  onChanged: (v) => _equipoVisitanteId = v,
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(_fechaPartido.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _fechaPartido,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _fechaPartido = date);
                  },
                ),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text(_horaPartido.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: _horaPartido);
                    if (time != null) setState(() => _horaPartido = time);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                  onChanged: (v) => _ubicacion = v,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: _crearPartido, style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja), child: const Text('Programar')),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _equipoLocalId = null;
    _equipoVisitanteId = null;
    _fechaPartido = DateTime.now();
    _horaPartido = TimeOfDay.now();
    _ubicacion = '';
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gestión de Partidos', style: TextStyle(color: AppColors.blanco, fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Programar Partido'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                onPressed: _mostrarDialogoCrear,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : ListView.builder(
              itemCount: _partidos.length,
              itemBuilder: (context, index) {
                final partido = _partidos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.sports_basketball, color: AppColors.naranja),
                    title: Text('${partido.nombreLocal} vs ${partido.nombreVisitante}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📅 ${partido.fecha ?? '-'}'),
                        Text('📍 ${partido.pabellon ?? 'Sin ubicación'}'),
                        Text('🏀 Resultado: ${partido.puntosLocal} - ${partido.puntosVisitante}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _actualizarResultado(partido),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarPartido(partido),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}