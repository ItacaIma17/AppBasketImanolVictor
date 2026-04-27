// lib/screens/Clasificacion.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../data/gestorFavoritos.dart';
import '../models/equipo.dart';
import '../services/equipoService.dart';
import '../widgets/Header.dart';
import '../widgets/MenuLateral.dart';
import 'equipos/DetalleEquipoPage.dart';

class ClasificacionPage extends StatefulWidget {
  final int id_categoria;
  final String categoria;


  const ClasificacionPage({
    super.key,
    required this.id_categoria,
    required this.categoria,
    
  });

  @override
  State<ClasificacionPage> createState() => _ClasificacionPageState();
}

class _ClasificacionPageState extends State<ClasificacionPage> 
  with SingleTickerProviderStateMixin{
  
  late TabController _tabController;
  List<Equipo> _equipos = [];
  bool _isLoading = true;
  String? _error;
  bool _esFavoritaLiga = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _esFavoritaLiga = FavoritosManager().esCategoriaFavorita(widget.categoria);
    _cargarClasificacion();
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarClasificacion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final todosEquipos = await EquipoService.listarEquipos();

      // Filtrar equipos por liga
      final equiposFiltrados = todosEquipos.where((e) =>
      e.nombreLiga == widget.categoria
      ).toList();

      // Ordenar por puntos (descendente)
      equiposFiltrados.sort((a, b) => (b.puntos ?? 0).compareTo(a.puntos ?? 0));

      setState(() {
        _equipos = equiposFiltrados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: HeaderApp(
        titulo: widget.categoria,
        actions: [
          IconButton(
            icon: Icon(
              _esFavoritaLiga ? Icons.star : Icons.star_border,
              color: _esFavoritaLiga ? Colors.amber : AppColors.blanco,
            ),
            onPressed: () {
              setState(() {
                _esFavoritaLiga = !_esFavoritaLiga;
                FavoritosManager().toggleCategoriaFavorita(widget.categoria);
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Column(
            children: [
              _buildTabs(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.blanco))
                    : _error != null
                        ? _buildErrorWidget()
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildClasificacion(),
                              _buildResultadosTab(),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultadosTab() {
    return const Center(
      child: Text(
        'Próximamente',
        style: TextStyle(color: Colors.white54, fontSize: 16),
      ),
    );
  }
  
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.negroOpacidad50,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: AppColors.gradienteNaranjaAmarillo,
        ),
        labelColor: AppColors.blanco,
        unselectedLabelColor: AppColors.blancoOpacidad70,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Clasificación'),
          Tab(text: 'Resultados'),
        ],
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
            onPressed: _cargarClasificacion,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildClasificacion() {
    if (_equipos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No hay equipos en esta liga',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // ← separación arriba
      itemCount: _equipos.length,
      itemBuilder: (context, index) {
        final equipo = _equipos[index];
        final esFavorito = FavoritosManager().equiposFavoritos.contains(equipo.nombre);
        return _buildEquipoRow(equipo, index + 1, esFavorito);
      },
    );
  }


  Widget _buildEquipoRow(Equipo equipo, int posicion, bool esFavorito) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EquipoDetallePage(equipo: equipo),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: posicion <= 4 ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$posicion',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipo.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PJ: ${equipo.partidosJugados ?? 0} | PG: ${equipo.partidosGanados ?? 0} | PP: ${equipo.partidosPerdidos ?? 0}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '${equipo.puntos ?? 0} pts',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.naranja,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  esFavorito ? Icons.star : Icons.star_border,
                  color: esFavorito ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (esFavorito) {
                      FavoritosManager().eliminarEquipoFavorito(equipo.nombre);
                    } else {
                      FavoritosManager().agregarEquipoFavorito(equipo.nombre);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}