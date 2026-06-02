import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../models/equipo.dart';
import '../../models/arbitro.dart';
import '../../services/arbitroService.dart';
import '../../services/partidoService.dart';
import '../../services/equipoService.dart';
import '../../services/autenticacion_service.dart';
import '../../widgets/Partidos/CrearPartidosCompletosDialog.dart';
import 'DetallePartidoAdminPage.dart';

class GestionPartidosPage extends StatefulWidget {
  const GestionPartidosPage({super.key});

  @override
  State<GestionPartidosPage> createState() => _GestionPartidosPageState();
}

class _GestionPartidosPageState extends State<GestionPartidosPage> {
  List<Partido> _partidos = [];
  List<Equipo> _equipos = [];
  List<Arbitro> _arbitros = [];
  bool _loading = true;
  String? _error;

  String? _filtroEstado;
  int? _filtroJornada;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final partidos = await PartidoService.listarPartidos();
      final equipos = await EquipoService.listarEquipos();
      final arbitros = await ArbitroService.listarArbitros();

      setState(() {
        _partidos = partidos;
        _equipos = equipos;
        _arbitros = arbitros;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Partido> get _partidosFiltrados {
    var filtrados = _partidos;

    if (_filtroEstado != null && _filtroEstado != 'TODOS') {
      filtrados = filtrados.where((p) => p.estado == _filtroEstado).toList();
    }

    if (_filtroJornada != null) {
      filtrados = filtrados.where((p) => p.jornada == _filtroJornada).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((p) =>
      p.nombreLocal.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.nombreVisitante.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtrados;
  }

  void _mostrarDialogoCrear() {
    showDialog(
      context: context,
      builder: (context) => CrearPartidoCompletoDialog(
        equipos: _equipos,
        onPartidoCreado: () => _cargarDatos(),
      ),
    );
  }

  void _editarPartido(Partido partido) {
    showDialog(
      context: context,
      builder: (context) => CrearPartidoCompletoDialog(
        equipos: _equipos,
        onPartidoCreado: () => _cargarDatos(),
        partidoToEdit: partido,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Gestión de Partidos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.naranja),
            onPressed: _mostrarDialogoCrear,
            tooltip: 'Crear Partido',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarDatos,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: Column(
          children: [
            _buildFiltros(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.blanco))
                  : _error != null
                  ? _buildErrorWidget()
                  : _partidosFiltrados.isEmpty
                  ? _buildVacio()
                  : RefreshIndicator(
                onRefresh: _cargarDatos,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _partidosFiltrados.length,
                  itemBuilder: (context, index) {
                    final partido = _partidosFiltrados[index];
                    return _buildPartidoCard(partido);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {

    final jornadasUnicas = _partidos
        .map((p) => p.jornada)
        .where((j) => j != null)
        .toSet()
        .toList()
      ..sort();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar equipos...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: AppColors.naranja, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filtroEstado,
                    hint: const Text('Estado', style: TextStyle(color: Colors.white70)),
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos', style: TextStyle(color: Colors.white))),
                      const DropdownMenuItem(value: 'PROGRAMADO', child: Text(' Programados', style: TextStyle(color: Colors.white))),
                      const DropdownMenuItem(value: 'EN_CURSO', child: Text('⏳ En curso', style: TextStyle(color: Colors.white))),
                      const DropdownMenuItem(value: 'FINALIZADO', child: Text(' Finalizados', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (value) => setState(() => _filtroEstado = value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFiltroChip('Todas', null),
                ...jornadasUnicas.map((jornada) => _buildFiltroChip('J$jornada', jornada)),
              ],
            ),
          ),
          if (_filtroEstado != null || _filtroJornada != null || _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _filtroEstado = null;
                    _filtroJornada = null;
                    _searchQuery = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text('Limpiar filtros', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String label, int? jornada) {
    final isSelected = _filtroJornada == jornada;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12)),
        selected: isSelected,
        onSelected: (_) => setState(() => _filtroJornada = isSelected ? null : jornada),
        backgroundColor: Colors.white.withOpacity(0.05),
        selectedColor: AppColors.naranja,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
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

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_basketball, size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'No hay partidos',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Presiona el botón + para crear un nuevo partido',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final colorEstado = _getEstadoColor(partido.estado);
    final textoEstado = _getEstadoTexto(partido.estado);
    final esProgramado = partido.esProgramado;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallePartidoAdminPage(partido: partido),
          ),
        ).then((_) => _cargarDatos());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(_getEstadoIcono(partido.estado), color: colorEstado, size: 18),
                  const SizedBox(width: 8),
                  Text(textoEstado, style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12)),
                  const Spacer(),
                  if (partido.jornada != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Jornada ${partido.jornada}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.naranja.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield, size: 32, color: AppColors.naranja),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              partido.nombreLocal,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: !esProgramado ? AppColors.gradienteNaranjaAmarillo : null,
                          color: esProgramado ? AppColors.naranja.withOpacity(0.2) : null,
                          borderRadius: BorderRadius.circular(16),
                          border: esProgramado ? Border.all(color: AppColors.naranja.withOpacity(0.3)) : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              partido.resultadoTexto,
                              style: TextStyle(
                                fontSize: !esProgramado ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                color: !esProgramado ? Colors.white : AppColors.naranja,
                              ),
                            ),
                            if (esProgramado)
                              const Text('vs', style: TextStyle(color: AppColors.naranja, fontSize: 10)),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.amarilloAragon.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield, size: 32, color: AppColors.amarilloAragon),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              partido.nombreVisitante,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                      const SizedBox(width: 8),
                      Text('${partido.fecha} - ${partido.hora}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          partido.pabellon,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (partido.nombreArbitro != null && partido.nombreArbitro!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.sports, size: 14, color: Colors.white54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Árbitro: ${partido.nombreArbitro}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (esProgramado)
                        ElevatedButton.icon(
                          onPressed: () => _editarPartido(partido),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetallePartidoAdminPage(partido: partido),
                            ),
                          ).then((_) => _cargarDatos());
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Ver Detalles'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.naranja,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'PROGRAMADO': return Colors.orange;
      case 'EN_CURSO': return Colors.blue;
      case 'FINALIZADO': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'PROGRAMADO': return 'PROGRAMADO';
      case 'EN_CURSO': return 'EN CURSO';
      case 'FINALIZADO': return 'FINALIZADO';
      default: return estado;
    }
  }

  IconData _getEstadoIcono(String estado) {
    switch (estado) {
      case 'PROGRAMADO': return Icons.schedule;
      case 'EN_CURSO': return Icons.play_circle;
      case 'FINALIZADO': return Icons.check_circle;
      default: return Icons.help;
    }
  }
}
