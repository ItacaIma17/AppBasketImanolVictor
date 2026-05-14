import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/JugadorAlineacion.dart';
import '../../models/alineacion.dart';
import '../../services/alineacionService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class VerAlineacionEntrenadorPage extends StatefulWidget {
  final int partidoId;
  final int equipoId;

  const VerAlineacionEntrenadorPage({
    super.key,
    required this.partidoId,
    required this.equipoId,
  });

  @override
  State<VerAlineacionEntrenadorPage> createState() => _VerAlineacionEntrenadorPageState();
}

class _VerAlineacionEntrenadorPageState extends State<VerAlineacionEntrenadorPage> {
  Alineacion? _alineacion;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarAlineacion();
  }

  Future<void> _cargarAlineacion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final alineacion = await AlineacionService.getAlineacion(
        widget.partidoId,
        widget.equipoId,
      );
      setState(() {
        _alineacion = alineacion;
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
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Mi Alineación"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
          : _error != null
              ? _buildErrorWidget()
              : _alineacion == null
                  ? _buildSinAlineacionWidget()
                  : _buildAlineacionContent(),
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
            onPressed: _cargarAlineacion,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSinAlineacionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Aún no has presentado tu alineación',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlineacionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _alineacion!.nombreEquipo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'vs ${_alineacion!.equipoVisitante}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _alineacion!.confirmada ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _alineacion!.confirmada ? 'Confirmada' : 'Pendiente de confirmar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSeccionTitulares(),
          const SizedBox(height: 16),
          _buildSeccionSuplentes(),
          const SizedBox(height: 16),
          _buildInfoAdicional(),
        ],
      ),
    );
  }

  Widget _buildSeccionTitulares() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Jugadores Titulares',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_alineacion!.titulares.length}/5',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_alineacion!.titulares.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No hay titulares seleccionados')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _alineacion!.titulares.length,
                itemBuilder: (context, index) {
                  final jugador = _alineacion!.titulares[index];
                  return _buildJugadorTile(jugador, Colors.green);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionSuplentes() {
    if (_alineacion!.suplentes.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Jugadores Suplentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_alineacion!.suplentes.length}',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _alineacion!.suplentes.length,
              itemBuilder: (context, index) {
                final jugador = _alineacion!.suplentes[index];
                return _buildJugadorTile(jugador, Colors.orange);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJugadorTile(JugadorAlineacion jugador, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Text(
          jugador.dorsal.toString(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        jugador.nombreCompleto,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(jugador.posicion),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Dorsal ${jugador.dorsal}',
          style: TextStyle(color: color, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildInfoAdicional() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Alineación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Presentada el: ${_formatDate(_alineacion!.fechaPresentacion)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Entrenador: ${_alineacion!.nombreEntrenador}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (_alineacion!.confirmada) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Esta alineación ha sido confirmada y no puede modificarse',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
