import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tfg_appfede/models/partido.dart';
import 'package:tfg_appfede/models/role.dart';
import 'package:tfg_appfede/widgets/DetallesPartidos/EstadisticasPartido.dart';
import 'package:tfg_appfede/widgets/DetallesPartidos/MarcadorPartido.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tfg_appfede/models/actaPartido.dart';
import 'package:tfg_appfede/services/actaService.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/screens/arbitros/CrearActaPage.dart';
import 'package:tfg_appfede/screens/arbitros/verActaArbitroPage.dart';

class DetallePartidoPage extends StatefulWidget {
  final Partido partido;
  final Role? userRole;

  const DetallePartidoPage({
    super.key,
    required this.partido,
    this.userRole,
  });

  @override
  State<DetallePartidoPage> createState() => _DetallePartidoPageState();
}

class _DetallePartidoPageState extends State<DetallePartidoPage> {
  // Estadísticas del partido
  late Map<String, dynamic> _estadisticas;

  // Acta del partido
  ActaPartido? _acta;
  bool _cargandoActa = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
    _cargarActa();
  }

  void _cargarEstadisticas() {
    _estadisticas = {
      'equipoLocal': {
        'puntos': widget.partido.puntosLocal,
        'rebotes': 42,
        'asistencias': 18,
        'robos': 8,
        'tapones': 5,
        'faltas': 20,
      },
      'equipoVisitante': {
        'puntos': widget.partido.puntosVisitante,
        'rebotes': 38,
        'asistencias': 15,
        'robos': 6,
        'tapones': 3,
        'faltas': 22,
      },
    };
  }

  Future<void> _cargarActa() async {
    setState(() => _cargandoActa = true);
    try {
      final acta = await ActaService.obtenerActaPorPartido(widget.partido.id);
      if (mounted) setState(() { _acta = acta; _cargandoActa = false; });
    } catch (_) {
      if (mounted) setState(() { _acta = null; _cargandoActa = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Widget separado - Marcador
                      MarcadorPartido(partido: widget.partido),

                      const SizedBox(height: 24),

                      // Widget separado - Estadísticas
                      EstadisticasPartido(estadisticas: _estadisticas),

                      const SizedBox(height: 24),

                      // Acta del partido
                      _buildActaPartido(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.negro,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51), // Reemplaza withOpacity(0.2)
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalles del Partido',
                style: TextStyle(
                  color: AppColors.blanco,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Partido ${widget.partido.id} - ${widget.partido.fecha}',
                style: TextStyle(
                  color: AppColors.blancoOpacidad70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Acta del Partido - Simplificada
  /// Solo 2 acciones: SUBIR (árbitros) y VER (todos)
  Widget _buildActaPartido() {
    final rol = widget.userRole ?? AutenticacionService.usuarioActual?.role;
    final esArbitro = rol == Role.ARBITRO;
    final esAdmin = rol == Role.ADMIN;
    final puedeEditar = esArbitro || esAdmin;

    if (_cargandoActa) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: AppColors.naranja)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: AppColors.naranja, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Acta del Partido',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (_acta != null && puedeEditar)
                IconButton(
                  tooltip: 'Editar acta',
                  icon: const Icon(Icons.edit, color: AppColors.naranja),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CrearActaPage(partido: widget.partido)));
                    _cargarActa();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_acta != null) ...[
            _buildResumenActa(_acta!),
            const SizedBox(height: 16),
            _buildIncidenciasActa(_acta!),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => VerActaArbitroPage(partido: widget.partido))),
                icon: const Icon(Icons.visibility, color: AppColors.blanco),
                label: const Text('Ver acta completa',
                    style: TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.pending, color: Colors.orange.shade700, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      puedeEditar
                          ? 'Acta pendiente. Crea el acta tras el partido.'
                          : 'El árbitro aún no ha creado el acta.',
                      style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            if (puedeEditar) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CrearActaPage(partido: widget.partido)));
                    _cargarActa();
                  },
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.blanco),
                  label: const Text('Crear Acta',
                      style: TextStyle(color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResumenActa(ActaPartido acta) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(acta.equipoLocal,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                    Text(acta.resultadoLocal,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.naranja)),
                  ],
                ),
              ),
              const Text('—', style: TextStyle(fontSize: 22, color: Colors.grey)),
              Expanded(
                child: Column(
                  children: [
                    Text(acta.equipoVisitante,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                    Text(acta.resultadoVisitante,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.naranja)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(Icons.person, 'Árbitro: ${acta.arbitroNombre}'),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time,
              'Fecha: ${acta.fechaActa.day}/${acta.fechaActa.month}/${acta.fechaActa.year}'),
          if ((acta.observaciones ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoRow(Icons.notes, acta.observaciones!),
          ],
        ],
      ),
    );
  }

  Widget _buildIncidenciasActa(ActaPartido acta) {
    if (acta.eventos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Sin incidencias registradas',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Incidencias',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...acta.eventos.take(8).map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.naranja.withAlpha(38), // Reemplaza withOpacity(0.15)
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("'${e.minuto}",
                    style: const TextStyle(
                        color: AppColors.naranja,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${e.tipo} · ${e.nombreJugador} (${e.nombreEquipo})${e.puntos != null ? " · ${e.puntos} pts" : ""}',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
        if (acta.eventos.length > 8)
          Text('... y ${acta.eventos.length - 8} incidencias más',
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // ==================== HELPER ====================

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }
}