// lib/screens/equipos/ListadoEquiposPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/equipo.dart';
import '../../services/equipoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class ListadoEquiposPage extends StatefulWidget {
  const ListadoEquiposPage({super.key});

  @override
  State<ListadoEquiposPage> createState() => _ListadoEquiposPageState();
}

class _ListadoEquiposPageState extends State<ListadoEquiposPage> {
  List<Equipo> _equipos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final equipos = await EquipoService.listarEquipos();
      setState(() { _equipos = equipos; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
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
              : _error != null ? _buildErrorWidget() : _buildEquiposList(),
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
      ElevatedButton(onPressed: _cargarEquipos, style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja), child: const Text('Reintentar')),
    ]),
  );

  Widget _buildEquiposList() {
    if (_equipos.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text('No hay equipos registrados', style: TextStyle(color: Colors.white54, fontSize: 16)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargarEquipos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _equipos.length,
        itemBuilder: (context, index) {
          final equipo = _equipos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.naranja.withOpacity(0.2), child: const Icon(Icons.sports_basketball, color: AppColors.naranja)),
              title: Text(equipo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Liga: ${equipo.nombreLiga ?? "Sin liga"}'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}