// lib/screens/Equipos/ListaEquiposPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/Header.dart';

import '../../models/equipo.dart';
import '../../services/equipoService.dart';
import '../../widgets/MenuLateral.dart';
import 'DetalleEquipoPage.dart';
import 'crearEquipoPage.dart';

class ListaEquiposPage extends StatefulWidget {
  const ListaEquiposPage({super.key});

  @override
  State<ListaEquiposPage> createState() => _ListaEquiposPageState();
}

class _ListaEquiposPageState extends State<ListaEquiposPage> {
  late Future<List<Equipo>> _equiposFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  void _cargarEquipos() {
    _equiposFuture = EquipoService.listarEquipos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Equipos"),
      bottomNavigationBar: const BarraInferior(selectedIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarACrearEquipo(),
        backgroundColor: AppColors.naranja,
        child: const Icon(Icons.add, color: AppColors.blanco),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: FutureBuilder<List<Equipo>>(
                  future: _equiposFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amarilloAragon),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: AppColors.blanco),
                            ),
                            ElevatedButton(
                              onPressed: _cargarEquipos,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    final equipos = snapshot.data ?? [];
                    final filteredEquipos = _filtrarEquipos(equipos);

                    if (filteredEquipos.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay equipos disponibles',
                          style: TextStyle(color: AppColors.blanco, fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredEquipos.length,
                      itemBuilder: (context, index) {
                        final equipo = filteredEquipos[index];
                        return _buildEquipoCard(equipo);
                      },
                    );
                  },
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
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: const TextStyle(color: AppColors.blanco),
        decoration: InputDecoration(
          hintText: 'Buscar equipo...',
          hintStyle: const TextStyle(color: AppColors.blancoOpacidad70),
          prefixIcon: const Icon(Icons.search, color: AppColors.blanco),
          filled: true,
          fillColor: AppColors.blanco.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  List<Equipo> _filtrarEquipos(List<Equipo> equipos) {
    if (_searchQuery.isEmpty) return equipos;
    return equipos.where((equipo) =>
    equipo.nombre.toLowerCase().contains(_searchQuery) ||
        equipo.ciudad.toLowerCase().contains(_searchQuery) ||
        (equipo.nombreLiga?.toLowerCase().contains(_searchQuery) ?? false)
    ).toList();
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.naranja.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.sports_basketball,
                  size: 30,
                  color: AppColors.naranja,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipo.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_city, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          equipo.ciudad,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.emoji_events, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          equipo.nombreLiga ?? 'Sin liga',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          equipo.nombreEntrenador ?? 'Sin entrenador',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.people, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${equipo.numeroJugadores} jugadores',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _navegarACrearEquipo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CrearEquipoPage()),
    ).then((_) => _cargarEquipos());
  }

  void _navegarADetalle(Equipo equipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleEquipoPage(equipo: equipo),
      ),
    ).then((_) => _cargarEquipos());
  }
}