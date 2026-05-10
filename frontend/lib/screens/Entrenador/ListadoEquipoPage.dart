import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/equipo.dart';
import '../../services/equipoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import '../equipos/DetalleEquipoPage.dart';

class ListadoEquiposPage extends StatefulWidget {
  const ListadoEquiposPage({super.key});

  @override
  State<ListadoEquiposPage> createState() => _ListadoEquiposPageState();
}

class _ListadoEquiposPageState extends State<ListadoEquiposPage> {
  List<Equipo> _equipos = [];
  List<Equipo> _equiposCache = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _filtroLiga;
  String? _filtroCiudad;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final equipos = await EquipoService.listarEquipos();
      setState(() {
        _equipos = equipos;
        _equiposCache = equipos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Equipo> _filtrarEquipos(List<Equipo> equipos) {
    return equipos.where((e) {
      if (_filtroLiga != null && _filtroLiga != 'Todas' && e.nombreLiga != _filtroLiga) return false;
      if (_filtroCiudad != null && _filtroCiudad != 'Todas' && e.ciudad != _filtroCiudad) return false;
      if (_searchQuery.isEmpty) return true;
      return e.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.ciudad.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (e.nombreLiga?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  void _navegarADetalle(Equipo equipo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EquipoDetallePage(equipo: equipo)),
    );
  }

  Future<void> _editarEquipo(Equipo equipo) async {
    final nombreCtrl = TextEditingController(text: equipo.nombre);
    final ciudadCtrl = TextEditingController(text: equipo.ciudad);
    final estadioCtrl = TextEditingController(text: equipo.nombreEstadio);

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Editar ${equipo.nombre}',
            style: const TextStyle(color: AppColors.blanco, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campoEdit('Nombre', nombreCtrl),
              const SizedBox(height: 10),
              _campoEdit('Ciudad', ciudadCtrl),
              const SizedBox(height: 10),
              _campoEdit('Estadio', estadioCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grisClaro)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (guardar != true || equipo.id == null) return;

    try {
      await EquipoService.actualizarEquipo(equipo.id!, {
        'nombre': nombreCtrl.text.trim(),
        'ciudad': ciudadCtrl.text.trim(),
        'nombreEstadio': estadioCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Equipo actualizado'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating));
        _cargarEquipos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  Widget _campoEdit(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.blanco),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.grisClaro),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grisClaro.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.naranja),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Gestión de Equipos"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : Column(
            children: [
              _buildSearchBar(),
              _buildFiltros(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _cargarEquipos,
                  child: _buildEquiposList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        style: const TextStyle(color: AppColors.blanco),
        decoration: InputDecoration(
          hintText: 'Buscar equipos...',
          hintStyle: TextStyle(color: AppColors.blancoOpacidad70),
          prefixIcon: const Icon(Icons.search, color: AppColors.naranja),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: AppColors.grisClaro),
            onPressed: () {
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled: true,
          fillColor: AppColors.blanco.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildFiltros() {
    final ligas = <String>{'Todas', ..._equiposCache.map((e) => e.nombreLiga ?? '').where((s) => s.isNotEmpty)};
    final ciudades = <String>{'Todas', ..._equiposCache.map((e) => e.ciudad).where((s) => s.isNotEmpty)};

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownFiltro(
              'Liga', _filtroLiga ?? 'Todas', ligas.toList(),
                  (v) => setState(() => _filtroLiga = v),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdownFiltro(
              'Ciudad', _filtroCiudad ?? 'Todas', ciudades.toList(),
                  (v) => setState(() => _filtroCiudad = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFiltro(
      String label, String value, List<String> opciones, ValueChanged<String?> onChanged) {

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.blanco.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<String>(
          value: opciones.contains(value) ? value : 'Todas',
          isExpanded: true,
          dropdownColor: AppColors.negro,
          underline: const SizedBox(),
          hint: Text(label, style: const TextStyle(color: AppColors.blancoOpacidad70)),
          items: opciones
              .map((o) => DropdownMenuItem(
            value: o,
            child: Text(o,
                style: const TextStyle(color: AppColors.blanco, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error, size: 64, color: Colors.red),
      const SizedBox(height: 16),
      Text(_error!, style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 16),
      ElevatedButton(
          onPressed: _cargarEquipos,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
          child: const Text('Reintentar')
      ),
    ]),
  );

  Widget _buildEquiposList() {
    final equiposFiltrados = _filtrarEquipos(_equipos);

    if (equiposFiltrados.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text('No hay equipos registrados', style: TextStyle(color: Colors.white54, fontSize: 16)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: equiposFiltrados.length,
      itemBuilder: (context, index) {
        final equipo = equiposFiltrados[index];
        return _buildEquipoCard(equipo);
      },
    );
  }

  Widget _buildEquipoCard(Equipo equipo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navegarADetalle(equipo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: AppColors.naranja.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.sports_basketball, size: 30, color: AppColors.naranja),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(equipo.nombre,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_city, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(child: Text(equipo.ciudad, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 12),
                        const Icon(Icons.emoji_events, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(child: Text(equipo.nombreLiga ?? 'Sin liga', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(child: Text(equipo.nombreEntrenador ?? 'Sin entrenador', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 12),
                        const Icon(Icons.people, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${equipo.numeroJugadores} jugadores', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.naranja, size: 20),
                tooltip: 'Editar',
                onPressed: () => _editarEquipo(equipo),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
