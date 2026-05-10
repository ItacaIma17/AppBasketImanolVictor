import 'package:flutter/material.dart';
import '../../config/common/resources/colores.dart';
import '../../models/EquipoEntrenador.dart';
import '../../models/partido.dart';
import '../../services/entrenadorService.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'PresentarAlinecionPage.dart';

class SeleccionarPartidoEntrenadorPage extends StatefulWidget {
  const SeleccionarPartidoEntrenadorPage({super.key});

  @override
  State<SeleccionarPartidoEntrenadorPage> createState() =>
      _SeleccionarPartidoEntrenadorPageState();
}

class _SeleccionarPartidoEntrenadorPageState
    extends State<SeleccionarPartidoEntrenadorPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String? _error;
  int? _equipoId;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {

      final equipoData = await EntrenadorService.obtenerMiEquipo();
      final equipo = EquipoEntrenador.fromJson(equipoData);

      if (equipo.tieneEquipo) {
        _equipoId = equipo.equipoId;

        final partidos = await PartidoService.getPartidosEntrenador();
        setState(() {
          _partidos = partidos.where((p) => p.esProgramado).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No tienes un equipo asignado';
          _isLoading = false;
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
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Seleccionar Partido"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : _buildPartidosList(),
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

  Widget _buildPartidosList() {
    if (_partidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_basketball, size: 64, color: Colors.white54),
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
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _partidos.length,
        itemBuilder: (context, index) {
          final partido = _partidos[index];

          final esLocal = partido.equipoLocalId == _equipoId;
          return _buildPartidoCard(partido, esLocal);
        },
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido, bool esLocal) {
    final tieneAlineacion = esLocal
        ? partido.tieneAlineacionLocal ?? false
        : partido.tieneAlineacionVisitante ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tieneAlineacion
              ? Colors.green.withOpacity(0.4)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tieneAlineacion
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PresentarAlineacionPage(
                  partido: partido,
                  esLocal: esLocal,
                ),
              ),
            ).then((_) => _cargarDatos());
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blanco,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tieneAlineacion
                            ? Colors.green.withOpacity(0.2)
                            : AppColors.naranja.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: tieneAlineacion
                              ? Colors.green.withOpacity(0.5)
                              : AppColors.naranja.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        tieneAlineacion ? 'Presentada' : 'Pendiente',
                        style: TextStyle(
                          color: tieneAlineacion ? Colors.green : AppColors.naranja,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                    const SizedBox(width: 8),
                    Text(
                      '${partido.fecha}  ${partido.hora}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        partido.pabellon.isNotEmpty ? partido.pabellon : 'Sin ubicación',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (tieneAlineacion) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Alineación ya presentada',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.touch_app, size: 14, color: AppColors.naranja),
                      const SizedBox(width: 6),
                      Text(
                        esLocal ? 'Juegas como LOCAL' : 'Juegas como VISITANTE',
                        style: TextStyle(
                          color: AppColors.naranja.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
