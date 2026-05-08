// lib/screens/equipos/DetalleEquipoPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/equipo.dart';
import '../../models/jugador.dart';
import '../../models/partido.dart';
import '../../services/equipoService.dart';
import '../../services/partidoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
// ✅ FIX: abrir perfil jugador desde equipos/ligas/mi equipo
import '../JugadorDetallePage.dart';

class EquipoDetallePage extends StatefulWidget {
  final Equipo equipo;

  const EquipoDetallePage({super.key, required this.equipo});

  @override
  State<EquipoDetallePage> createState() => _EquipoDetallePageState();
}

class _EquipoDetallePageState extends State<EquipoDetallePage> {
  List<Jugador> _jugadores = [];
  List<Partido> _partidos = [];
  bool _cargando = true;
  String? _error;

  // Función auxiliar para parsear fecha dd/MM/yyyy a DateTime
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
      print('Error parseando fecha: $fechaStr - $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final jugadores = await EquipoService.getJugadoresEquipo(widget.equipo.id ?? 0);
      final partidos = await PartidoService.getPartidosByEquipo(widget.equipo.id ?? 0);

      setState(() {
        _jugadores = jugadores;
        _partidos = partidos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: HeaderApp(titulo: widget.equipo.nombre),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoEquipo(),
                const SizedBox(height: 20),
                _buildSeccionJugadores(),
                const SizedBox(height: 20),
                _buildSeccionPartidos(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoEquipo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradienteNaranjaAmarillo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.shield, size: 60, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            widget.equipo.nombre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.emoji_events, 'Liga', widget.equipo.nombreLiga ?? 'Sin liga'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Estadio', widget.equipo.nombreEstadio.isNotEmpty ? widget.equipo.nombreEstadio : 'No especificado'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_city, 'Ciudad', widget.equipo.ciudad.isNotEmpty ? widget.equipo.ciudad : 'No especificada'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionJugadores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.naranja,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Jugadores',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_jugadores.length} jugadores',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_jugadores.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay jugadores en este equipo',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _jugadores.length,
            itemBuilder: (context, index) {
              final jugador = _jugadores[index];
              return _buildJugadorCard(jugador);
            },
          ),
      ],
    );
  }

  Widget _buildJugadorCard(Jugador jugador) {
    // ✅ FIX: tap abre el perfil del jugador (JugadorDetallePage)
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JugadorDetallePage(
            jugador: jugador,
            equipoNombre: widget.equipo.nombre,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.gradienteRojoNaranja,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                jugador.dorsal.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jugador.nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  jugador.posicion,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.naranja.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            // ✅ FIX: mostrar estadísticas (pts/reb/ast) en la tarjeta del
            // listado, además de en JugadorDetallePage.
            child: Text(
              '${jugador.promedioPuntos.toStringAsFixed(1)} pts · '
              '${jugador.promedioRebotes.toStringAsFixed(1)} reb · '
              '${jugador.promedioAsistencias.toStringAsFixed(1)} ast',
              style: const TextStyle(color: AppColors.naranja, fontSize: 10),
            ),
          ),
        ],
      ),
      ), // cierra InkWell del FIX abrir-perfil-jugador
    );
  }

  Widget _buildSeccionPartidos() {
    // Filtrar próximos partidos (no finalizados)
    final proximosPartidos = _partidos
        .where((p) => p.estado != 'FINALIZADO')
        .toList()
      ..sort((a, b) {
        final fechaA = _parseFecha(a.fecha);
        final fechaB = _parseFecha(b.fecha);
        if (fechaA == null || fechaB == null) return 0;
        return fechaA.compareTo(fechaB);
      });

    // Filtrar partidos finalizados
    final finalizados = _partidos
        .where((p) => p.estado == 'FINALIZADO')
        .toList()
      ..sort((a, b) {
        final fechaA = _parseFecha(a.fecha);
        final fechaB = _parseFecha(b.fecha);
        if (fechaA == null || fechaB == null) return 0;
        return fechaB.compareTo(fechaA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.naranja,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Próximos Partidos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (proximosPartidos.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay próximos partidos',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ...proximosPartidos.map((p) => _buildPartidoCard(p, esProximo: true)),

        const SizedBox(height: 24),

        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.naranja,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Partidos Finalizados',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (finalizados.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay partidos finalizados',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ...finalizados.map((p) => _buildPartidoCard(p, esProximo: false)),
      ],
    );
  }

  Widget _buildPartidoCard(Partido partido, {required bool esProximo}) {
    final esLocal = partido.equipoLocalId == widget.equipo.id;
    final rival = esLocal ? partido.nombreVisitante : partido.nombreLocal;
    final resultado = esLocal
        ? '${partido.puntosLocal} - ${partido.puntosVisitante}'
        : '${partido.puntosVisitante} - ${partido.puntosLocal}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esProximo ? AppColors.naranja.withOpacity(0.3) : Colors.green.withOpacity(0.3),
        ),
      ),
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
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: esProximo ? AppColors.naranja.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  esProximo ? 'PROGRAMADO' : 'FINALIZADO',
                  style: TextStyle(
                    color: esProximo ? AppColors.naranja : Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                '${partido.fecha} - ${partido.hora}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
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
          if (!esProximo) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Resultado: $resultado',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}