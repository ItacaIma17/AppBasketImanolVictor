// lib/screens/Admin/GestionEquiposPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

import '../../models/equipo.dart';
import '../../models/liga.dart';
import '../../services/equipoService.dart';
import '../Liga/LigaService.dart';


class GestionEquiposPage extends StatefulWidget {
  const GestionEquiposPage({super.key});

  @override
  State<GestionEquiposPage> createState() => _GestionEquiposPageState();
}

class _GestionEquiposPageState extends State<GestionEquiposPage> {
  List<Equipo> _equipos = [];
  List<Map<String, dynamic>> _ligas = [];
  bool _isLoading = true;
  String? _error;

  String _filtroNombre = '';
  int? _filtroLigaId;

  List<Equipo> get _equiposFiltrados {
    return _equipos.where((equipo) {
      final coincideNombre = _filtroNombre.isEmpty ||
          equipo.nombre.toLowerCase().contains(_filtroNombre.toLowerCase());
      final coincideLiga = _filtroLigaId == null || equipo.ligaId == _filtroLigaId;
      return coincideNombre && coincideLiga;
    }).toList();
  }

  // Controladores para el formulario
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _estadioController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _anoController = TextEditingController();
  final _escudoUrlController = TextEditingController();
  int? _ligaIdSeleccionada;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _estadioController.dispose();
    _ciudadController.dispose();
    _anoController.dispose();
    _escudoUrlController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final equipos = await EquipoService.listarEquipos();
      final ligas = await LigaService.listarLigas();

