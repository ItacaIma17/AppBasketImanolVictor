// lib/screens/Entrenador/ProximosPartidosPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/EquipoEntrenador.dart';
import '../../models/partido.dart';
import '../../services/entrenadorService.dart';
import '../../services/autenticacion_service.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'PresentarAlinecionPage.dart';
// ✅ FIX: abrir detalle de partido desde la lista filtrada del entrenador.
import '../DetallesPartido.dart';

class ProximosPartidosPage extends StatefulWidget {
  const ProximosPartidosPage({super.key});

  @override
  State<ProximosPartidosPage> createState() => _ProximosPartidosPageState();
}

class _ProximosPartidosPageState extends State<ProximosPartidosPage> {
  List<Partido> _partidos = [];
  EquipoEntrenador? _miEquipo;
  bool _isLoading = true;
  String _filtro = 'PROXIMOS'; // PROXIMOS, TODOS, FINALIZADOS
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
    setState(() => _isLoading = true);

    try {
      final equipoData = await EntrenadorService.obtenerMiEquipo();
      final equipo = EquipoEntrenador.fromJson(equipoData);

      if (equipo.tieneEquipo) {
        final partidos = await PartidoService.getPartidosByEquipo(equipo.equipoId);
        setState(() {
          _miEquipo = equipo;
          _partidos = partidos;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Partido> get _partidosFiltrados {
    final now = DateTime.now();
    final nowSinHora = DateTime(now.year, now.month, now.day);

    switch (_filtro) {
      case 'PROXIMOS':
        return _partidos
            .where((p) {
          final fechaPartido = _parseFecha(p.fecha);
          return p.estado != 'FINALIZADO' &&
              fechaPartido != null &&
              fechaPartido.isAfter(nowSinHora);
        })
            .toList()
          ..sort((a, b) => _compareFechas(a.fecha, b.fecha));

      case 'FINALIZADOS':
        return _partidos
            .where((p) => p.estado == 'FINALIZADO')
            .toList()
          ..sort((a, b) => _compareFechas(b.fecha, a.fecha));

      default:
        return _partidos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Próximos Partidos"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : _miEquipo == null
              ? _buildSinEquipo()
              : Column(
            children: [
              _buildFiltros(),
              Expanded(
                child: _partidosFiltrados.isEmpty
                    ? _buildSinPartidos()
                    : _buildPartidosList(),
              ),
            ],
          ),
        ),
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
            onPressed: _cargarDatos,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSinEquipo() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text('No tienes un equipo asignado', style: TextStyle(color: Colors.white54)),
        ],
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

  Widget _buildSinPartidos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _filtro == 'PROXIMOS' ? Icons.calendar_today : Icons.history,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            _filtro == 'PROXIMOS'
                ? 'No hay próximos partidos'
                : 'No hay partidos finalizados',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPartidosList() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _partidosFiltrados.length,
        itemBuilder: (context, index) {
          final partido = _partidosFiltrados[index];
          return _buildPartidoCard(partido);
        },
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final esLocal = partido.nombreLocal == _miEquipo!.nombreEquipo;
    final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;
    final esLocalJuego = esLocal;

    // Parsear fecha de forma segura
    final fechaParsed = _parseFecha(partido.fecha);
    final now = DateTime.now();
    final nowSinHora = DateTime(now.year, now.month, now.day);

    final isPast = fechaParsed != null && fechaParsed.isBefore(nowSinHora);
    final isToday = fechaParsed != null &&
        fechaParsed.year == now.year &&
        fechaParsed.month == now.month &&
        fechaParsed.day == now.day;

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

    // Determinar si tiene alineación presentada
    final tieneAlineacion = esLocal
        ? partido.tieneAlineacionLocal ?? false
        : partido.tieneAlineacionVisitante ?? false;

    // Usar fecha directamente
    final fechaMostrar = partido.fecha;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // ✅ Tarjeta clicable -> DetallePartidoPage. El botón "Presentar"
      // sigue funcionando porque consume su propio tap.
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetallePartidoPage(partido: partido)),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
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
            // Fecha y hora
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fechaMostrar,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  partido.hora.isNotEmpty ? partido.hora : 'Hora por confirmar',
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
                    partido.pabellon.isNotEmpty ? partido.pabellon : 'Sin ubicación',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Estado de alineación
            if (partido.estado != 'FINALIZADO' && !isPast)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tieneAlineacion ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      tieneAlineacion ? Icons.check_circle : Icons.warning_amber,
                      color: tieneAlineacion ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tieneAlineacion
                            ? 'Alineación ya presentada'
                            : 'Alineación pendiente',
                        style: TextStyle(
                          color: tieneAlineacion ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    if (!tieneAlineacion)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PresentarAlineacionPage(
                                partido: partido,
                                esLocal: esLocalJuego,
                              ),
                            ),
                          ).then((_) => _cargarDatos());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.naranja,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Presentar'),
                      ),
                  ],
                ),
              ),
            // Resultado si está finalizado
            if (partido.estado == 'FINALIZADO')
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
      ), // cierra InkWell del FIX detalle-partido
    );
  }
}