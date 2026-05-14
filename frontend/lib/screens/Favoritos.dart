import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import 'package:tfg_appfede/models/liga.dart';
import 'package:tfg_appfede/models/equipo.dart';
import 'package:tfg_appfede/models/jugador.dart';
import 'package:tfg_appfede/screens/Clasificacion.dart';
import 'package:tfg_appfede/screens/JugadorDetallePage.dart';
import 'package:tfg_appfede/screens/equipos/DetalleEquipoPage.dart';
import 'package:tfg_appfede/services/ligaService.dart';
import 'package:tfg_appfede/services/equipoService.dart';
import 'package:tfg_appfede/services/jugadorService.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/Favoritos/TarjetaCategoriaFav.dart';
import 'package:tfg_appfede/widgets/Favoritos/TarjetaEquipoFav.dart';
import 'package:tfg_appfede/widgets/Favoritos/TarjetaJugadorFav.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Liga> _todasLasLigas = [];
  List<Equipo> _todosLosEquipos = [];
  List<Jugador> _todosLosJugadores = [];
  bool _cargando = true;

  final TextEditingController _buscadorJugadorController = TextEditingController();
  String _textoBusquedaJugador = '';

  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);
  _cargarTodo();
}

  Future<void> _cargarTodo() async {
    await FavoritosManager().cargarFavoritos();
    await _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final ligas = await LigaService.listarLigas();
      final equipos = await EquipoService.listarEquipos();
      final jugadores = await JugadorService.listarJugadores();

      setState(() {
        _todasLasLigas = ligas;
        _todosLosEquipos = equipos;
        _todosLosJugadores = jugadores;
        _cargando = false;
      });
    } catch (e) {
      print(" Error cargando datos iniciales: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscadorJugadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      backgroundColor: AppColors.negro,
      appBar: const HeaderApp(titulo: "Favoritos"),
      bottomNavigationBar: const BarraInferior(selectedIndex: 3),
      body: SafeArea(
          child: Column(
            children: [
              _buildTabs(),
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLigasTab(),
                          _buildEquiposTab(),
                          _buildJugadoresTab(),
                        ],
                      ),
              ),
            ],
          ),
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
          gradient: AppColors.gradienteRojoNaranja,
        ),
        labelColor: AppColors.blanco,
        unselectedLabelColor: AppColors.blancoOpacidad70,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'Ligas'),
          Tab(text: 'Equipos'),
          Tab(text: 'Jugadores'),
        ],
      ),
    );
  }

Widget _buildLigasTab() {
  final favoritas = FavoritosManager().categoriasFavoritas.toList();

  if (favoritas.isEmpty) {
    return _buildEmptyState('No tienes ligas favoritas');
  }

  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: favoritas.length,
    itemBuilder: (context, index) {
      final nombre = favoritas[index];

      final coincidencias = _todasLasLigas
          .where((l) => l.nombreLiga.toLowerCase() == nombre.toLowerCase())
          .toList();

      Liga? liga;
      if (coincidencias.isNotEmpty) {
        liga = coincidencias.first;
      }

      final ligaId = liga?.id ?? 0;

      return TarjetaCategoria(
        nombre: nombre,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClasificacionPage(
                categoria: nombre,
                id_categoria: ligaId,
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildEquiposTab() {
  final idsFavoritos = FavoritosManager().equiposFavoritos;

  print(" IDs favoritos equipos: $idsFavoritos");
  print(" Equipos cargados: ${_todosLosEquipos.map((e) => '${e.id}:${e.nombre}').toList()}");

  if (idsFavoritos.isEmpty) {
    return _buildEmptyState('No tienes equipos favoritos');
  }

  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: idsFavoritos.length,
    itemBuilder: (context, index) {
      final equipoId = idsFavoritos[index];

      final coincidencias = _todosLosEquipos
          .where((e) => e.id == equipoId)
          .toList();

      if (coincidencias.isEmpty) return const SizedBox();

      final equipo = coincidencias.first;

      return TarjetaEquipo(
        nombre: equipo.nombre,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EquipoDetallePage(equipoId: equipoId),
            ),
          );
        },
      );
    },
  );
}

 Widget _buildJugadoresTab() {
  final idsFavoritos = FavoritosManager().jugadoresFavoritos;

  if (idsFavoritos.isEmpty) {
    return _buildEmptyState('No tienes jugadores favoritos');
  }

  final jugadoresFavoritos = _todosLosJugadores
      .where((j) => idsFavoritos.contains(j.id))
      .toList();

  final jugadoresFiltrados = _textoBusquedaJugador.isEmpty
      ? jugadoresFavoritos
      : jugadoresFavoritos
          .where((j) => j.nombreCompleto
              .toLowerCase()
              .contains(_textoBusquedaJugador.toLowerCase()))
          .toList();

  return Column(
    children: [

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _buscadorJugadorController,
          onChanged: (value) => setState(() => _textoBusquedaJugador = value),
          style: const TextStyle(color: AppColors.blanco),
          decoration: InputDecoration(
            hintText: 'Buscar jugador...',
            hintStyle: const TextStyle(color: AppColors.blancoOpacidad70),
            prefixIcon: const Icon(Icons.search, color: AppColors.blancoOpacidad70),
            suffixIcon: _textoBusquedaJugador.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.blancoOpacidad70),
                    onPressed: () => setState(() {
                      _textoBusquedaJugador = '';
                      _buscadorJugadorController.clear();
                    }),
                  )
                : null,
            filled: true,
            fillColor: AppColors.negroOpacidad50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      Expanded(
        child: jugadoresFiltrados.isEmpty
            ? _buildEmptyState('No se encontraron jugadores')
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: jugadoresFiltrados.length,
                itemBuilder: (context, index) {
                  final jugador = jugadoresFiltrados[index];
                  return TarjetaJugador(
                    nombre: jugador.nombreCompleto,
                    equipo: jugador.nombreEquipo ?? 'Sin equipo',
                    edad: jugador.edad,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JugadorDetallePage(
                            jugador: jugador,
                            equipoNombre: jugador.nombreEquipo,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      }

  Widget _buildEmptyState(String mensaje) {
    return Center(
      child: Text(
        mensaje,
        style: const TextStyle(color: AppColors.grisClaro, fontSize: 16),
      ),
    );
  }
}

