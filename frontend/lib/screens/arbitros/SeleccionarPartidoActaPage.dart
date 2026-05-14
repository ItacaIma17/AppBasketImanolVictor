import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../services/arbitroService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'CrearActaPage.dart';
import 'VerActaArbitroPage.dart';

class SeleccionarPartidoActaPage extends StatefulWidget {
  const SeleccionarPartidoActaPage({super.key});

  @override
  State<SeleccionarPartidoActaPage> createState() =>
      _SeleccionarPartidoActaPageState();
}

class _SeleccionarPartidoActaPageState
    extends State<SeleccionarPartidoActaPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final partidos = await ArbitroService.getMisPartidos();
      setState(() {
        _partidos = partidos;
        _isLoading = false;
      });
    } catch (e) {
      print(' Error cargando partidos: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Mis Partidos"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.amarilloAragon))
          : _error != null
              ? _buildErrorWidget()
              : _buildPartidosList(),
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
            onPressed: _cargarPartidos,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPartidosList() {
    if (_partidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No hay partidos asignados',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarPartidos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _partidos.length,
        itemBuilder: (context, index) {
          final partido = _partidos[index];
          return _buildPartidoCard(partido);
        },
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final tieneActa = partido.tieneActa == true;
    final puedeHacerActa = partido.estado == 'FINALIZADO' && !tieneActa;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${partido.nombreLocal} vs ${partido.nombreVisitante}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: partido.estado == 'FINALIZADO' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    partido.estado == 'FINALIZADO' ? 'FINALIZADO' : 'PROGRAMADO',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(partido.fecha, style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(partido.hora, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    partido.pabellon.isNotEmpty ? partido.pabellon : 'Sin ubicación',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (partido.estado == 'FINALIZADO' && tieneActa)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerActaArbitroPage(partido: partido),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver Acta'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              )
            else if (puedeHacerActa)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrearActaPage(partido: partido),
                      ),
                    ).then((_) => _cargarPartidos());
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text('Hacer Acta'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                ),
              )
            else if (partido.estado != 'FINALIZADO')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _verAlineaciones(partido);
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('Ver Alineaciones'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _verAlineaciones(Partido partido) async {
    try {
      final alineaciones = await ArbitroService.getAlineacionesPartido(partido.id);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alineaciones - ${partido.nombreLocal} vs ${partido.nombreVisitante}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: _buildAlineacionesDialog(alineaciones),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando alineaciones: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildAlineacionesDialog(Map<String, dynamic> alineaciones) {
    final local = alineaciones['alineacionLocal'];
    final visitante = alineaciones['alineacionVisitante'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(local != null ? local['nombreEquipo'] : 'Sin alineación',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (local != null && local['titulares'] != null)
                ..._buildJugadoresList(local['titulares'], 'Titulares'),
              if (local != null && local['suplentes'] != null)
                ..._buildJugadoresList(local['suplentes'], 'Suplentes'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(visitante != null ? visitante['nombreEquipo'] : 'Sin alineación',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (visitante != null && visitante['titulares'] != null)
                ..._buildJugadoresList(visitante['titulares'], 'Titulares'),
              if (visitante != null && visitante['suplentes'] != null)
                ..._buildJugadoresList(visitante['suplentes'], 'Suplentes'),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildJugadoresList(List<dynamic> jugadores, String tipo) {
    if (jugadores.isEmpty) return [];

    return [
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(tipo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ),
      ...jugadores.map((j) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          '${j['dorsal'] ?? '?'} - ${j['nombre'] ?? j['nombreJugador'] ?? 'Desconocido'} (${j['posicion'] ?? '?'})',
          style: const TextStyle(fontSize: 12),
        ),
      )),
    ];
  }
}
