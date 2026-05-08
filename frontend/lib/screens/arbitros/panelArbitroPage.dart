// lib/screens/Arbitro/PanelArbitroPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/arbitro.dart';
import '../../models/partido.dart';
import '../../services/arbitroService.dart';
import '../../services/autenticacion_service.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import '../Partidos/SeleccionarPartidoPage.dart';
import 'CrearActaPage.dart';
import 'MisPartidosArbitroPage.dart';
import 'SeleccionarPartidoActaPage.dart';
import 'VerActaArbitroPage.dart';

class PanelArbitroPage extends StatefulWidget {
  const PanelArbitroPage({super.key});

  @override
  State<PanelArbitroPage> createState() => _PanelArbitroPageState();
}

class _PanelArbitroPageState extends State<PanelArbitroPage> {
  Arbitro? _arbitro;
  List<Partido> _partidosAsignados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final arbitro = AutenticacionService.arbitroActual;
      if (arbitro != null) {
        final partidos = await ArbitroService.getMisPartidos();
        setState(() {
          _arbitro = arbitro;
          _partidosAsignados = partidos;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Panel de Árbitro"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _arbitro == null
              ? _buildSinPerfil()
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPerfilArbitro(),
                const SizedBox(height: 16),
                _buildEstadisticas(),
                const SizedBox(height: 16),
                _buildMenuAcciones(),
                const SizedBox(height: 16),
                if (_partidosAsignados.isNotEmpty) _buildProximosPartidos(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSinPerfil() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gavel, size: 80, color: Colors.white54),
          SizedBox(height: 16),
          Text('No hay información de perfil disponible', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildPerfilArbitro() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradienteNaranjaAmarillo,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.gavel, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                _arbitro!.nombreCompleto,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                _arbitro!.email,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Código: ${_arbitro!.codigoArbitro ?? "N/A"}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticas() {
    final partidosPendientes = _partidosAsignados.where((p) => p.estado != 'FINALIZADO').length;
    final partidosFinalizados = _partidosAsignados.where((p) => p.estado == 'FINALIZADO').length;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.pending_actions, size: 32, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(
                    partidosPendientes.toString(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Partidos pendientes', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 32, color: Colors.green),
                  const SizedBox(height: 8),
                  Text(
                    partidosFinalizados.toString(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Partidos finalizados', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuAcciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACCIONES RÁPIDAS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAccionCard(
                icon: Icons.calendar_today,
                title: 'Mis Partidos',
                color: Colors.blue,
                onTap: () => _navigateTo(const MisPartidosArbitroPage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAccionCard(
                icon: Icons.people,
                title: 'Ver Alineaciones',
                color: Colors.green,
                onTap: () => _navigateTo(const SeleccionarPartidoPage()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAccionCard(
                icon: Icons.description,
                title: 'Crear Acta',
                color: Colors.orange,
                onTap: () => _navigateTo(const SeleccionarPartidoActaPage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAccionCard(
                icon: Icons.picture_as_pdf,
                title: 'Ver Actas',
                color: Colors.purple,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccionCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
    final proximos = _partidosAsignados.where((p) => p.estado != 'FINALIZADO').take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRÓXIMOS PARTIDOS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        ...proximos.map((partido) => _buildPartidoCard(partido)),
      ],
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final alineacionesListas = (partido.tieneAlineacionLocal ?? false) && (partido.tieneAlineacionVisitante ?? false);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.sports_basketball, color: AppColors.naranja),
        title: Text('${partido.nombreLocal} vs ${partido.nombreVisitante}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${DateTime.parse(partido.fecha).day}/${DateTime.parse(partido.fecha).month}/${DateTime.parse(partido.fecha).year} - ${partido.direccionPabellon ?? "Sin ubicación"}'),
            if (!alineacionesListas)
              const Text('Esperando alineaciones', style: TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ),
        trailing: partido.tieneActa == true
            ? ElevatedButton(
          onPressed: () => _navigateTo(VerActaArbitroPage(partido :partido)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Ver Acta'),
        )
            : alineacionesListas
            ? ElevatedButton(
          onPressed: () => _navigateTo(CrearActaPage(partido: partido)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
          child: const Text('Crear Acta'),
        )
            : Container(),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}