import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'PresentarAlinecionPage.dart';
import 'VerActaEntrenador.dart';
import 'VerAlineacionesEntrenadorPage.dart';

class MisPartidosEntrenadorPage extends StatefulWidget {
  const MisPartidosEntrenadorPage({super.key});

  @override
  State<MisPartidosEntrenadorPage> createState() => _MisPartidosEntrenadorPageState();
}

class _MisPartidosEntrenadorPageState extends State<MisPartidosEntrenadorPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String? _error;
  String _filtro = 'PROGRAMADO';

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
      final partidos = await PartidoService.getPartidosEntrenador();
      setState(() {
        _partidos = partidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Partido> get _partidosFiltrados {
    if (_filtro == 'TODOS') {
      return _partidos;
    }
    return _partidos.where((p) => p.estado == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Mis Partidos"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildFiltros(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _buildErrorWidget()
                    : _buildPartidosList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFiltroChip('PROGRAMADO', 'Pendientes'),
          _buildFiltroChip('FINALIZADO', 'Finalizados'),
          _buildFiltroChip('TODOS', 'Todos'),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String valor, String label) {
    final isSelected = _filtro == valor;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filtro = valor;
          });
        }
      },
      backgroundColor: Colors.grey.withOpacity(0.3),
      selectedColor: AppColors.naranja,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
      ),
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
    if (_partidosFiltrados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No hay partidos en esta categoría',
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
        itemCount: _partidosFiltrados.length,
        itemBuilder: (context, index) {
          final partido = _partidosFiltrados[index];
          final esLocal = true;
          return _buildPartidoCard(partido, esLocal);
        },
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido, bool esLocal) {
    final fechaPartido = DateTime.parse('${partido.fecha} ${partido.hora}');
    final now = DateTime.now();
    final estaFinalizado = fechaPartido.isBefore(now);

    final tieneAlineacion = esLocal
        ? (partido.tieneAlineacionLocal ?? false)
        : (partido.tieneAlineacionVisitante ?? false);

    final esLocalJuego = esLocal;

    final partidoId = int.tryParse(partido.id.toString()) ?? 0;
    final equipoLocalId = int.tryParse(partido.equipoLocalId.toString()) ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (estaFinalizado && partido.tieneActa == true) {
            _verActa(partidoId);

          } else if (!estaFinalizado && !tieneAlineacion) {
            _presentarAlineacion(partido, esLocalJuego);

          } else if (!estaFinalizado && tieneAlineacion) {
            _verAlineacion(partidoId, equipoLocalId);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${partido.nombreLocal} vs ${partido.nombreVisitante}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildEstadoChip(partido, tieneAlineacion),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(fechaPartido),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('HH:mm').format(fechaPartido),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      partido.direccionPabellon ?? 'Sin ubicación',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              if (estaFinalizado && partido.puntosLocal != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Resultado: ${partido.puntosLocal} - ${partido.puntosVisitante}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(Partido partido, bool tieneAlineacion) {
    if (partido.estado == 'FINALIZADO') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Finalizado',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    } else if (tieneAlineacion) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Alineación Lista',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Pendiente',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    }
  }

  void _presentarAlineacion(Partido partido, bool esLocal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PresentarAlineacionPage(
          partido: partido,
          esLocal: esLocal,
        ),
      ),
    ).then((_) => _cargarPartidos());
  }

  void _verAlineacion(int partidoId, int equipoId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerAlineacionEntrenadorPage(
          partidoId: partidoId,
          equipoId: equipoId,
        ),
      ),
    );
  }

  void _verActa(int partidoId) async {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerActaEntrenadorPage(partidoId: partidoId),
      ),
    );
  }
}
