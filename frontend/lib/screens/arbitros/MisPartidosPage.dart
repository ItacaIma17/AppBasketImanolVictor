// lib/screens/Arbitro/MisPartidosPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/screens/arbitros/verActaArbitroPage.dart';
import '../../models/actaPartido.dart';
import '../../models/partido.dart';
import '../../services/actaService.dart';
import '../../services/arbitroService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'CrearActaPage.dart';

class MisPartidosPage extends StatefulWidget {
  const MisPartidosPage({super.key});

  @override
  State<MisPartidosPage> createState() => _MisPartidosPageState();
}

class _MisPartidosPageState extends State<MisPartidosPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String? _error;
  String _filtro = 'PROGRAMADO'; // PROGRAMADO, FINALIZADO, TODOS

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
          return _buildPartidoCard(partido);
        },
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    final tieneActa = partido.tieneActa ?? false;
    final estaFinalizado = partido.estado == 'FINALIZADO';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Convertir IDs correctamente
          final partidoId = int.tryParse(partido.id.toString()) ?? 0;

          if (tieneActa && estaFinalizado) {
            _verActa(partidoId);

          } else if (!tieneActa && !estaFinalizado) {
            _crearActa(partido); // esta función recibe un Partido, no un int
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
                  _buildEstadoChip(partido, tieneActa),
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
              _buildAccionButton(partido, tieneActa, estaFinalizado),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(Partido partido, bool tieneActa) {
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
    } else if (tieneActa) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Acta Creada',
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

  Widget _buildAccionButton(Partido partido, bool tieneActa, bool estaFinalizado) {
    // Convertir id de String a int
    final partidoId = int.tryParse(partido.id.toString()) ?? 0;

    if (estaFinalizado && tieneActa) {
      return ElevatedButton.icon(
        onPressed: () => _verActa(partidoId),
        icon: const Icon(Icons.visibility, size: 18),
        label: const Text('Ver Acta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (!estaFinalizado && !tieneActa) {
      // Verificar si ambas alineaciones están presentadas
      final alineacionesListas = (partido.tieneAlineacionLocal ?? false) &&
          (partido.tieneAlineacionVisitante ?? false);

      if (!alineacionesListas) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Text(
                'Esperando alineaciones de los equipos',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ),
        );
      }

      return ElevatedButton.icon(
        onPressed: () => _crearActa(partido),
        icon: const Icon(Icons.edit_document, size: 18),
        label: const Text('Crear Acta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (estaFinalizado && !tieneActa) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 16),
            SizedBox(width: 8),
            Text(
              'Partido finalizado sin acta',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _crearActa(Partido partido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearActaPage(partido: partido),
      ),
    ).then((_) => _cargarPartidos());
  }

  void _verActa(int partidoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerActaArbitroPage(partidoId: partidoId),
      ),
    );
  }
}

