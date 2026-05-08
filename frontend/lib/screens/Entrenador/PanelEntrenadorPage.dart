// lib/screens/Entrenador/PanelEntrenadorPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/EquipoEntrenador.dart';
import '../../models/jugador.dart';
import '../../models/partido.dart';
import '../../services/entrenadorService.dart';
import '../../services/equipoService.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import '../equipos/ConfiguracionPage.dart';
import 'JugadoresEquipoPage.dart';
import '../equipos/SolicitarEquipoPage.dart';
import 'MiEquipoPage.dart';
import 'PresentarAlinecionPage.dart';
import 'SeleccionarPartidoEntrenadorPage.dart';
import 'ProximosPartidosPage.dart';
import 'EstadisticasEquipoPage.dart';

class PanelEntrenadorPage extends StatefulWidget {
  const PanelEntrenadorPage({super.key});

  @override
  State<PanelEntrenadorPage> createState() => _PanelEntrenadorPageState();
}

class _PanelEntrenadorPageState extends State<PanelEntrenadorPage> {
  bool _isLoading = true;
  bool _tieneEquipo = false;
  EquipoEntrenador? _miEquipo;
  List<Jugador> _jugadores = [];
  List<Partido> _proximosPartidos = [];
  String? _error;

  // ============================================================
  // FUNCIONES AUXILIARES PARA FECHAS
  // ============================================================

  /// Convierte fecha dd/MM/yyyy a DateTime de forma segura
  DateTime? _parseFecha(String fechaStr) {
    if (fechaStr.isEmpty) return null;
    try {
      final parts = fechaStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      print('Error parseando fecha $fechaStr: $e');
      return null;
    }
  }

