// lib/screens/Admin/GestionJugadoresPage.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/jugador.dart';
import '../../models/equipo.dart';
import '../../services/jugadorService.dart';
import '../../services/equipoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class GestionJugadoresPage extends StatefulWidget {
  const GestionJugadoresPage({super.key});

  @override
  State<GestionJugadoresPage> createState() => _GestionJugadoresPageState();
}

class _GestionJugadoresPageState extends State<GestionJugadoresPage> {
  List<Jugador> _jugadores = [];
  List<Equipo> _equipos = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;
  String _filtro = 'TODOS'; // TODOS, SIN_EQUIPO, CON_EQUIPO
  String _busqueda = '';

  // Formulario para crear/editar jugador
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  Jugador? _editandoJugador;

  // Controladores del formulario
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dorsalController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _posicionController = TextEditingController();
  int? _equipoId;

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
    _dorsalController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    _posicionController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final jugadores = await JugadorService.listarJugadores();
      final equipos = await EquipoService.listarEquipos();

      setState(() {
        _jugadores = jugadores;
        _equipos = equipos;
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

  List<Jugador> get _jugadoresFiltrados {
    Iterable<Jugador> base = _jugadores;
    switch (_filtro) {
      case 'SIN_EQUIPO': base = base.where((j) => j.equipoId == null); break;
      case 'CON_EQUIPO': base = base.where((j) => j.equipoId != null); break;
    }
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return base.toList();
    return base.where((j) =>
    j.nombreCompleto.toLowerCase().contains(q) ||
        j.posicion.toLowerCase().contains(q) ||
        j.dorsal.toString().contains(q) ||
        (j.nombreEquipo ?? '').toLowerCase().contains(q)
    ).toList();
  }

  Future<void> _crearJugador() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final jugadorData = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'email': _emailController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'dorsal': int.tryParse(_dorsalController.text) ?? 0,
        'altura': double.tryParse(_alturaController.text) ?? 0,
        'peso': double.tryParse(_pesoController.text) ?? 0,
        'posicion': _posicionController.text,
        'equipoId': _equipoId,
      };

      await JugadorService.crearJugador(jugadorData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jugador creado correctamente'), backgroundColor: Colors.green),
        );
        _limpiarFormulario();
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear jugador: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  // En GestionJugadoresPage.dart - CORREGIR _actualizarJugador

  Future<void> _actualizarJugador() async {
    if (!_formKey.currentState!.validate() || _editandoJugador == null) return;

    // Verificar que el id no sea null
    if (_editandoJugador!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID del jugador no válido'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final jugadorData = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'email': _emailController.text,
        'dorsal': int.tryParse(_dorsalController.text) ?? 0,
        'altura': double.tryParse(_alturaController.text) ?? 0,
        'peso': double.tryParse(_pesoController.text) ?? 0,
        'posicion': _posicionController.text,
        'equipoId': _equipoId,
      };

      // Usar el operador ! para indicar que no es null (después de la verificación)
      await JugadorService.actualizarJugador(_editandoJugador!.id!, jugadorData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jugador actualizado correctamente'), backgroundColor: Colors.green),
        );
        _limpiarFormulario();
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar jugador: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _eliminarJugador(Jugador jugador) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar a ${jugador.nombreCompleto}?'),
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
        await JugadorService.eliminarJugador(jugador.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jugador eliminado correctamente'), backgroundColor: Colors.green),
          );
          _cargarDatos();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar jugador: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _editarJugador(Jugador jugador) {
    setState(() {
      _isEditing = true;
      _editandoJugador = jugador;
      _nombreController.text = jugador.nombre;
      _apellidoController.text = jugador.apellido ?? '';
      _emailController.text = jugador.email;
      _usernameController.text = jugador.username;
      _dorsalController.text = jugador.dorsal.toString();
      _alturaController.text = jugador.altura.toString();
      _pesoController.text = jugador.peso.toString();
      _posicionController.text = jugador.posicion;
      _equipoId = jugador.equipoId;
      _passwordController.text = ''; // No mostrar contraseña
    });
  }

  void _limpiarFormulario() {
    _isEditing = false;
    _editandoJugador = null;
    _nombreController.clear();
    _apellidoController.clear();
    _emailController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _dorsalController.clear();
    _alturaController.clear();
    _pesoController.clear();
    _posicionController.clear();
    _equipoId = null;
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Gestión de Jugadores"),
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
                      child: _buildListaJugadores(),
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
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _busqueda = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, dorsal, posición o equipo...',
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
              isDense: true,
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFiltroChip('TODOS', 'Todos'),
              _buildFiltroChip('CON_EQUIPO', 'Con Equipo'),
              _buildFiltroChip('SIN_EQUIPO', 'Sin Equipo'),
            ],
          ),
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

  Widget _buildListaJugadores() {
    if (_jugadoresFiltrados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text('No hay jugadores registrados', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jugadoresFiltrados.length,
        itemBuilder: (context, index) {
          final jugador = _jugadoresFiltrados[index];
          return _buildJugadorCard(jugador);
        },
      ),
    );
  }

  Widget _buildJugadorCard(Jugador jugador) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.naranja,
          child: Text(jugador.iniciales, style: const TextStyle(color: Colors.white)),
        ),
        title: Text(jugador.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dorsal: ${jugador.dorsal} | Posición: ${jugador.posicion}'),
            Text(
              jugador.nombreEquipo != null ? 'Equipo: ${jugador.nombreEquipo}' : 'Sin equipo',
              style: TextStyle(
                color: jugador.nombreEquipo != null ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: AppColors.naranja),
              tooltip: 'Cambiar equipo',
              onPressed: () => _cambiarEquipo(jugador),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editarJugador(jugador),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _eliminarJugador(jugador),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarEquipo(Jugador jugador) async {
    if (jugador.id == null) return;
    int? nuevoEquipoId = jugador.equipoId;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text('Cambiar equipo de ${jugador.nombreCompleto}'),
          content: DropdownButtonFormField<int?>(
            value: nuevoEquipoId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Equipo'),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Sin equipo')),
              ..._equipos.map((e) => DropdownMenuItem<int?>(
                value: e.id,
                child: Text(e.nombre, overflow: TextOverflow.ellipsis),
              )),
            ],
            onChanged: (v) => setSt(() => nuevoEquipoId = v),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (guardar != true || nuevoEquipoId == jugador.equipoId) return;

    try {
      await JugadorService.actualizarJugador(jugador.id!, {
        'nombre': jugador.nombre,
        'apellido': jugador.apellido ?? '',
        'email': jugador.email,
        'dorsal': jugador.dorsal,
        'altura': jugador.altura,
        'peso': jugador.peso,
        'posicion': jugador.posicion,
        'equipoId': nuevoEquipoId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Equipo actualizado'), backgroundColor: Colors.green));
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // En GestionJugadoresPage.dart - CORREGIDO

// Cambiar el DropdownButtonFormField para trabajar con int?
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
                  _isEditing ? 'EDITAR JUGADOR' : 'NUEVO JUGADOR',
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
                const SizedBox(height: 12),
                // CORREGIDO: Usar DropdownButtonFormField<int?> en lugar de <int>
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(labelText: 'Equipo'),
                  value: _equipoId,
                  hint: const Text('Seleccionar equipo'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Sin equipo'),
                    ),
                    ..._equipos.map((e) => DropdownMenuItem<int?>(
                      value: e.id,
                      child: Text(e.nombre),
                    )),
                  ],
                  onChanged: (value) => setState(() => _equipoId = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dorsalController,
                        decoration: const InputDecoration(labelText: 'Dorsal *'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _posicionController,
                        decoration: const InputDecoration(labelText: 'Posición *'),
                        validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _alturaController,
                        decoration: const InputDecoration(labelText: 'Altura (m)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pesoController,
                        decoration: const InputDecoration(labelText: 'Peso (kg)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
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
                            : (_isEditing ? _actualizarJugador : _crearJugador),
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