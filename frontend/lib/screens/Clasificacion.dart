// lib/screens/Clasificacion.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../data/gestorFavoritos.dart';
import '../models/equipo.dart';
import '../models/partido.dart';
import '../services/equipoService.dart';
import '../services/partidoService.dart';
import '../widgets/Header.dart';
import '../widgets/MenuLateral.dart';
import 'equipos/DetalleEquipoPage.dart';
// ✅ FIX nav: para abrir el detalle del partido desde la pestaña Resultados
import 'DetallesPartido.dart';

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
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String? _error;
  bool _esFavoritaLiga = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final todosPartidos = await PartidoService.listarPartidos();

      // Filtrar equipos por liga
      final equiposFiltrados = todosEquipos.where((e) =>
      e.nombreLiga == widget.categoria
      ).toList();

      // Filtrar partidos por liga
      final partidosFiltrados = todosPartidos
          .where((p) => p.ligaId == widget.id_categoria)
          .toList();

      // Ordenar por puntos (descendente)
      equiposFiltrados.sort((a, b) => (b.puntos ?? 0).compareTo(a.puntos ?? 0));

      setState(() {
        _equipos = equiposFiltrados;
        _partidos = partidosFiltrados;
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
                              _buildEquiposTab(),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquiposTab() {
    if (_equipos.isEmpty) {
      return const Center(
        child: Text('No hay equipos en esta liga',
            style: TextStyle(color: Colors.white54, fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _equipos.length,
      itemBuilder: (context, i) {
        final eq = _equipos[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.naranja.withOpacity(0.15),
              child: const Icon(Icons.sports_basketball, color: AppColors.naranja),
            ),
            title: Text(eq.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${eq.ciudad} · ${eq.numeroJugadores} jugadores'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EquipoDetallePage(equipo: eq)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultadosTab() {
    if (_partidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No hay resultados disponibles',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Agrupar partidos por jornada
    final jornadasMap = <int?, List<Partido>>{};
    for (var partido in _partidos) {
      final jornada = partido.jornada ?? 0;
      if (!jornadasMap.containsKey(jornada)) {
        jornadasMap[jornada] = [];
      }
      jornadasMap[jornada]!.add(partido);
    }

    // Ordenar jornadas de menor a mayor
    final jornadasOrdenadas = jornadasMap.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jornadasOrdenadas.length,
      itemBuilder: (context, index) {
        final jornada = jornadasOrdenadas[index];
        final partidos = jornadasMap[jornada]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la jornada
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Jornada $jornada',
                style: const TextStyle(
                  color: AppColors.blanco,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Partidos de la jornada
            ...partidos.map((partido) => _buildPartidoResultado(partido)),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildPartidoResultado(Partido partido) {
    final String resultado;
    if (partido.esFinalizado) {
      resultado = '${partido.puntosLocal} - ${partido.puntosVisitante}';
    } else {
      resultado = '-';
    }

    // ✅ FIX nav: la tarjeta del partido abre su detalle (DetallePartidoPage)
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetallePartidoPage(partido: partido),
          ),
        ),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    partido.nombreLocal,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    resultado,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: partido.esFinalizado ? AppColors.naranja : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    partido.nombreVisitante,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estado: ${partido.estado}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (partido.direccionPabellon.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                partido.direccionPabellon,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
      ), // cierra InkWell del FIX nav
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
          Tab(text: 'Equipos'),
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