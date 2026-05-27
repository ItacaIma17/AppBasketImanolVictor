import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/equipo.dart';
import '../../models/partido.dart';
import '../../models/role.dart';
import '../../services/autenticacion_service.dart';
import '../../services/equipoService.dart';
import '../../services/loggerService.dart';
import '../../services/partidoService.dart';
import '../../widgets/Partidos/CrearPartidosCompletosDialog.dart';
import 'DetallePartidoAdminPage.dart';

class GestionPartidosPage extends StatefulWidget {
  const GestionPartidosPage({super.key, this.ligaId});

  final int? ligaId;

  @override
  State<GestionPartidosPage> createState() => _GestionPartidosPageState();
}

class _GestionPartidosPageState extends State<GestionPartidosPage> {
  List<Partido> _partidos = [];
  List<Equipo> _equipos = [];
  bool _isLoading = true;
  String? _error;

  int? _jornadaFiltro;
  String? _estadoFiltro;
  int? _ligaId;

  @override
  void initState() {
    super.initState();
    _ligaId = widget.ligaId;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = AutenticacionService.token;
      final usuario = AutenticacionService.usuarioActual;

      if (token == null) {
        throw Exception('No hay sesión activa.');
      }

      if (usuario?.role != Role.ADMIN) {
        throw Exception('No tienes permisos.');
      }

      final partidos = await PartidoService.listarPartidos();
      final equipos = await EquipoService.listarEquipos();

      setState(() {
        _partidos = partidos;
        _equipos = equipos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _mostrarDialogoCrear() {
    showDialog(
      context: context,
      builder: (context) =>
          CrearPartidoCompletoDialog(
            equipos: _equipos,
            ligaIdInicial: _ligaId,
            onPartidoCreado: () => _cargarDatos(),
          ),
    );
  }

  List<Partido> get _partidosFiltrados {
    var filtrados = _partidos;

    if (_jornadaFiltro != null) {
      filtrados = filtrados.where((p) => p.jornada == _jornadaFiltro).toList();
    }

    if (_estadoFiltro != null) {
      filtrados = filtrados.where((p) => p.estado == _estadoFiltro).toList();
    }

    filtrados.sort((a, b) => a.fecha.compareTo(b.fecha));
    return filtrados;
  }

  Map<int, List<Partido>> get _partidosPorJornada {
    final mapa = <int, List<Partido>>{};
    for (var partido in _partidosFiltrados) {
      final jornada = (partido.jornada != null && partido.jornada! >= 1) ? partido.jornada! : 1;
      mapa.putIfAbsent(jornada, () => []).add(partido);
    }
    return Map.fromEntries(
      mapa.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Gestión de Partidos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Administra los partidos de la liga',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoCrear,
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildFiltros(),

              const SizedBox(height: 20),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                  child: Text(
                      _error!, style: const TextStyle(color: Colors.red)),
                )
                    : _partidosFiltrados.isEmpty
                    ? const Center(
                  child: Text(
                    'No hay partidos',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                    : ListView(
                  children: _partidosPorJornada.entries.map((entry) {
                    return _buildJornadaSection(entry.key, entry.value);
                  }).toList(),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('Filtrar:', style: TextStyle(color: Colors.white)),
          const SizedBox(width: 12),

          Expanded(
            child: Material(
              color: Colors.transparent,
              child: DropdownButtonFormField<int>(
                value: _jornadaFiltro,
                dropdownColor: const Color(0xFF1E293B),
                hint: const Text('Jornada', style: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...List.generate(
                    34,
                        (i) => DropdownMenuItem(value: i + 1, child: Text('J${i + 1}')),
                  )
                ],
                onChanged: (v) => setState(() => _jornadaFiltro = v),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Material(
              color: Colors.transparent,
              child: DropdownButtonFormField<String>(
                value: _estadoFiltro,
                dropdownColor: const Color(0xFF1E293B),
                hint: const Text('Estado', style: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  DropdownMenuItem(value: 'PROGRAMADO', child: Text('Programado')),
                  DropdownMenuItem(value: 'EN_CURSO', child: Text('En curso')),
                  DropdownMenuItem(value: 'FINALIZADO', child: Text('Finalizado')),
                ],
                onChanged: (v) => setState(() => _estadoFiltro = v),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJornadaSection(int jornada, List<Partido> partidos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Jornada $jornada',
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        ...partidos.map(_buildPartidoCard),
      ],
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final estado = partido.estado.toUpperCase();
    Color estadoColor = Colors.grey;
    if (estado == 'PROGRAMADO')
      estadoColor = Colors.blueAccent;
    else if (estado == 'EN_CURSO')
      estadoColor = Colors.orange;
    else if (estado == 'FINALIZADO') estadoColor = Colors.green;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetallePartidoAdminPage(partido: partido),
        ),
      ).then((refresh) { if (refresh == true) _cargarDatos(); }),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${partido.nombreLocal} vs ${partido.nombreVisitante}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: estadoColor.withOpacity(0.6)),
                ),
                child: Text(estado,
                    style: TextStyle(
                        color: estadoColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event, size: 13, color: Colors.white60),
              const SizedBox(width: 4),
              Text('${partido.fecha} · ${partido.hora}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 12),
              if (partido.jornada != null) ...[
                const Icon(Icons.format_list_numbered, size: 13,
                    color: Colors.white60),
                const SizedBox(width: 4),
                Text('J${partido.jornada}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.stadium, size: 13, color: Colors.white54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  partido.pabellon.isNotEmpty
                      ? partido.pabellon
                      : 'Sin pabellón',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.sports, size: 13,
                  color: partido.nombreArbitro != null
                      ? AppColors.naranja
                      : Colors.white38),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  partido.nombreArbitro ?? 'Sin árbitro asignado',
                  style: TextStyle(
                      color: partido.nombreArbitro != null
                          ? AppColors.naranja
                          : Colors.white38,
                      fontSize: 11,
                      fontStyle: partido.nombreArbitro == null
                          ? FontStyle.italic
                          : FontStyle.normal),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
