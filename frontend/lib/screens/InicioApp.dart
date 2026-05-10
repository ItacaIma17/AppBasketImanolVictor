import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import 'package:tfg_appfede/models/equipo.dart';
import 'package:tfg_appfede/models/jugador.dart';
import 'package:tfg_appfede/models/liga.dart';
import 'package:tfg_appfede/models/partido.dart';
import 'package:tfg_appfede/models/usuario.dart';
import 'package:tfg_appfede/screens/Admin/GestionEquiposPage.dart';
import 'package:tfg_appfede/screens/Admin/GestionJugadoresPage.dart';
import 'package:tfg_appfede/screens/Clasificacion.dart';
import 'package:tfg_appfede/screens/DetallesPartido.dart';
import 'package:tfg_appfede/screens/Ligas.dart';
import 'package:tfg_appfede/screens/equipos/DetalleEquipoPage.dart';
import 'package:tfg_appfede/screens/JugadorDetallePage.dart';
import 'package:tfg_appfede/screens/Liga/LigaService.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/services/equipoService.dart';
import 'package:tfg_appfede/services/jugadorService.dart';
import 'package:tfg_appfede/services/partidoService.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';
import 'package:tfg_appfede/models/role.dart';
import 'package:tfg_appfede/screens/Admin/PanelAdminPage.dart';
import 'package:tfg_appfede/screens/Entrenador/PanelEntrenadorPage.dart';
import 'package:tfg_appfede/screens/Entrenador/MiEquipoPage.dart';
import 'package:tfg_appfede/screens/Entrenador/MisPartidosEntrenadorPage.dart';
import 'package:tfg_appfede/screens/Entrenador/SeleccionarPartidoEntrenadorPage.dart';
import 'package:tfg_appfede/screens/arbitros/MisPartidosArbitroPage.dart';
import 'package:tfg_appfede/screens/arbitros/SeleccionarPartidoActaPage.dart';
import 'package:tfg_appfede/screens/equipos/SolicitarEquipoPage.dart';
import 'package:tfg_appfede/screens/Tienda.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  Usuario? _usuario;
  List<Liga> _ligas = [];
  List<Partido> _partidos = [];
  List<Equipo> _equipos = [];
  List<Jugador> _jugadores = [];
  bool _cargando = true;

  final TextEditingController _searchCtrl = TextEditingController();
  bool _buscando = false;
  List<_ResultadoBusqueda> _resultados = [];

  final FavoritosManager _favManager = FavoritosManager();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _favManager.cargarFavoritos();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      await _favManager.cargarFavoritos();
      final results = await Future.wait([
        AutenticacionService.obtenerUsuarioActual().catchError((_) => null),
        LigaService.listarLigas().catchError((_) => <Liga>[]),
        PartidoService.listarPartidos().catchError((_) => <Partido>[]),
        EquipoService.listarEquipos().catchError((_) => <Equipo>[]),
        JugadorService.listarJugadores().catchError((_) => <Jugador>[]),
      ]);

      final usuario = results[0] as Usuario?;
      var partidosResult = results[2] as List<Partido>;

      if (usuario != null && usuario.isEntrenador) {
        try {
          partidosResult = await PartidoService.getPartidosEntrenador();
        } catch (_) {
          partidosResult = <Partido>[];
        }
      }

      if (mounted) {
        setState(() {
          _usuario = usuario;
          _ligas = (results[1] as List<Liga>).take(5).toList();
          _partidos = partidosResult;
          _equipos = results[3] as List<Equipo>;
          _jugadores = results[4] as List<Jugador>;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Equipo? _getEquipoById(int? equipoId) {
    if (equipoId == null) return null;
    try {
      return _equipos.firstWhere((e) => e.id == equipoId);
    } catch (e) {
      return null;
    }
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() { _buscando = false; _resultados = []; });
      return;
    }

    setState(() => _buscando = true);
    final res = <_ResultadoBusqueda>[];

    for (final l in _ligas) {
      if (l.nombreLiga.toLowerCase().contains(q)) {
        res.add(_ResultadoBusqueda(
          tipo: 'Liga',
          nombre: l.nombreLiga,
          subtitulo: l.descripcion ?? '',
          objeto: l,
          icono: Icons.emoji_events,
        ));
      }
    }

    for (final e in _equipos) {
      if (e.nombre.toLowerCase().contains(q) || e.ciudad.toLowerCase().contains(q)) {
        res.add(_ResultadoBusqueda(
          tipo: 'Equipo',
          nombre: e.nombre,
          subtitulo: e.ciudad,
          objeto: e,
          icono: Icons.sports_basketball,
        ));
      }
    }

    for (final j in _jugadores) {
      if (j.nombreCompleto.toLowerCase().contains(q) ||
          j.posicion.toLowerCase().contains(q)) {
        res.add(_ResultadoBusqueda(
          tipo: 'Jugador',
          nombre: j.nombreCompleto,
          subtitulo: '${j.posicion} · ${j.nombreEquipo ?? ""}',
          objeto: j,
          icono: Icons.person,
        ));
      }
    }

    setState(() { _resultados = res.take(15).toList(); });
  }

  void _onResultadoTap(_ResultadoBusqueda r) {
    _searchCtrl.clear();
    setState(() { _buscando = false; _resultados = []; });
    FocusScope.of(context).unfocus();

    if (r.objeto is Liga) {
      final liga = r.objeto as Liga;
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          ClasificacionPage(id_categoria: liga.id ?? 0, categoria: liga.nombreLiga)));
    } else if (r.objeto is Equipo) {
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          EquipoDetallePage(equipo: r.objeto as Equipo)));
    } else if (r.objeto is Jugador) {
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          JugadorDetallePage(jugador: r.objeto as Jugador)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      bottomNavigationBar: const BarraInferior(selectedIndex: 2),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_buscando && _searchCtrl.text.isEmpty) {
            setState(() { _buscando = false; _resultados = []; });
          }
        },
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
          child: SafeArea(
            child: Stack(
              children: [
                _cargando
                    ? const Center(child: CircularProgressIndicator(
                    color: AppColors.amarilloAragon))
                    : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  color: AppColors.naranja,
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverHeader(),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildBuscador(),
                            const SizedBox(height: 20),
                            _buildBienvenida(),
                            const SizedBox(height: 20),
                            _buildFavoritosRapidos(),
                            const SizedBox(height: 20),
                            _buildAccesosRapidos(),
                            const SizedBox(height: 24),
                            _buildProximosPartidos(),
                            const SizedBox(height: 24),
                            _buildLigasDestacadas(),
                            const SizedBox(height: 24),
                            _buildEstadisticasRapidas(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_buscando)
                  Positioned(
                    top: 56,
                    left: 16,
                    right: 16,
                    child: _buildResultadosBusqueda(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.blanco),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/LogoFAB.png', height: 26,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.sports_basketball, color: AppColors.naranja, size: 22)),
          const SizedBox(width: 8),
          const Text('FAB',
              style: TextStyle(color: AppColors.blanco, fontSize: 18,
                  fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.blanco),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Sin notificaciones nuevas'),
              behavior: SnackBarBehavior.floating,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildBuscador() {
    return Hero(
      tag: 'searchbar',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: AppColors.blanco, fontSize: 15),
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: 'Buscar equipos, jugadores, ligas...',
            hintStyle: TextStyle(color: AppColors.blanco.withOpacity(0.5), fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.naranja, size: 22),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.grisClaro, size: 18),
              onPressed: () {
                _searchCtrl.clear();
                setState(() { _buscando = false; _resultados = []; });
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildResultadosBusqueda() {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 360),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _resultados.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('Sin resultados',
                style: TextStyle(color: AppColors.grisClaro)),
          ),
        )
            : ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _resultados.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
          itemBuilder: (_, i) {
            final r = _resultados[i];
            return ListTile(
              dense: true,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _colorTipo(r.tipo).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(r.icono, color: _colorTipo(r.tipo), size: 18),
              ),
              title: Text(r.nombre,
                  style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              subtitle: Text(
                '${r.tipo} · ${r.subtitulo}',
                style: const TextStyle(
                    color: AppColors.grisClaro, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.naranja, size: 14),
              onTap: () => _onResultadoTap(r),
            );
          },
        ),
      ),
    );
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'Liga': return AppColors.amarilloAragon;
      case 'Equipo': return AppColors.rojoAragon;
      case 'Jugador': return Colors.blue.shade400;
      default: return AppColors.naranja;
    }
  }

  Widget _buildBienvenida() {
    final hora = DateTime.now().hour;
    final saludo = hora < 12 ? 'Buenos días' : hora < 20 ? 'Buenas tardes' : 'Buenas noches';
    final nombre = _usuario?.nombre ?? 'Aficionado';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.gradienteRojoNaranja,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : '',
                style: const TextStyle(color: AppColors.blanco, fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¡$saludo, $nombre!',
                    style: const TextStyle(color: AppColors.blanco, fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(
                  DateFormat('EEEE, d MMMM', 'es_ES').format(DateTime.now()),
                  style: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
                ),
                if (_usuario?.role != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.naranja.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.naranja.withOpacity(0.5)),
                    ),
                    child: Text(_usuario!.role!.displayName,
                        style: const TextStyle(
                            color: AppColors.naranja, fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_proximos.length}', style: const TextStyle(
                  color: AppColors.amarilloAragon, fontSize: 20,
                  fontWeight: FontWeight.bold)),
              const Text('próximos', style: TextStyle(
                  color: AppColors.grisClaro, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritosRapidos() {
    final equiposFav = _favManager.equiposFavoritos;
    final jugadoresFav = _favManager.jugadoresFavoritos;
    final ligasFav = _favManager.categoriasFavoritas;

    if (equiposFav.isEmpty && jugadoresFav.isEmpty && ligasFav.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion('Tus Favoritos', Icons.star, AppColors.amarilloAragon),
        const SizedBox(height: 10),
        SizedBox(
          height: 82,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...ligasFav.map((nombre) {
                final liga = _ligas.firstWhere(
                      (l) => l.nombreLiga == nombre,
                  orElse: () => Liga(
                    id: null,
                    nombreLiga: nombre,
                    numeroEquipos: 0,
                    numeroEquiposRegistrados: 0,
                    descripcion: '',
                  ),
                );
                return _buildChipFavorito(
                    nombre, Icons.emoji_events, AppColors.amarilloAragon,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        ClasificacionPage(id_categoria: liga.id ?? 0,
                            categoria: nombre))));
              }),
              ...equiposFav.map((equipoId) {
                final equipo = _equipos.firstWhere(
                      (e) => e.id == equipoId,
                  orElse: () => Equipo(
                    id: equipoId,
                    nombre: 'Equipo $equipoId',
                    ciudad: '',
                    nombreEstadio: '',
                    entrenadorId: null,
                    ligaId: null,
                  ),
                );
                return _buildChipFavorito(
                    equipo.nombre, Icons.sports_basketball, AppColors.rojoAragon,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        EquipoDetallePage(equipoId: equipoId))));
              }),
              ...jugadoresFav.map((jugadorId) {
                final jugador = _jugadores.firstWhere(
                      (j) => j.id == jugadorId,
                  orElse: () => Jugador(
                    id: jugadorId,
                    username: '',
                    email: '',
                    nombre: 'Jugador',
                    apellido: '',
                    edad: 0,
                    posicion: '',
                    dorsal: 0,
                    altura: 0.0,
                    peso: 0.0,
                    puntosTotales: 0,
                    rebotesTotales: 0,
                    asistenciasTotales: 0,
                    robosTotales: 0,
                    partidosJugados: 0,
                    codigoJugador: null,
                    verificado: false,
                    tieneEquipo: false,
                    equipoId: null,
                    nombreEquipo: null,
                  ),
                );
                return _buildChipFavorito(
                    jugador.nombreCompleto, Icons.person, Colors.blue.shade400,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        JugadorDetallePage(jugador: jugador, equipoNombre: jugador.nombreEquipo))));
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipFavorito(String nombre, IconData icono, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: color, size: 22),
            const SizedBox(height: 6),
            Text(nombre,
                style: TextStyle(color: color, fontSize: 10,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesosRapidos() {
    final rol = _usuario?.role;
    final accesos = _accesosPorRol(rol);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion('Acceso Rápido', Icons.flash_on, AppColors.naranja),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: accesos
              .map((a) => _buildAccesoCard(a.icon, a.label, a.color, a.onTap))
              .toList(),
        ),
      ],
    );
  }

  List<_AccesoRapido> _accesosPorRol(Role? rol) {
    final base = <_AccesoRapido>[
      _AccesoRapido(
        Icons.emoji_events,
        'Ligas',
        AppColors.rojoAragon,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LigasPage())),
      ),
    ];

    switch (rol) {
      case Role.ADMIN:
        return [
          _AccesoRapido(
            Icons.admin_panel_settings,
            'Panel',
            AppColors.amarilloAragon,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PanelAdminPage())),
          ),
          _AccesoRapido(
            Icons.sports_basketball,
            'Equipos',
            AppColors.naranja,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionEquiposPage())),
          ),
          _AccesoRapido(
            Icons.person_search,
            'Jugadores',
            Colors.blue.shade600,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionJugadoresPage())),
          ),
          ...base,
        ];

      case Role.ENTRENADOR:
        final entrenador = AutenticacionService.entrenadorActual;
        final tieneEquipo = entrenador?.tieneEquipo ?? false;
        return [
          _AccesoRapido(
            Icons.dashboard,
            'Panel',
            AppColors.amarilloAragon,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PanelEntrenadorPage())),
          ),
          if (tieneEquipo)
            _AccesoRapido(
              Icons.sports_basketball,
              'Mi Equipo',
              AppColors.naranja,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MiEquipoPage())),
            )
          else
            _AccesoRapido(
              Icons.vpn_key,
              'Solicitar',
              AppColors.amarilloAragon,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SolicitarEquipoPage())),
            ),
          if (tieneEquipo)
            _AccesoRapido(
              Icons.line_style,
              'Alineación',
              AppColors.rojoAragon,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SeleccionarPartidoEntrenadorPage())),
            ),
          if (tieneEquipo)
            _AccesoRapido(
              Icons.history,
              'Mis Partidos',
              Colors.blue.shade600,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MisPartidosEntrenadorPage())),
            ),
          ...base,
        ];

      case Role.ARBITRO:
        return [
          _AccesoRapido(
            Icons.assignment,
            'Designaciones',
            AppColors.amarilloAragon,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MisPartidosArbitroPage())),
          ),
          _AccesoRapido(
            Icons.description,
            'Subir Acta',
            AppColors.naranja,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SeleccionarPartidoActaPage())),
          ),
          ...base,
        ];

      case Role.JUGADOR:
      case Role.AFICIONADO:
      case Role.USUARIO:
      default:
        return [
          ...base,
          _AccesoRapido(
            Icons.sports_basketball,
            'Equipos',
            AppColors.naranja,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionEquiposPage())),
          ),
          _AccesoRapido(
            Icons.person_search,
            'Jugadores',
            Colors.blue.shade600,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionJugadoresPage())),
          ),
          _AccesoRapido(
            Icons.shopping_bag,
            'Tienda',
            AppColors.rojoAragon,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TiendaPage())),
          ),
        ];
    }
  }

  Widget _buildAccesoCard(IconData icono, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(color: color, fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  List<Partido> get _proximos => _partidos
      .where((p) => p.estado == 'PROGRAMADO')
      .take(3)
      .toList();

  Widget _buildProximosPartidos() {
    if (_proximos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion('Próximos Partidos', Icons.schedule, AppColors.blanco),
        const SizedBox(height: 10),
        ..._proximos.map(_buildTarjetaPartidoMini),
      ],
    );
  }

  Widget _buildTarjetaPartidoMini(Partido p) {

    final equipoLocal = _getEquipoById(p.equipoLocalId);
    final equipoVisitante = _getEquipoById(p.equipoVisitanteId);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => DetallePartidoPage(partido: p))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [

            GestureDetector(
              onTap: () {
                if (equipoLocal != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EquipoDetallePage(equipo: equipoLocal),
                    ),
                  );
                }
              },
              child: _buildEquipoBola(p.nombreLocal),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('vs',
                      style: TextStyle(color: AppColors.blanco,
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(
                    '${p.fecha} · ${p.hora}',
                    style: const TextStyle(color: AppColors.grisClaro, fontSize: 10),
                  ),
                  if (p.jornada != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.rojoAragon.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('J${p.jornada}',
                          style: const TextStyle(
                              color: AppColors.blanco, fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                if (equipoVisitante != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EquipoDetallePage(equipo: equipoVisitante),
                    ),
                  );
                }
              },
              child: _buildEquipoBola(p.nombreVisitante),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipoBola(String nombre) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.rojoAragon.withOpacity(0.3),
            child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.blanco, fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(nombre,
              style: const TextStyle(color: AppColors.blanco, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildLigasDestacadas() {
    if (_ligas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildTituloSeccion(
                'Ligas Activas', Icons.emoji_events, AppColors.blanco)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const LigasPage())),
              child: const Text('Ver todas',
                  style: TextStyle(color: AppColors.naranja, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._ligas.map((liga) => _buildFilaLiga(liga)),
      ],
    );
  }

  Widget _buildFilaLiga(Liga liga) {
    final esFav = _favManager.esCategoriaFavorita(liga.nombreLiga);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
          ClasificacionPage(id_categoria: liga.id ?? 0, categoria: liga.nombreLiga))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteNaranjaAmarillo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.emoji_events,
                  color: AppColors.blanco, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(liga.nombreLiga,
                      style: const TextStyle(color: AppColors.blanco,
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  if (liga.descripcion != null && liga.descripcion!.isNotEmpty)
                    Text(liga.descripcion!,
                        style: const TextStyle(
                            color: AppColors.grisClaro, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                esFav ? Icons.star : Icons.star_border,
                color: esFav ? AppColors.amarilloAragon : AppColors.grisClaro,
                size: 20,
              ),
              onPressed: () {
                _favManager.toggleCategoriaFavorita(liga.nombreLiga);
                setState(() {});
              },
            ),
            const Icon(Icons.chevron_right, color: AppColors.naranja, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasRapidas() {
    final total = _partidos.length;
    final finalizados = _partidos.where((p) => p.estado == 'FINALIZADO').length;
    final enCurso = _partidos.where((p) => p.estado == 'EN_CURSO').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion('Esta Temporada', Icons.bar_chart, AppColors.blanco),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMini('$total', 'Partidos', AppColors.blanco),
              _buildDivider(),
              _buildStatMini('$finalizados', 'Jugados', Colors.green.shade400),
              _buildDivider(),
              _buildStatMini('$enCurso', 'En Curso', AppColors.naranja),
              _buildDivider(),
              _buildStatMini('${_proximos.length}', 'Próximos', Colors.blue.shade400),
              _buildDivider(),
              _buildStatMini('${_equipos.length}', 'Equipos', AppColors.amarilloAragon),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1));

  Widget _buildTituloSeccion(String titulo, IconData icono, Color color) {
    return Row(
      children: [
        Container(
          width: 3, height: 18,
          decoration: BoxDecoration(
              gradient: AppColors.gradienteRojoNaranja,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Icon(icono, color: AppColors.naranja, size: 16),
        const SizedBox(width: 6),
        Text(titulo,
            style: TextStyle(color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatMini(String valor, String label, Color color) {
    return Column(
      children: [
        Text(valor,
            style: TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    );
  }
}

class _ResultadoBusqueda {
  final String tipo;
  final String nombre;
  final String subtitulo;
  final dynamic objeto;
  final IconData icono;

  _ResultadoBusqueda({
    required this.tipo,
    required this.nombre,
    required this.subtitulo,
    required this.objeto,
    required this.icono,
  });
}

class _AccesoRapido {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _AccesoRapido(this.icon, this.label, this.color, this.onTap);
}
