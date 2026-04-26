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
import '../equipos/SolicitarEquipoPage.dart';
import 'MiEquipoPage.dart';
import 'PresentarAlineacion.dart';
import 'SeleccionarPartidoEntrenadorPage.dart';

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

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final equipoData = await EntrenadorService.obtenerMiEquipo();
      final equipo = EquipoEntrenador.fromJson(equipoData);

      if (equipo.tieneEquipo) {
        // Cargar jugadores y próximos partidos en paralelo con casting correcto
        final resultados = await Future.wait([
          EquipoService.getJugadoresEquipo(equipo.equipoId),
          PartidoService.getProximosPartidosEquipo(equipo.equipoId),
        ]);

        if (mounted) {
          setState(() {
            _miEquipo = equipo;
            _jugadores = resultados[0] as List<Jugador>;
            _proximosPartidos = resultados[1] as List<Partido>;
            _tieneEquipo = true;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _tieneEquipo = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error cargando datos: $e');
      if (mounted) {
        setState(() {
          _tieneEquipo = false;
          _isLoading = false;
          _error = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Panel de Entrenador"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
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

  // ============================================================
  // SIN EQUIPO ASIGNADO
  // ============================================================

  Widget _buildSinEquipoWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_basketball,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            const Text(
              'Aún no tienes un equipo asignado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Solicita un equipo usando el código que te proporcionó la federación',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SolicitarEquipoPage(),
                  ),
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

  // ============================================================
  // CON EQUIPO ASIGNADO
  // ============================================================

  Widget _buildMiEquipoWidget() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
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
          ],
        ),
      ),
    );
  }

  Widget _buildEquipoHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_miEquipo!.nombreLiga != null)
                Text(
                  _miEquipo!.nombreLiga!,
                  style: const TextStyle(color: Colors.white70),
                ),
              if (_miEquipo!.nombreEstadio != null)
                Text(
                  _miEquipo!.nombreEstadio!,
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
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
        Expanded(
          child: _buildEstadisticaCard(
            icon: Icons.people,
            label: 'Jugadores',
            value: '${_jugadores.length}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildEstadisticaCard(
            icon: Icons.sports_basketball,
            label: 'Partidos',
            value: '${_proximosPartidos.length}',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildEstadisticaCard(
            icon: Icons.assessment,
            label: 'Victorias',
            value: '0',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticaCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuPrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GESTIÓN DEL EQUIPO',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMenuCard(
              title: 'Mi Equipo',
              icon: Icons.people,
              color: Colors.blue,
              onTap: () => _navigateTo(const MiEquipoPage()),
            ),
            _buildMenuCard(
              title: 'Jugadores',
              icon: Icons.sports_basketball,
              color: Colors.green,
              onTap: () => _navigateTo(JugadoresEquipoPage(equipoId: _miEquipo!.equipoId)),
            ),
            _buildMenuCard(
              title: 'Próximos Partidos',
              icon: Icons.calendar_today,
              color: Colors.orange,
              onTap: () => _navigateTo(ProximosPartidosPage(partidos: _proximosPartidos)),
            ),
            _buildMenuCard(
              title: 'Alineación',
              icon: Icons.line_style,
              color: Colors.purple,
              onTap: () => _navigateTo(const SeleccionarPartidoEntrenadorPage()),
            ),
            _buildMenuCard(
              title: 'Estadísticas',
              icon: Icons.bar_chart,
              color: Colors.red,
              onTap: () => _navigateTo(const EstadisticasEquipoPage()),
            ),
            _buildMenuCard(
              title: 'Configuración',
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () => _navigateTo(const ConfiguracionEquipoPage()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
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
        const Text(
          'PRÓXIMOS PARTIDOS',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ..._proximosPartidos.take(3).map((partido) => _buildPartidoCard(partido)),
      ],
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final esLocal = partido.equipoLocal == _miEquipo!.nombreEquipo;
    final rival = esLocal ? partido.equipoVisitante : partido.equipoLocal;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.sports_basketball, color: AppColors.naranja),
        title: Text('vs $rival'),
        subtitle: Text(
          '${partido.fecha.day}/${partido.fecha.month}/${partido.fecha.year} - ${partido.ubicacion ?? 'Sin ubicación'}',
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PresentarAlineacionPage(
                  partido: partido,
                  esLocal: esLocal,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Alineación'),
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

// Pantallas placeholder
class JugadoresEquipoPage extends StatelessWidget {
  final int equipoId;
  const JugadoresEquipoPage({super.key, required this.equipoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jugadores del Equipo')),
      body: Center(child: Text('Lista de jugadores del equipo $equipoId')),
    );
  }
}

class ProximosPartidosPage extends StatelessWidget {
  final List<Partido> partidos;
  const ProximosPartidosPage({super.key, required this.partidos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Próximos Partidos')),
      body: ListView.builder(
        itemCount: partidos.length,
        itemBuilder: (context, index) {
          final partido = partidos[index];
          return ListTile(
            title: Text('${partido.equipoLocal} vs ${partido.equipoVisitante}'),
            subtitle: Text('${partido.fecha.day}/${partido.fecha.month}/${partido.fecha.year}'),
          );
        },
      ),
    );
  }
}

class EstadisticasEquipoPage extends StatelessWidget {
  const EstadisticasEquipoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: const Center(child: Text('Estadísticas del equipo - Próximamente')),
    );
  }
}

class ConfiguracionEquipoPage extends StatelessWidget {
  const ConfiguracionEquipoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: const Center(child: Text('Configuración del equipo - Próximamente')),
    );
  }
}