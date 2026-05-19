import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/usuario.dart';
import '../../services/adminService.dart';

class GestionUsuariosPage extends StatefulWidget {
  const GestionUsuariosPage({super.key});

  @override
  State<GestionUsuariosPage> createState() => _GestionUsuariosPageState();
}

class _GestionUsuariosPageState extends State<GestionUsuariosPage> {
  List<dynamic> _usuarios = [];
  List<dynamic> _filtrados = [];
  bool _cargando = true;
  String? _error;
  String _busqueda = '';
  String _filtroRol = 'Todos';

  static const _roles = ['Todos', 'JUGADOR', 'ENTRENADOR', 'ARBITRO', 'AFICIONADO', 'ADMIN'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final data = await AdminService.listarTodosUsuarios();
      if (mounted) {
        setState(() {

          _usuarios = data.map((u) => u.toJson()).toList();
          _aplicarFiltros();
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _cargando = false; });
    }
  }

  void _aplicarFiltros() {
    var lista = List<dynamic>.from(_usuarios);
    if (_filtroRol != 'Todos') {
      lista = lista.where((u) =>
      (u['role'] ?? u['rol'] ?? '').toString().toUpperCase() == _filtroRol
      ).toList();
    }
    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista.where((u) =>
      (u['nombre'] ?? '').toString().toLowerCase().contains(q) ||
          (u['email'] ?? '').toString().toLowerCase().contains(q) ||
          (u['username'] ?? '').toString().toLowerCase().contains(q)
      ).toList();
    }
    _filtrados = lista;
  }

  Future<void> _toggleBloqueo(Map<String, dynamic> u) async {
    final bloqueado = u['bloqueado'] == true;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(bloqueado ? 'Desbloquear usuario' : 'Bloquear usuario',
            style: const TextStyle(color: AppColors.blanco)),
        content: Text(
          '¿${bloqueado ? "Desbloquear" : "Bloquear"} a ${u['nombre'] ?? u['username']}?',
          style: const TextStyle(color: AppColors.grisClaro),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.grisClaro))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: bloqueado ? Colors.green : Colors.red),
            child: Text(bloqueado ? 'Desbloquear' : 'Bloquear',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      if (bloqueado) {
        await AdminService.desbloquearUsuario(u['id']);
      } else {
        await AdminService.bloquearUsuario(u['id']);
      }
      await _cargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${bloqueado ? "Desbloqueado" : "Bloqueado"}: ${u['nombre'] ?? u['username']}'),
          backgroundColor: bloqueado ? Colors.green : Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text('Gestión de Usuarios',
                          style: TextStyle(color: AppColors.blanco,
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.blanco),
                      onPressed: _cargar,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: AppColors.blanco),
                        onChanged: (v) => setState(() {
                          _busqueda = v;
                          _aplicarFiltros();
                        }),
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          hintStyle: const TextStyle(color: AppColors.grisClaro),
                          prefixIcon: const Icon(Icons.search, color: AppColors.naranja),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filtroRol,
                            dropdownColor: const Color(0xFF1E1E1E),
                            underline: const SizedBox(),
                            iconEnabledColor: AppColors.naranja,
                            style: const TextStyle(color: AppColors.blanco, fontSize: 13),
                            items: _roles.map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r,
                                  style: const TextStyle(color: AppColors.blanco)),
                            )).toList(),
                            onChanged: (v) => setState(() {
                              _filtroRol = v!;
                              _aplicarFiltros();
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text('${_filtrados.length} usuarios',
                        style: const TextStyle(
                            color: AppColors.grisClaro, fontSize: 12)),
                  ],
                ),
              ),

              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator(
                    color: AppColors.amarilloAragon))
                    : _error != null
                    ? _buildError()
                    : _filtrados.isEmpty
                    ? const Center(
                    child: Text('Sin usuarios',
                        style: TextStyle(color: AppColors.grisClaro)))
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: _filtrados.length,
                  itemBuilder: (_, i) =>
                      _buildUserCard(_filtrados[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> u) {
    final rol = (u['role'] ?? u['rol'] ?? 'AFICIONADO').toString();
    final bloqueado = u['bloqueado'] == true;
    final verificado = u['verificado'] == true;
    final nombre = u['nombre'] ?? u['username'] ?? 'Sin nombre';
    final email = u['email'] ?? '';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bloqueado
              ? Colors.red.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: _rolColor(rol).withOpacity(0.2),
          child: Text(inicial,
              style: TextStyle(color: _rolColor(rol),
                  fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(nombre,
                  style: const TextStyle(color: AppColors.blanco,
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _rolColor(rol).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_labelRol(rol),
                  style: TextStyle(color: _rolColor(rol),
                      fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email,
                style: const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  verificado ? Icons.verified : Icons.warning_amber,
                  size: 12,
                  color: verificado ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  verificado ? 'Verificado' : 'Sin verificar',
                  style: TextStyle(
                    color: verificado ? Colors.green : Colors.orange,
                    fontSize: 11,
                  ),
                ),
                if (bloqueado) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.block, size: 12, color: Colors.red),
                  const SizedBox(width: 4),
                  const Text('Bloqueado',
                      style: TextStyle(color: Colors.red, fontSize: 11)),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            bloqueado ? Icons.lock_open : Icons.block,
            color: bloqueado ? Colors.green : Colors.red,
          ),
          onPressed: () => _toggleBloqueo(u),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.blanco),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargar,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojoAragon),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Color _rolColor(String rol) {
    switch (rol.toUpperCase()) {
      case 'JUGADOR': return Colors.green;
      case 'ENTRENADOR': return Colors.orange;
      case 'ARBITRO': return Colors.purple;
      case 'ADMIN': return Colors.red;
      default: return Colors.blue;
    }
  }

  String _labelRol(String rol) {
    switch (rol.toUpperCase()) {
      case 'JUGADOR': return ' Jugador';
      case 'ENTRENADOR': return ' Entrenador';
      case 'ARBITRO': return ' Árbitro';
      case 'ADMIN': return ' Admin';
      default: return ' Aficionado';
    }
  }
}
