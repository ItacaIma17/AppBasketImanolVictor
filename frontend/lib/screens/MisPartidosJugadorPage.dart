// lib/screens/Jugador/MisPartidosJugadorPage.dart (nuevo archivo)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class MisPartidosJugadorPage extends StatefulWidget {
  const MisPartidosJugadorPage({super.key});

  @override
  State<MisPartidosJugadorPage> createState() => _MisPartidosJugadorPageState();
}

class _MisPartidosJugadorPageState extends State<MisPartidosJugadorPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String _filtro = 'PROXIMOS'; // PROXIMOS, TODOS, FINALIZADOS
  String? _error;
  String? _nombreEquipo;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    setState(() => _isLoading = true);

    try {
      final partidos = await PartidoService.getPartidosByJugador();
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
    final now = DateTime.now();

    switch (_filtro) {
      case 'PROXIMOS':
        return _partidos
            .where((p) => DateTime.parse(p.fecha).isAfter(now) && p.estado != 'FINALIZADO')
            .toList()
          ..sort((a, b) => DateTime.parse(a.fecha).compareTo(DateTime.parse(b.fecha)));
      case 'FINALIZADOS':
        return _partidos
            .where((p) => p.estado == 'FINALIZADO')
            .toList()
          ..sort((a, b) => DateTime.parse(b.fecha).compareTo(DateTime.parse(a.fecha)));
      default:
        return _partidos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Mis Partidos"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Column(
            children: [
              _buildFiltros(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _buildErrorWidget()
                    : _partidosFiltrados.isEmpty
                    ? _buildSinPartidos()
                    : RefreshIndicator(
                  onRefresh: _cargarPartidos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _partidosFiltrados.length,
                    itemBuilder: (context, index) {
                      return _buildPartidoCard(_partidosFiltrados[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFiltroChip('PROXIMOS', 'Próximos'),
          _buildFiltroChip('TODOS', 'Todos'),
          _buildFiltroChip('FINALIZADOS', 'Finalizados'),
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
        if (selected) setState(() => _filtro = valor);
      },
      backgroundColor: Colors.grey.withOpacity(0.3),
      selectedColor: AppColors.naranja,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
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

  Widget _buildSinPartidos() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text('No hay partidos en esta categoría', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final esLocal = true; // Determinar si es local basado en el equipo del jugador
    final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;

    final now = DateTime.now();
    final fechaPartido = DateTime.parse(partido.fecha);
    final isPast = fechaPartido.isBefore(now);
    final isToday = fechaPartido.year == now.year &&
        fechaPartido.month == now.month &&
        fechaPartido.day == now.day;

    String estadoTexto;
    Color estadoColor;
    IconData estadoIcono;

    if (partido.estado == 'FINALIZADO') {
      estadoTexto = 'Finalizado';
      estadoColor = Colors.green;
      estadoIcono = Icons.check_circle;
    } else if (isPast) {
      estadoTexto = 'No jugado';
      estadoColor = Colors.red;
      estadoIcono = Icons.cancel;
    } else if (isToday) {
      estadoTexto = 'Hoy';
      estadoColor = Colors.orange;
      estadoIcono = Icons.today;
    } else {
      estadoTexto = 'Programado';
      estadoColor = Colors.blue;
      estadoIcono = Icons.event;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    'vs $rival',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(estadoIcono, size: 14, color: estadoColor),
                      const SizedBox(width: 4),
                      Text(estadoTexto, style: TextStyle(color: estadoColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(fechaPartido),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
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
            if (partido.estado == 'FINALIZADO' && partido.puntosLocal != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}