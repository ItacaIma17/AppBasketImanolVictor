import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import 'package:tfg_appfede/models/equipo.dart';
import 'package:tfg_appfede/screens/Equipos.dart';
import 'package:tfg_appfede/services/equipoService.dart';


class ClasificacionPage extends StatefulWidget {
  final String categoriaEdad;
  final String categoriaNivel;

  const ClasificacionPage({
    super.key,
    required this.categoriaEdad,
    required this.categoriaNivel,
  });

  @override
  State<ClasificacionPage> createState() => _ClasificacionPageState();
}

class _ClasificacionPageState extends State<ClasificacionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _esFavorita = false;
  List<Equipo> _equiposBD = [];
  bool _cargando = true;


@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  
  // Construir el nombre de la categoría
  final categoriaNombre = '${widget.categoriaEdad} ${widget.categoriaNivel}';
  
  // Verificar si ya está en favoritos
  _esFavorita = FavoritosManager().esCategoriaSfavorita(categoriaNombre);

  // Cargar equipos desde el backend
  _cargarEquipos();
}

void _cargarEquipos() async {
  try {
    final equipos = await EquipoService.listarEquipos(); 
    setState(() {
      _equiposBD = equipos;
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

  final List<Map<String, dynamic>> _jornadas = [
    {
      'numero': 1,
      'partidos': [
        {
          'equipoLocal': 'Basket Zaragoza',
          'equipoVisitante': 'CD Huesca',
          'resultadoLocal': 85,
          'resultadoVisitante': 72,
        },
        {
          'equipoLocal': 'Oliver Basket',
          'equipoVisitante': 'Caspe Basket',
          'resultadoLocal': 78,
          'resultadoVisitante': 80,
        },
      ],
    },
    {
      'numero': 2,
      'partidos': [
        {
          'equipoLocal': 'CD Huesca',
          'equipoVisitante': 'Oliver Basket',
          'resultadoLocal': 90,
          'resultadoVisitante': 88,
        },
        {
          'equipoLocal': 'Caspe Basket',
          'equipoVisitante': 'Basket Zaragoza',
          'resultadoLocal': 65,
          'resultadoVisitante': 92,
        },
      ],
    },
  ];

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
                  '${widget.categoriaEdad}',
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.categoriaNivel,
                  style: const TextStyle(
                    color: AppColors.blancoOpacidad70,
                    fontSize: 14,
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
              final categoriaNombre = '${widget.categoriaEdad} ${widget.categoriaNivel}';
              
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

      // Adaptamos tu card antigua a datos reales
      return _buildEquipoCard({
        'nombre': equipo.nombre,
        'puntos': equipo.puntos ?? 0,
        'victorias': equipo.victorias ?? 0,
        'derrotas': equipo.derrotas ?? 0,
      }, index + 1);
    },
  );
}


  /// Card de equipo en la clasificación
  Widget _buildEquipoCard(Map<String, dynamic> equipo, int posicion) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla del equipo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EquipoPage(nombreEquipo: equipo['nombre']),
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
                equipo['nombre'],
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
                  '${equipo['puntos']} pts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.naranja,
                  ),
                ),
                Text(
                  '${equipo['victorias']}V - ${equipo['derrotas']}D',
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

  /// Tab de resultados por jornadas
  Widget _buildResultadosTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jornadas.length,
      itemBuilder: (context, index) {
        final jornada = _jornadas[index];
        return _buildJornadaCard(jornada);
      },
    );
  }

  /// Card de una jornada con sus partidos
  Widget _buildJornadaCard(Map<String, dynamic> jornada) {
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
                  'Jornada ${jornada['numero']}',
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
            itemCount: (jornada['partidos'] as List).length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final partido = (jornada['partidos'] as List)[index];
              return _buildPartidoRow(partido);
            },
          ),
        ],
      ),
    );
  }

  /// Fila de un partido
  Widget _buildPartidoRow(Map<String, dynamic> partido) {
    return Row(
      children: [
        // Equipo local
        Expanded(
          child: Text(
            partido['equipoLocal'],
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Resultado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.grisClaro,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${partido['resultadoLocal']} - ${partido['resultadoVisitante']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Equipo visitante
        Expanded(
          child: Text(
            partido['equipoVisitante'],
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}