import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../config/api_config.dart';
import '../../models/AlineacionesPartido.dart';
import '../../models/JugadorAlineacion.dart';
import '../../models/alineacion.dart';
import '../../services/alineacionService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class VerAlineacionesPage extends StatefulWidget {
  final int partidoId;

  const VerAlineacionesPage({super.key, required this.partidoId});

  @override
  State<VerAlineacionesPage> createState() => _VerAlineacionesPageState();
}

class _VerAlineacionesPageState extends State<VerAlineacionesPage> {
  AlineacionesPartido? _alineaciones;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarAlineaciones();
  }

  Future<void> _cargarAlineaciones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await AlineacionService.getAlineacionesPartido(widget.partidoId);

      if (data is AlineacionesPartido) {
        setState(() {
          _alineaciones = data as AlineacionesPartido?;
          _isLoading = false;
        });
      } else if (data is Map<String, dynamic>) {

        final alineacionesPartido = AlineacionesPartido.fromJson(data);
        setState(() {
          _alineaciones = alineacionesPartido;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Formato de datos inválido';
        });
      }
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
      appBar: const HeaderApp(titulo: "Alineaciones"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.amarilloAragon))
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),
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
            onPressed: _cargarAlineaciones,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
                    '${_alineaciones!.equipoLocal} vs ${_alineaciones!.equipoVisitante}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEstadoChip('Local', _alineaciones!.alineacionLocalConfirmada),
                      const SizedBox(width: 8),
                      _buildEstadoChip('Visitante', _alineaciones!.alineacionVisitanteConfirmada),
                    ],
                  ),
                  if (_alineaciones!.partidoListoParaComenzar)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Ambos equipos han confirmado sus alineaciones'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAlineacionEquipo(
            _alineaciones!.equipoLocal,
            _alineaciones!.alineacionLocal,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildAlineacionEquipo(
            _alineaciones!.equipoVisitante,
            _alineaciones!.alineacionVisitante,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(String equipo, bool confirmada) {
    return Chip(
      backgroundColor: confirmada ? Colors.green : Colors.grey,
      label: Text(
        '$equipo: ${confirmada ? "Confirmada" : "Pendiente"}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildAlineacionEquipo(String nombreEquipo, Alineacion? alineacion, Color color) {
    if (alineacion == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                nombreEquipo,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 8),
              const Text('Alineación no presentada aún'),
            ],
          ),
        ),
      );
    }

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
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  nombreEquipo,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
                const Spacer(),
                if (alineacion.confirmada)
                  const Chip(
                    label: Text('Confirmada'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Titulares', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...alineacion.titulares.map((j) => _buildJugadorTile(j)),
            if (alineacion.suplentes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Suplentes', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...alineacion.suplentes.map((j) => _buildJugadorTile(j)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJugadorTile(JugadorAlineacion jugador) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.naranja.withOpacity(0.2),
        child: Text(jugador.dorsal.toString()),
      ),
      title: Text(jugador.nombreCompleto),
      subtitle: Text(jugador.posicion),
    );
  }

  static Future<Map<String, dynamic>> presentarAlineacion(Map<String, dynamic> data) async {
    try {
      final response = await AppConfig.post('/alineaciones/presentar', data: data);
      return response;
    } catch (e) {
      throw Exception('Error al presentar alineación: $e');
    }
  }

  static Future<Map<String, dynamic>?> getAlineacionEquipo(int partidoId, int equipoId) async {
    try {
      final response = await AppConfig.get('/alineaciones/partido/$partidoId/equipo/$equipoId');
      return response;
    } catch (e) {
      return null;
    }
  }
}
