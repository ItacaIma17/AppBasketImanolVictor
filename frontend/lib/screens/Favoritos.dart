import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import 'package:tfg_appfede/models/liga.dart';
import 'package:tfg_appfede/models/equipo.dart';
import 'package:tfg_appfede/screens/Clasificacion.dart';
import 'package:tfg_appfede/screens/Equipos.dart';
import 'package:tfg_appfede/services/ligaService.dart';
import 'package:tfg_appfede/services/equipoService.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/Favoritos/TarjetaCategoriaFav.dart';
import 'package:tfg_appfede/widgets/Favoritos/TarjetaEquipoFav.dart';
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
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final ligas = await LigaService.listarLigas();
      final equipos = await EquipoService.listarEquipos();

      setState(() {
        _todasLasLigas = ligas;
        _todosLosEquipos = equipos;
        _cargando = false;
      });
    } catch (e) {
      print("❌ Error cargando datos iniciales: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Favoritos"),
      bottomNavigationBar: const BarraInferior(selectedIndex: 3),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTabs(),
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
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
      ),
    );
  }

  /// Tabs
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

 /// Ligas favoritas
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

      // Buscar liga por nombre
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
        categoriaEdad: nombre,
        categoriaNivel: '',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClasificacionPage(
                categoria: nombre,
                ligaId: ligaId,
              ),
            ),
          );
        },
      );
    },
  );
}


  /// Equipos favoritos
Widget _buildEquiposTab() {
  final favoritos = FavoritosManager().equiposFavoritos.toList();

  if (favoritos.isEmpty) {
    return _buildEmptyState('No tienes equipos favoritos');
  }

  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: favoritos.length,
    itemBuilder: (context, index) {
      final nombre = favoritos[index];

      // Buscar equipo por nombre
      final coincidencias = _todosLosEquipos
          .where((e) => e.nombre.toLowerCase() == nombre.toLowerCase())
          .toList();

      Equipo? equipo;
      if (coincidencias.isNotEmpty) {
        equipo = coincidencias.first;
      }

      final equipoId = equipo?.id ?? 0;

      return TarjetaEquipo(
        nombre: nombre,
        posicion: '-',
        proximoPartido: '-',
        rival: '-',
        esLocal: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EquipoPage(equipoId: equipoId),
            ),
          );
        },
      );
    },
  );
}


  /// Jugadores favoritos
  Widget _buildJugadoresTab() {
    final jugadores = FavoritosManager().jugadoresFavoritos.toList();

    if (jugadores.isEmpty) {
      return _buildEmptyState('No tienes jugadores favoritos');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: jugadores.length,
      itemBuilder: (context, index) {
      final nombre = jugadores[index];

        return ListTile(
          title: Text(
            nombre,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white),
          onTap: () {
            // Aquí puedes navegar a la página del jugador si la tienes
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String mensaje) {
    return Center(
      child: Text(
        mensaje,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
