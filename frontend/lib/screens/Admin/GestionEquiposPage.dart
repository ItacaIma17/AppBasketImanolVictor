import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/screens/equipos/DetalleEquipoPage.dart';
import '../../models/equipo.dart';
import '../../services/equipoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class GestionEquiposPage extends StatefulWidget {
  const GestionEquiposPage({super.key});

  @override
  State<GestionEquiposPage> createState() => _GestionEquiposPageState();
}

class _GestionEquiposPageState extends State<GestionEquiposPage> {
  List<Equipo> _equipos = [];
  List<Equipo> _equiposFiltrados = [];
  bool _cargando = true;
  String? _error;

  String _filtroNombre = '';
  String? _filtroLiga;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final equipos = await EquipoService.listarEquipos();
      setState(() {
        _equipos = equipos;
        _aplicarFiltros();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _equiposFiltrados = _equipos.where((e) {
        if (_filtroNombre.isNotEmpty && !e.nombre.toLowerCase().contains(_filtroNombre.toLowerCase())) {
          return false;
        }
        if (_filtroLiga != null && _filtroLiga!.isNotEmpty && e.nombreLiga != _filtroLiga) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  Future<void> _editarEquipo(Equipo equipo) async {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(text: equipo.nombre);
    final ciudadCtrl = TextEditingController(text: equipo.ciudad);
    final estadioCtrl = TextEditingController(text: equipo.nombreEstadio);

    final guardado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Editar Equipo', style: TextStyle(color: Colors.white)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: ciudadCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextFormField(
                controller: estadioCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Estadio / Pabellón',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (guardado == true && equipo.id != null) {
      try {
        await EquipoService.actualizarEquipo(equipo.id!, {
          'nombre': nombreCtrl.text.trim(),
          'ciudad': ciudadCtrl.text.trim(),
          'nombreEstadio': estadioCtrl.text.trim(),
        });
        await _cargarEquipos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(' Equipo actualizado'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    nombreCtrl.dispose();
    ciudadCtrl.dispose();
    estadioCtrl.dispose();
  }

  Future<void> _eliminarEquipo(Equipo equipo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Eliminar equipo', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${equipo.nombre}"? Esta acción no se puede deshacer.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && equipo.id != null) {
      try {
        await EquipoService.eliminarEquipo(equipo.id!);
        await _cargarEquipos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(' Equipo eliminado'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final ligasUnicas = _equipos.map((e) => e.nombreLiga).where((l) => l != null).toSet().toList();

    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Gestión de Equipos"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar equipo...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: AppColors.naranja),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        onChanged: (value) {
                          _filtroNombre = value;
                          _aplicarFiltros();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filtroLiga,
                        hint: const Text('Todas las ligas', style: TextStyle(color: Colors.white70)),
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todas', style: TextStyle(color: Colors.white))),
                          ...ligasUnicas.map((liga) => DropdownMenuItem(
                            value: liga,
                            child: Text(liga ?? 'Sin liga', style: const TextStyle(color: Colors.white)),
                          )),
                        ],
                        onChanged: (value) {
                          _filtroLiga = value;
                          _aplicarFiltros();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    : _equiposFiltrados.isEmpty
                    ? const Center(child: Text('No hay equipos', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _equiposFiltrados.length,
                  itemBuilder: (context, index) {
                    final equipo = _equiposFiltrados[index];
                    return _buildEquipoCard(equipo);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipoCard(Equipo equipo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EquipoDetallePage(equipo: equipo),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.naranja.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield, size: 32, color: AppColors.naranja),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipo.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        equipo.nombreLiga ?? 'Sin liga',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        equipo.ciudad.isNotEmpty ? equipo.ciudad : 'Ciudad no especificada',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Editar equipo',
                      onPressed: () => _editarEquipo(equipo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar equipo',
                      onPressed: () => _eliminarEquipo(equipo),
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
