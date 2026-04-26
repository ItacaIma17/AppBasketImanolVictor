import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import 'package:tfg_appfede/models/partido.dart';
import 'package:tfg_appfede/screens/Equipos.dart';
import 'package:tfg_appfede/services/equipoService.dart';
import '../models/equipo.dart';
import 'package:tfg_appfede/services/PartidoService.dart';


class ClasificacionPage extends StatefulWidget {
  final String categoria;
  final int ligaId;

  const ClasificacionPage({
    super.key,
    required this.categoria,
    required this.ligaId,
  });

  @override
  State<ClasificacionPage> createState() => _ClasificacionPageState();
}

class _ClasificacionPageState extends State<ClasificacionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _esFavorita = false;
  List<Equipo> _equiposBD = [];
  List<Partido> _partidos = [];
  bool _cargando = true;


@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  
  // Construir el nombre de la categoría
  final categoriaNombre = '${widget.categoria}';
  
  // Verificar si ya está en favoritos
  _esFavorita = FavoritosManager().esCategoriaSfavorita(categoriaNombre);

    // Cargar equipos desde el backend
    _cargarEquipos();
  }

void _cargarEquipos() async {
  try {
    final equipos = await EquipoService.listarEquiposPorLiga(widget.ligaId);

    // Cargar partidos de cada equipo
    final List<Partido> todosPartidos = [];

    for (final equipo in equipos) {
      print('Cargando partidos para equipo: ${equipo.nombre} (ID: ${equipo.id})');

      final local = await PartidoService.obtenerPartidosPorEquipoLocal(equipo.id ?? 0);
      final visitante = await PartidoService.obtenerPartidosPorEquipoVisitante(equipo.id ?? 0);

      print('Partidos como local: ${local.length}');
      print('Partidos como visitante: ${visitante.length}');

      todosPartidos.addAll(local);
      todosPartidos.addAll(visitante);
    }
      // Eliminar duplicados usando el id (String)
      final Map<String, Partido> partidosUnicos = {};
      for (final partido in todosPartidos) {
        if (!partidosUnicos.containsKey(partido.id)) {
          partidosUnicos[partido.id] = partido;
        }
      }

      // Convertir a lista y ordenar por fecha
      final partidos = partidosUnicos.values.toList();

      partidos.sort((a, b) {
        final fechaA = DateTime.tryParse(a.fecha) ?? DateTime.now();
        final fechaB = DateTime.tryParse(b.fecha) ?? DateTime.now();
        return fechaA.compareTo(fechaB);
      });

      print('Total partidos únicos cargados: ${partidos.length}');
      for (final p in partidos) {
        print('${p.nombreLocal} vs ${p.nombreVisitante} (${p.fecha} ${p.hora})');
      }

      setState(() {
        _equiposBD = equipos;
        _partidos = partidos;
        _cargando = false;
      });
    } catch (e) {
      print("Error cargando equipos: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Agrupar partidos por fecha (jornada)
  Map<String, List<Partido>> _agruparPartidosPorFecha() {
    final Map<String, List<Partido>> agrupados = {};
    for (final partido in _partidos) {
      final fecha = partido.fecha ?? 'Sin fecha';
      if (!agrupados.containsKey(fecha)) {
        agrupados[fecha] = [];
      }
      agrupados[fecha]!.add(partido);
    }
    return agrupados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con título y botón favorito
              _buildHeader(),

              // Tabs para alternar entre clasificación y resultados
              _buildTabs(),

              // Contenido según la tab seleccionada
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildClasificacionTab(),
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

  /// Header con título y botón de favorito
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.negro,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón atrás
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
            onPressed: () => Navigator.pop(context),
          ),

          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.categoria}',
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Botón de favorito
          IconButton(
            icon: Icon(
              _esFavorita ? Icons.star : Icons.star_border,
              color: _esFavorita ? AppColors.amarilloAragon : AppColors.blanco,
              size: 28,
            ),
            onPressed: () {
              // Construir el nombre de la categoría
              final categoriaNombre = '${widget.categoria}';
              
              // Alternar favorito
              setState(() {
                _esFavorita = !_esFavorita;
                FavoritosManager().toggleCategoriaFavorita(categoriaNombre);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_esFavorita
                      ? 'Liga añadida a favoritos'
                      : 'Liga eliminada de favoritos'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Tabs para alternar entre clasificación y resultados
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'Clasificación'),
          Tab(text: 'Resultados'),
        ],
      ),
    );
  }

  /// Tab de clasificación
  Widget _buildClasificacionTab() {
    // Mientras carga datos del backend
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blanco),
      );
    }

    // Si no hay equipos en la BD
    if (_equiposBD.isEmpty) {
      return const Center(
        child: Text(
          "No hay equipos registrados",
          style: TextStyle(
            color: AppColors.blanco,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Mostrar equipos reales
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _equiposBD.length,
      itemBuilder: (context, index) {
        final equipo = _equiposBD[index];

      // Pasar el equipo completo a _buildEquipoCard
      return _buildEquipoCard(equipo, index + 1);
    },
  );
}


  /// Card de equipo en la clasificación
  Widget _buildEquipoCard(Equipo equipo, int posicion) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla del equipo pasando el equipoId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EquipoPage(equipoId: equipo.id ?? 0),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Posición
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: posicion <= 3
                    ? AppColors.gradienteNaranjaAmarillo
                    : null,
                color: posicion > 3 ? AppColors.grisClaro : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$posicion',
                  style: TextStyle(
                    color: posicion <= 3 ? AppColors.blanco : AppColors.negro,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Nombre del equipo
            Expanded(
              child: Text(
                equipo.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Estadísticas
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${equipo.puntosFavor?.toStringAsFixed(0)} pts favor - ${equipo.puntosContra?.toStringAsFixed(0)} pts contra',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.naranja,
                  ),
                ),
                Text(
                  '${equipo.victorias}V - ${equipo.derrotas}D',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tab de resultados por fechas
  Widget _buildResultadosTab() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blanco),
      );
    }

    if (_partidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.sports_basketball, size: 80, color: AppColors.blancoOpacidad70),
            SizedBox(height: 16),
            Text(
              'No hay partidos registrados',
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final agrupados = _agruparPartidosPorFecha();
    final fechas = agrupados.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fechas.length,
      itemBuilder: (context, index) {
        final fecha = fechas[index];
        final partidosDeFecha = agrupados[fecha] ?? [];
        return _buildJornadaCard(fecha, partidosDeFecha);
      },
    );
  }

  /// Card de una jornada/fecha con sus partidos
  Widget _buildJornadaCard(String fecha, List<Partido> partidos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la jornada
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.gradienteNaranjaAmarillo,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.blanco, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Fecha: $fecha',
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de partidos
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: partidos.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final partido = partidos[index];
              return _buildPartidoRow(partido);
            },
          ),
        ],
      ),
    );
  }
  Widget _buildPartidoRow(Partido partido) {
    final bool esPendiente = partido.estado == 'PROGRAMADO';

    final String resultado = esPendiente
        ? 'Por jugar'
        : '${partido.puntosLocal} - ${partido.puntosVisitante}';

    final bool esResultadoDisponible = !esPendiente;

    final String nombreLocal = partido.nombreLocal;
    final String nombreVisitante = partido.nombreVisitante;
    final String hora = partido.hora;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nombreLocal,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.negro,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: esResultadoDisponible
                  ? AppColors.gradienteNaranjaAmarillo.colors.first.withOpacity(0.2)
                  : AppColors.grisClaro,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: esResultadoDisponible
                    ? AppColors.naranja
                    : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              resultado,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: esResultadoDisponible ? AppColors.naranja : Colors.grey,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              nombreVisitante,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.negro,
              ),
            ),
          ),

          if (hora.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                hora,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}