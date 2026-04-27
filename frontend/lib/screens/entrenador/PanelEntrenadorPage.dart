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
import 'PresentarAlineacion.dart';
import 'SeleccionarPartidoEntrenadorPage.dart';
import 'ProximosPartidosPage.dart'; // ✅ Añadir import
import 'EstadisticasEquipoPage.dart'; // ✅ Añadir import


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
            const Icon(Icons.sports_basketball, size: 80, color: Colors.white54),
            const SizedBox(height: 24),
            const Text(
              'Aún no tienes un equipo asignado',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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

  Widget _buildMenuPrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GESTIÓN DEL EQUIPO', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMenuCard('Mi Equipo', Icons.people, Colors.blue, () => _navigateTo(const MiEquipoPage())),
            _buildMenuCard('Jugadores', Icons.sports_basketball, Colors.green, () => _navigateTo(JugadoresEquipoPage(equipoId: _miEquipo!.equipoId))),
            // ✅ CORREGIDO: No pasar partidos como parámetro
            _buildMenuCard('Próximos Partidos', Icons.calendar_today, Colors.orange, () => _navigateTo(const ProximosPartidosPage())),
            _buildMenuCard('Presentar Alineación', Icons.line_style, Colors.purple, () => _navigateTo(const SeleccionarPartidoEntrenadorPage())),
            _buildMenuCard('Estadísticas', Icons.bar_chart, Colors.red, () => _navigateTo(const EstadisticasEquipoPage())),
            _buildMenuCard('Configuración', Icons.settings, Colors.grey, () => _navigateTo(const ConfiguracionPage())),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
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
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.sports_basketball, color: AppColors.naranja),
        title: Text('vs $rival'),
        subtitle: Text('${DateTime.parse(partido.fecha).day}/${DateTime.parse(partido.fecha).month}/${DateTime.parse(partido.fecha).year} - ${partido.direccionPabellon ?? "Sin ubicación"}'),
        trailing: ElevatedButton(
          onPressed: () => _navigateTo(PresentarAlineacionPage(partido: partido, esLocal: esLocal)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Alineación'),
        ),
      ),
    );
  }

  Widget _buildAccionesRapidas() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _navigateTo(const SeleccionarPartidoEntrenadorPage()),
            icon: const Icon(Icons.line_style),
            label: const Text('Nueva Alineación'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _navigateTo(const MiEquipoPage()),
            icon: const Icon(Icons.people),
            label: const Text('Ver Equipo'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ),
      ],
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}