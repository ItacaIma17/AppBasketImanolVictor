// lib/screens/Admin/GestionLigasPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

import '../../services/autenticacion_service.dart';
import '../Liga/LigaService.dart';

class GestionLigasPage extends StatefulWidget {
  const GestionLigasPage({super.key});

  @override
  State<GestionLigasPage> createState() => _GestionLigasPageState();
}

class _GestionLigasPageState extends State<GestionLigasPage> {
  List<Map<String, dynamic>> _ligas = [];
  bool _isLoading = true;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _temporadaController = TextEditingController();
  final _paisController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _cargarLigas();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _temporadaController.dispose();
    super.dispose();
  }

  Future<void> _cargarLigas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ligas = await LigaService.listarLigas();
      setState(() {
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

  // lib/screens/Admin/GestionLigasPage.dart

  // lib/screens/Admin/GestionLigasPage.dart (parte del método crear)

  Future<void> _crearLiga() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ligaData = {
        'nombreLiga': _nombreController.text.trim(),
        'pais': _paisController.text.trim().isEmpty ? 'España' : _paisController.text.trim(),
        'numeroEquipos': 0,
        'temporada': _temporadaController.text.trim(),
      };

      await LigaService.crearLiga(ligaData);

      _limpiarFormulario();
      await _cargarLigas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Liga creada exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _mostrarError('Error al crear liga: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarLiga(Map<String, dynamic> liga) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar la liga "${liga['nombreLiga']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await LigaService.eliminarLiga(liga['id']);
        await _cargarLigas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Liga eliminada'), backgroundColor: Colors.green),
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
        title: const Text('Crear Nueva Liga'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre de la liga'),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _temporadaController,
                decoration: const InputDecoration(labelText: 'Temporada (ej: 2024-2025)'),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: _crearLiga, style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja), child: const Text('Crear')),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _descripcionController.clear();
    _temporadaController.clear();
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
              const Text('Gestión de Ligas', style: TextStyle(color: AppColors.blanco, fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Nueva Liga'),
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
              itemCount: _ligas.length,
              itemBuilder: (context, index) {
                final liga = _ligas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.naranja.withOpacity(0.2),
                      child: Text(liga['nombreLiga'][0], style: const TextStyle(color: AppColors.naranja, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(liga['nombreLiga'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (liga['descripcion'] != null) Text(liga['descripcion']),
                        Text('📅 ${liga['temporada'] ?? 'Temporada no especificada'}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarLiga(liga),
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