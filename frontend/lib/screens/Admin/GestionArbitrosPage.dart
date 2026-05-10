import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/arbitro.dart';
import '../../services/arbitroService.dart';
import '../../services/loggerService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class GestionArbitrosPage extends StatefulWidget {
  const GestionArbitrosPage({super.key});

  @override
  State<GestionArbitrosPage> createState() => _GestionArbitrosPageState();
}

class _GestionArbitrosPageState extends State<GestionArbitrosPage> {
  List<Arbitro> _arbitros = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;
  String _filtro = 'TODOS';

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  Arbitro? _editandoArbitro;

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _licenciaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _licenciaController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final arbitros = await ArbitroService.listarArbitros();

      setState(() {
        _arbitros = arbitros;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Arbitro> get _arbitrosFiltrados {
    switch (_filtro) {
      case 'ACTIVOS':
        return _arbitros.where((a) => a.activo == true).toList();
      case 'INACTIVOS':
        return _arbitros.where((a) => a.activo == false).toList();
      default:
        return _arbitros;
    }
  }

  Future<void> _crearArbitro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final arbitroData = {
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'codigoArbitro': _licenciaController.text.trim(),
        'activo': true,
      };

      LoggerService.info('Creando árbitro: ${arbitroData['username']}', tag: 'ARBITRO');

      await ArbitroService.crearArbitro(arbitroData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Árbitro creado correctamente'), backgroundColor: Colors.green),
        );
        _limpiarFormulario();
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear árbitro: $e'), backgroundColor: Colors.red),
        );
      }
      LoggerService.error('Error creando árbitro', tag: 'ARBITRO', error: e);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _actualizarArbitro() async {
    if (!_formKey.currentState!.validate() || _editandoArbitro == null) return;

    setState(() => _isCreating = true);

    try {
      final arbitroData = {
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'email': _emailController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'codigoArbitro': _licenciaController.text.trim(),
      };

      if (_passwordController.text.trim().isNotEmpty) {
        arbitroData['password'] = _passwordController.text.trim();
      }

      LoggerService.info('Actualizando árbitro: ${_editandoArbitro!.id}', tag: 'ARBITRO');
      LoggerService.info('Datos: $arbitroData', tag: 'ARBITRO');

      await ArbitroService.actualizarArbitro(_editandoArbitro!.id!, arbitroData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Árbitro actualizado correctamente'), backgroundColor: Colors.green),
        );
        _limpiarFormulario();
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar árbitro: $e'), backgroundColor: Colors.red),
        );
      }
      LoggerService.error('Error actualizando árbitro', tag: 'ARBITRO', error: e);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _eliminarArbitro(Arbitro arbitro) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar a ${arbitro.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ArbitroService.eliminarArbitro(arbitro.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Árbitro eliminado correctamente'), backgroundColor: Colors.green),
          );
          _cargarDatos();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar árbitro: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _cambiarEstadoArbitro(Arbitro arbitro) async {
    try {
      if (arbitro.id == null) {
        throw Exception('ID de árbitro no válido');
      }

      await ArbitroService.cambiarEstadoArbitro(arbitro.id!, !arbitro.activo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(arbitro.activo ? 'Árbitro desactivado' : 'Árbitro activado'),
            backgroundColor: Colors.orange,
          ),
        );
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $e'), backgroundColor: Colors.red),
        );
      }
      LoggerService.error('Error cambiando estado del árbitro', tag: 'ARBITRO', error: e);
    }
  }

  void _editarArbitro(Arbitro arbitro) {
    setState(() {
      _isEditing = true;
      _editandoArbitro = arbitro;
      _nombreController.text = arbitro.nombre ?? '';
      _apellidoController.text = arbitro.apellido ?? '';
      _emailController.text = arbitro.email;
      _usernameController.text = arbitro.username;
      _telefonoController.text = arbitro.telefono ?? '';
      _licenciaController.text = arbitro.codigoArbitro ?? '';
      _passwordController.text = '';
    });
  }

  void _limpiarFormulario() {
    _isEditing = false;
    _editandoArbitro = null;
    _nombreController.clear();
    _apellidoController.clear();
    _emailController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _telefonoController.clear();
    _licenciaController.clear();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Gestión de Árbitros"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : Column(
            children: [
              _buildFiltros(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildListaArbitros(),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildFormulario(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarDatos,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFiltroChip('TODOS', 'Todos'),
          _buildFiltroChip('ACTIVOS', 'Activos'),
          _buildFiltroChip('INACTIVOS', 'Inactivos'),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String valor, String label) {
    final isSelected = _filtro == valor;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _filtro = valor);
      },
      backgroundColor: Colors.grey.withOpacity(0.3),
      selectedColor: AppColors.naranja,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
    );
  }

  Widget _buildListaArbitros() {
    if (_arbitrosFiltrados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text('No hay árbitros registrados', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _arbitrosFiltrados.length,
        itemBuilder: (context, index) {
          final arbitro = _arbitrosFiltrados[index];
          return _buildArbitroCard(arbitro);
        },
      ),
    );
  }

  Widget _buildArbitroCard(Arbitro arbitro) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: arbitro.activo ? AppColors.naranja : Colors.grey,
          child: Text(
            arbitro.iniciales,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          arbitro.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(arbitro.email),
            if (arbitro.codigoArbitro != null)
              Text('Licencia: ${arbitro.codigoArbitro}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                arbitro.activo ? Icons.visibility : Icons.visibility_off,
                color: arbitro.activo ? Colors.green : Colors.red,
              ),
              onPressed: () => _cambiarEstadoArbitro(arbitro),
              tooltip: arbitro.activo ? 'Desactivar' : 'Activar',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editarArbitro(arbitro),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _eliminarArbitro(arbitro),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'EDITAR ÁRBITRO' : 'NUEVO ÁRBITRO',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _licenciaController,
                  decoration: const InputDecoration(labelText: 'Licencia'),
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Usuario *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña *'),
                    obscureText: true,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (_isEditing) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _limpiarFormulario,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isCreating
                            ? null
                            : (_isEditing ? _actualizarArbitro : _crearArbitro),
                        icon: _isCreating
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(_isEditing ? Icons.update : Icons.save),
                        label: Text(_isEditing ? 'Actualizar' : 'Crear'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