      setState(() {
        _equipos = equipos;
        _ligas = ligas.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _crearEquipo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ligaIdSeleccionada == null) {
      _mostrarError('Selecciona una liga');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // En el frontend, asegurar que el año no sea null
      final equipoData = {
        'nombre': _nombreController.text.trim(),
        'ciudad': _ciudadController.text.trim(),
        'nombreEstadio': _estadioController.text.trim(),
        'anoFundacion': int.tryParse(_anoController.text.trim()) ?? 0,  // ← Valor por defecto 0 si es null
        'escudoUrl': _escudoUrlController.text.trim().isEmpty ? null : _escudoUrlController.text.trim(),
        'ligaId': _ligaIdSeleccionada,
      };

      print('📝 Datos del equipo a enviar: $equipoData');

      await EquipoService.crearEquipo(equipoData);

      _limpiarFormulario();
      await _cargarDatos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Equipo creado exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Cerrar diálogo
      }
    } catch (e) {
      print('❌ Error creando equipo: $e');
      _mostrarError('Error al crear equipo: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _actualizarEquipo(Equipo equipo) async {
    _nombreController.text = equipo.nombre;
    _estadioController.text = equipo.nombreEstadio;
    _ciudadController.text = equipo.ciudad;
    _anoController.text = equipo.anoFundacion.toString();
    _escudoUrlController.text = equipo.escudoUrl ?? '';
    _ligaIdSeleccionada = equipo.ligaId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Equipo'),
        content: _buildFormularioEquipo(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final equipoActualizado = Equipo(
                    id: equipo.id,
                    nombre: _nombreController.text,
                    nombreEstadio: _estadioController.text,
                    ciudad: _ciudadController.text,
                    anoFundacion: int.parse(_anoController.text),
                    escudoUrl: _escudoUrlController.text.isNotEmpty ? _escudoUrlController.text : null,
              ligaId: _ligaIdSeleccionada,
              );
              await EquipoService.actualizarEquipo(equipo.id!, equipoActualizado as Map<String, dynamic>);
              Navigator.pop(context);
              await _cargarDatos();

              if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Equipo actualizado'), backgroundColor: Colors.green),
              );
              }
              } catch (e) {
              _mostrarError('Error al actualizar: $e');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // lib/screens/Admin/GestionEquiposPage.dart - Añadir método de edición

  // lib/screens/Admin/GestionEquiposPage.dart

  void _mostrarDialogoEditar(Equipo equipo) {
    final nombreCtrl = TextEditingController(text: equipo.nombre);
    final ciudadCtrl = TextEditingController(text: equipo.ciudad);
    final estadioCtrl = TextEditingController(text: equipo.nombreEstadio);
    final anoCtrl = TextEditingController(text: equipo.anoFundacion?.toString() ?? '');
    final escudoCtrl = TextEditingController(text: equipo.escudoUrl ?? '');
    int? ligaIdSeleccionada = equipo.ligaId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Editar Equipo: ${equipo.nombre}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del equipo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ciudadCtrl,
                    decoration: const InputDecoration(labelText: 'Ciudad'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: estadioCtrl,
                    decoration: const InputDecoration(labelText: 'Estadio'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: anoCtrl,
                    decoration: const InputDecoration(labelText: 'Año de fundación'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Liga>>(
                    future: LigaService.listarLigas(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final ligas = snapshot.data!;
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Liga'),
                        value: ligaIdSeleccionada,
                        items: ligas.map((liga) {
                          return DropdownMenuItem(
                            value: liga.id,
                            child: Text(liga.nombreLiga),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            ligaIdSeleccionada = value;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final equipoData = {
                    'nombre': nombreCtrl.text.trim(),
                    'ciudad': ciudadCtrl.text.trim(),
                    'nombreEstadio': estadioCtrl.text.trim(),
                    'anoFundacion': int.tryParse(anoCtrl.text.trim()),
                    'escudoUrl': escudoCtrl.text.trim().isEmpty ? null : escudoCtrl.text.trim(),
                    'ligaId': ligaIdSeleccionada,
                  };

                  try {
                    await EquipoService.actualizarEquipo(equipo.id!, equipoData);
                    Navigator.pop(context);
                    await _cargarDatos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Equipo actualizado correctamente'), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _eliminarEquipo(Equipo equipo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar el equipo "${equipo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await EquipoService.eliminarEquipo(equipo.id!);
        await _cargarDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Equipo eliminado'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        _mostrarError('Error al eliminar: $e');
      }
    }
  }

  void _mostrarDialogoCrear() {
    _limpiarFormulario();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Equipo'),
        content: SingleChildScrollView(child: _buildFormularioEquipo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _crearEquipo,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // lib/screens/Admin/GestionEquiposPage.dart

  Widget _buildFormularioEquipo() {
    return FutureBuilder<List<Liga>>(
      future: LigaService.listarLigas(),  // ✅ Ahora devuelve List<Liga>
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final ligas = snapshot.data!;

        return Column(
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del equipo'),
            ),
            const SizedBox(height: 12),
            // ... otros campos
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Liga'),
              value: _ligaIdSeleccionada,
              items: ligas.map((liga) {
                return DropdownMenuItem(
                  value: liga.id,
                  child: Text(liga.nombreLiga),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _ligaIdSeleccionada = value;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _estadioController.clear();
    _ciudadController.clear();
    _anoController.clear();
    _escudoUrlController.clear();
    _ligaIdSeleccionada = null;
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
              const Text(
                'Gestión de Equipos',
                style: TextStyle(color: AppColors.blanco, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Equipo'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                onPressed: _mostrarDialogoCrear,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.negro.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _filtroNombre = v),
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: const InputDecoration(
                    hintText: 'Filtrar por nombre',
                    hintStyle: TextStyle(color: AppColors.blancoOpacidad70),
                    prefixIcon: Icon(Icons.search, color: AppColors.blanco),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<int?>(
                value: _filtroLigaId,
                dropdownColor: AppColors.negro,
                hint: const Text('Liga', style: TextStyle(color: AppColors.blanco)),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Todas', style: TextStyle(color: AppColors.blanco))),
                  ..._ligas.map((l) => DropdownMenuItem<int?>(
                    value: l['id'] as int?,
                    child: Text(l['nombreLiga']?.toString() ?? 'Liga', style: const TextStyle(color: AppColors.blanco)),
                  )),
                ],
                onChanged: (value) => setState(() => _filtroLigaId = value),
              )
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _equiposFiltrados.length,
              itemBuilder: (context, index) {
                final equipo = _equiposFiltrados[index];
                return _buildEquipoCard(equipo);
              },
            ),
          ),
        ],
      ),
    );
  }

  // En el método _buildEquipoCard

  Widget _buildEquipoCard(Equipo equipo) {
    return Card(
      color: AppColors.blanco,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.naranja.withOpacity(0.2),
          child: const Icon(Icons.sports_basketball, color: AppColors.naranja),
        ),
        title: Text(equipo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadio: ${equipo.nombreEstadio}'),
            Text('Ciudad: ${equipo.ciudad}'),
            Text('Liga: ${equipo.nombreLiga ?? "Sin liga"}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _mostrarDialogoEditar(equipo),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _eliminarEquipo(equipo),
            ),
          ],
        ),
      ),
    );
  }
}