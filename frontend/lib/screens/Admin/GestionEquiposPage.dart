// lib/screens/Admin/GestionEquiposPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

import '../../models/equipo.dart';
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

  // Controladores para el formulario
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _estadioController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _anoController = TextEditingController();
  final _escudoUrlController = TextEditingController();
  int? _ligaIdSeleccionada;

  @override
  void initState() {
    super.initState();
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
        _ligas = ligas;
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

    try {
      final equipo = Equipo(
          nombre: _nombreController.text,
          nombreEstadio: _estadioController.text,
          ciudad: _ciudadController.text,
          anoFundacion: int.parse(_anoController.text),
          escudoUrl: _escudoUrlController.text.isNotEmpty ? _escudoUrlController.text : null,
    ligaId: _ligaIdSeleccionada,
    );

    await EquipoService.crearEquipo(equipo);

    _limpiarFormulario();
    await _cargarDatos();

    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('✅ Equipo creado exitosamente'), backgroundColor: Colors.green),
    );
    Navigator.pop(context); // Cerrar diálogo
    }
    } catch (e) {
    _mostrarError('Error al crear equipo: $e');
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
        content: _buildFormulario(),
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
              await EquipoService.actualizarEquipo(equipo.id!, equipoActualizado);
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
        content: SingleChildScrollView(child: _buildFormulario()),
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

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre del equipo'),
            validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _estadioController,
            decoration: const InputDecoration(labelText: 'Estadio'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ciudadController,
            decoration: const InputDecoration(labelText: 'Ciudad'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _anoController,
            decoration: const InputDecoration(labelText: 'Año de fundación'),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
          ),
          // En la sección del formulario, corrige el Dropdown así:

          DropdownButtonFormField<int>(
            value: _ligaIdSeleccionada,
            decoration: const InputDecoration(labelText: 'Liga'),
            items: _ligas.map<DropdownMenuItem<int>>((liga) {  // ← Especificar el tipo genérico
              return DropdownMenuItem<int>(
                value: liga['id'] as int,  // ← Asegurar tipo int
                child: Text(liga['nombreLiga']),
              );
            }).toList(),
            onChanged: (value) => _ligaIdSeleccionada = value,
            validator: (v) => v == null ? 'Selecciona una liga' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _escudoUrlController,
            decoration: const InputDecoration(labelText: 'URL del escudo (opcional)'),
          ),
        ],
      ),
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
              itemCount: _equipos.length,
              itemBuilder: (context, index) {
                final equipo = _equipos[index];
                return _buildEquipoCard(equipo);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipoCard(Equipo equipo) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.naranja.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: equipo.escudoUrl != null
                  ? Image.network(equipo.escudoUrl!, height: 80)
                  : Icon(Icons.sports_basketball, size: 60, color: AppColors.naranja),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipo.nombre,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '🏟️ ${equipo.nombreEstadio}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '📍 ${equipo.ciudad}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _actualizarEquipo(equipo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarEquipo(equipo),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}