// lib/screens/Admin/GestionLigasPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/liga.dart';
import '../../services/autenticacion_service.dart';
import '../Clasificacion.dart';
import '../Liga/LigaService.dart';

class GestionLigasPage extends StatefulWidget {
  const GestionLigasPage({super.key});

  @override
  State<GestionLigasPage> createState() => _GestionLigasPageState();
}

class _GestionLigasPageState extends State<GestionLigasPage> {
  List<Liga> _ligas = [];  // ✅ Cambiado a List<Liga>
  bool _isLoading = true;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _temporadaController = TextEditingController();
  final _paisController = TextEditingController();  // ✅ Añadido

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
    _paisController.dispose();
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

  Future<void> _eliminarLiga(Liga liga) async {  // ✅ Cambiado a tipo Liga
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar la liga "${liga.nombreLiga}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await LigaService.eliminarLiga(liga.id!);
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
                controller: _paisController,  // ✅ Campo para país
                decoration: const InputDecoration(labelText: 'País'),
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
    _paisController.clear();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  /// Navega a la página de Clasificación / detalle de la liga.
  /// Antes la card era inerte porque no tenía `onTap`.
  void _abrirLiga(Liga liga) {
    if (liga.id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClasificacionPage(
          id_categoria: liga.id!,
          categoria: liga.nombreLiga,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: usar Scaffold con AppBar y fondo en gradiente.
    // Antes era un Container sin Scaffold, así que el título blanco
    // quedaba sobre fondo blanco (invisible) y no había botón de
    // volver — el usuario solo veía el botón "Nueva Liga".
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.rojoAragon,
        foregroundColor: Colors.white,
        title: const Text('Gestión de Ligas'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: _cargarLigas,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.naranja,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva Liga', style: TextStyle(color: Colors.white)),
        onPressed: _mostrarDialogoCrear,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
                    : _ligas.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay ligas registradas',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _ligas.length,
                            itemBuilder: (context, index) {
                              final liga = _ligas[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  // ✅ Hacer la liga clicable para acceder
                                  // a su clasificación / detalle.
                                  onTap: () => _abrirLiga(liga),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.naranja.withOpacity(0.2),
                                    child: Text(
                                      liga.nombreLiga.isNotEmpty
                                          ? liga.nombreLiga[0]
                                          : '?',
                                      style: const TextStyle(
                                        color: AppColors.naranja,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    liga.nombreLiga,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (liga.pais != null)
                                        Text('País: ${liga.pais}'),
                                      Text(
                                        '📅 ${liga.temporada ?? 'Temporada no especificada'}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '🏆 Equipos: ${liga.numeroEquiposRegistrados}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _eliminarLiga(liga),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ),
      ),
    );
  }
}