  /// Compara dos fechas para ordenar
  int _compareFechas(String fechaA, String fechaB) {
    final dateA = _parseFecha(fechaA);
    final dateB = _parseFecha(fechaB);
    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    return dateA.compareTo(dateB);
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final equipoData = await EntrenadorService.obtenerMiEquipo();
      final equipo = EquipoEntrenador.fromJson(equipoData);

      if (equipo.tieneEquipo) {
        final jugadores = await EquipoService.getJugadoresEquipo(equipo.equipoId);
        final partidos = await PartidoService.getProximosPartidosEquipo(equipo.equipoId);

        // Ordenar partidos por fecha
        partidos.sort((a, b) => _compareFechas(a.fecha, b.fecha));

        setState(() {
          _miEquipo = equipo;
          _jugadores = jugadores;
          _proximosPartidos = partidos;
          _tieneEquipo = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _tieneEquipo = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() {
        _tieneEquipo = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Panel de Entrenador"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tieneEquipo && _miEquipo != null
              ? _buildMiEquipoWidget()
              : _buildSinEquipoWidget(),
        ),
      ),
    );
  }

  Widget _buildSinEquipoWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SolicitarEquipoPage()),
                ).then((_) => _cargarDatos());
              },
              icon: const Icon(Icons.vpn_key),
              label: const Text('Solicitar Equipo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiEquipoWidget() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEquipoHeader(),
            const SizedBox(height: 16),
            _buildEstadisticasRapidas(),
            const SizedBox(height: 16),
            _buildMenuPrincipal(),
            const SizedBox(height: 16),
            if (_proximosPartidos.isNotEmpty) _buildProximosPartidos(),
            const SizedBox(height: 16),
            _buildAccionesRapidas(),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipoHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, size: 50, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                _miEquipo!.nombreEquipo,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              if (_miEquipo!.nombreLiga != null)
                Text(_miEquipo!.nombreLiga!, style: const TextStyle(color: Colors.white70)),
              if (_miEquipo!.nombreEstadio != null)
                Text(_miEquipo!.nombreEstadio!, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  'Entrenador: ${_miEquipo!.nombreCompletoEntrenador}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticasRapidas() {
    return Row(
      children: [
        Expanded(child: _buildEstadisticaCard(Icons.people, 'Jugadores', '${_jugadores.length}', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildEstadisticaCard(Icons.calendar_today, 'Partidos', '${_proximosPartidos.length}', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildEstadisticaCard(Icons.emoji_events, 'Victorias', '0', Colors.orange)),
      ],
    );
  }

  Widget _buildEstadisticaCard(IconData icon, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // En PanelEntrenadorPage.dart - Reducir tamaño de botones

  Widget _buildMenuPrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  gradient: AppColors.gradienteRojoNaranja,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('GESTIÓN DEL EQUIPO',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.8)),
            ],
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            _buildMenuCard('Mi Equipo', Icons.people, Colors.blue,
                    () => _navigateTo(const MiEquipoPage())),
            _buildMenuCard('Jugadores', Icons.sports_basketball, Colors.green,
                    () => _navigateTo(JugadoresEquipoPage(equipoId: _miEquipo!.equipoId))),
            _buildMenuCard('Partidos', Icons.calendar_today, Colors.orange,
                    () => _navigateTo(const ProximosPartidosPage())),
            _buildMenuCard('Alineación', Icons.line_style, Colors.purple,
                    () => _navigateTo(const SeleccionarPartidoEntrenadorPage())),
            _buildMenuCard('Estadísticas', Icons.bar_chart, Colors.red,
                    () => _navigateTo(const EstadisticasEquipoPage())),
            _buildMenuCard('Ajustes', Icons.settings, Colors.grey,
                    () => _navigateTo(const ConfiguracionPage())),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.chevron_right, size: 16, color: color.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProximosPartidos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRÓXIMOS PARTIDOS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        ..._proximosPartidos.take(3).map((partido) => _buildPartidoCard(partido)),
      ],
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final esLocal = partido.nombreLocal == _miEquipo!.nombreEquipo;
    final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;

    // Usar la fecha directamente (ya viene formateada como dd/MM/yyyy)
    final fechaFormateada = partido.fecha;
    final ubicacion = partido.pabellon.isNotEmpty ? partido.pabellon :
    (partido.direccionPabellon.isNotEmpty ? partido.direccionPabellon : "Sin ubicación");

    // Determinar si es hoy (sin usar DateTime.parse)
    final hoy = DateTime.now();
    final fechaParts = partido.fecha.split('/');
    bool esHoy = false;
    if (fechaParts.length == 3) {
      final dia = int.tryParse(fechaParts[0]);
      final mes = int.tryParse(fechaParts[1]);
      final anyo = int.tryParse(fechaParts[2]);
    if (dia != null && mes != null && anyo != null) {
    esHoy = dia == hoy.day && mes == hoy.month && anyo == hoy.year;
    }
    }

    return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Container(
    decoration: esHoy ? BoxDecoration(
    border: Border.all(color: Colors.green, width: 2),
    borderRadius: BorderRadius.circular(12),
    ) : null,
    child: ListTile(
    leading: const Icon(Icons.sports_basketball, color: AppColors.naranja),
    title: Text('vs $rival'),
    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('📅 $fechaFormateada - ${partido.hora}'),
    Text('📍 $ubicacion'),
    ],
    ),
    trailing: ElevatedButton(
    onPressed: () => _navigateTo(PresentarAlineacionPage(
    partido: partido,
    esLocal: esLocal,
    )),
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.naranja,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: const Text('Alineación'),
    ),
    ),
    ),
    );
  }

  Widget _buildAccionesRapidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  gradient: AppColors.gradienteRojoNaranja,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('ACCIONES RÁPIDAS',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.8)),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildAccionRapidaBtn(
                  Icons.line_style, 'Alineación', AppColors.naranja,
                      () => _navigateTo(const SeleccionarPartidoEntrenadorPage())),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildAccionRapidaBtn(
                  Icons.people, 'Equipo', Colors.blue.shade600,
                      () => _navigateTo(const MiEquipoPage())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccionRapidaBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}