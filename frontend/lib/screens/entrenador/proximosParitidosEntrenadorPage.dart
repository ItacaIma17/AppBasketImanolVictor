// lib/screens/Entrenador/ProximosPartidosEntrenadorPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../services/autenticacion_service.dart';
import '../../services/entrenadorService.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'PresentarAlineacion.dart';

class ProximosPartidosEntrenadorPage extends StatefulWidget {
  const ProximosPartidosEntrenadorPage({super.key});

  @override
  State<ProximosPartidosEntrenadorPage> createState() => _ProximosPartidosEntrenadorPageState();
}

class _ProximosPartidosEntrenadorPageState extends State<ProximosPartidosEntrenadorPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String? _error;
  String _filtro = 'PROXIMOS'; // PROXIMOS, TODOS

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
      final entrenador = AutenticacionService.entrenadorActual;

      if (entrenador == null || !entrenador.tieneEquipo) {
        setState(() {
          _error = 'No tienes un equipo asignado';
          _isLoading = false;
        });
        return;
      }

      final partidos = await PartidoService.getProximosPartidosEquipo(entrenador.equipoId!);

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
  if (_filtro == 'PROXIMOS') {
    final now = DateTime.now();

    return _partidos.where((p) {
      final fechaPartido = DateTime.parse('${p.fecha} ${p.hora}');
      return fechaPartido.isAfter(now);
    }).toList();
  }

  return _partidos;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Próximos Partidos"),
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
          _buildFiltroChip('PROXIMOS', 'Próximos'),
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

  Widget _buildPartidosList() {
    if (_partidosFiltrados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No hay partidos programados',
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
          final esLocal = true; // Determinar si es local o visitante
          return _buildPartidoCard(partido, esLocal);
        },
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido, bool esLocal) {
    final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;
    final esLocalJuego = esLocal;

    // Determinar estado del partido
    final now = DateTime.now();

    final fechaPartido = DateTime.parse('${partido.fecha} ${partido.hora}');

    // Partido ya jugado
    final isPast = fechaPartido.isBefore(now);

    // Partido hoy
    final isToday =
        fechaPartido.year == now.year &&
        fechaPartido.month == now.month &&
        fechaPartido.day == now.day;


    String estadoTexto;
    Color estadoColor;

    if (partido.estado == 'FINALIZADO') {
      estadoTexto = 'Finalizado';
      estadoColor = Colors.green;
    } else if (isPast) {
      estadoTexto = 'No jugado';
      estadoColor = Colors.red;
    } else if (isToday) {
      estadoTexto = 'Hoy';
      estadoColor = Colors.orange;
    } else {
      estadoTexto = 'Programado';
      estadoColor = Colors.blue;
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estadoTexto,
                    style: TextStyle(color: estadoColor, fontSize: 12),
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
                  DateFormat('dd/MM/yyyy HH:mm').format(
                    DateTime.parse('${partido.fecha} ${partido.hora}'),
                  ),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(
                    DateTime.parse('${partido.fecha} ${partido.hora}'),
                  ),
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
            const SizedBox(height: 12),
            if (partido.estado != 'FINALIZADO' && !isPast)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PresentarAlineacionPage(
                            partido: partido,
                            esLocal: esLocalJuego,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.line_style, size: 18),
                    label: const Text('Presentar Alineación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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