// lib/screens/Admin/DetallePartidoAdminPage.dart

import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../services/partidoService.dart';
import '../../services/actaService.dart';
import '../../services/equipoService.dart';
import '../../models/actaPartido.dart';
// ✅ FIX nav: para abrir el perfil del equipo desde el detalle del partido.
import '../Equipos.dart';
// ✅ FIX edit: reutilizamos el dialog ya existente (modo edición).
import '../../widgets/Partidos/CrearPartidosCompletosDialog.dart';

class DetallePartidoAdminPage extends StatefulWidget {
  final Partido partido;

  const DetallePartidoAdminPage({super.key, required this.partido});

  @override
  State<DetallePartidoAdminPage> createState() => _DetallePartidoAdminPageState();
}

class _DetallePartidoAdminPageState extends State<DetallePartidoAdminPage> {
  bool _cargando = false;
  ActaPartido? _acta;

  @override
  void initState() {
    super.initState();
    _cargarActa();
  }

  Future<void> _cargarActa() async {
    setState(() => _cargando = true);
    try {
      final acta = await ActaService.obtenerActaPorPartido(widget.partido.id);
      if (mounted) setState(() => _acta = acta);
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _finalizarPartido() async {
    final resultado = await showDialog<Map<String, int>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Finalizar Partido', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Resultado Local', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              onChanged: (v) => resultadoLocal = int.tryParse(v) ?? 0,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Resultado Visitante', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              onChanged: (v) => resultadoVisitante = int.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, {'local': resultadoLocal, 'visitante': resultadoVisitante}),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (resultado != null && mounted) {
      setState(() => _cargando = true);
      try {
        await PartidoService.finalizarPartido(
          widget.partido.id,
          resultado['local']!,
          resultado['visitante']!,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Partido finalizado correctamente'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  int resultadoLocal = 0;
  int resultadoVisitante = 0;

  /// ✅ FIX: abre CrearPartidoCompletoDialog en modo edición, reutilizando
  /// la misma ruta/dialog que ya usa GestionPartidos. Recarga el acta al
  /// cerrar para reflejar los cambios.
  Future<void> _editarPartido() async {
    setState(() => _cargando = true);
    try {
      final equipos = await EquipoService.listarEquipos();
      if (!mounted) return;
      setState(() => _cargando = false);

      await showDialog(
        context: context,
        builder: (_) => CrearPartidoCompletoDialog(
          equipos: equipos,
          partidoToEdit: widget.partido,
          ligaIdInicial: widget.partido.ligaId,
          onPartidoCreado: () {
            if (mounted) Navigator.pop(context, true); // refresca lista al volver
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error abriendo edición: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esProgramado = widget.partido.estado == 'PROGRAMADO';
    final esFinalizado = widget.partido.estado == 'FINALIZADO';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          '${widget.partido.nombreLocal} vs ${widget.partido.nombreVisitante}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (esProgramado)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Editar partido',
              // ✅ FIX: el botón estaba vacío (TODO). Reusamos el dialog
              // CrearPartidoCompletoDialog en modo edición, igual que
              // GestionPartidos._editarPartido.
              onPressed: _editarPartido,
            ),
          if (esProgramado)
            IconButton(
              icon: const Icon(Icons.sports_score, color: Colors.green),
              onPressed: _finalizarPartido,
              tooltip: 'Finalizar partido',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: _cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              if (_acta != null) _buildActaCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // ✅ FIX nav: equipo local clicable -> EquipoPage(equipoId)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.partido.equipoLocalId == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EquipoPage(
                              equipoId: widget.partido.equipoLocalId!,
                            ),
                          ),
                        ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.naranja.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield, size: 30, color: AppColors.naranja),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.partido.nombreLocal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.naranja.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.partido.resultadoTexto,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.naranja),
                ),
              ),
              // ✅ FIX nav: equipo visitante clicable -> EquipoPage(equipoId)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.partido.equipoVisitanteId == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EquipoPage(
                              equipoId: widget.partido.equipoVisitanteId!,
                            ),
                          ),
                        ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.amarilloAragon.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield, size: 30, color: AppColors.amarilloAragon),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.partido.nombreVisitante,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          _buildInfoRow(Icons.calendar_today, 'Fecha', '${widget.partido.fecha} ${widget.partido.hora}'),
          _buildInfoRow(Icons.location_on, 'Pabellón', widget.partido.pabellon),
          _buildInfoRow(Icons.map, 'Ubicación', widget.partido.direccionPabellon),
          if (widget.partido.jornada != null)
            _buildInfoRow(Icons.emoji_events, 'Jornada', 'Jornada ${widget.partido.jornada}'),
          _buildInfoRow(Icons.sports_score, 'Estado', widget.partido.estado),
        ],
      ),
    );
  }

  Widget _buildActaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: AppColors.naranja),
              SizedBox(width: 8),
              Text('Acta del Partido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (_acta != null) ...[
            _buildInfoRow(Icons.person, 'Árbitro', _acta!.arbitroNombre),
            _buildInfoRow(Icons.calendar_today, 'Fecha acta', _acta!.fechaActa.toString().substring(0, 16)),
            if (_acta!.observaciones != null && _acta!.observaciones!.isNotEmpty)
              _buildInfoRow(Icons.notes, 'Observaciones', _acta!.observaciones!),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navegar a ver acta completa
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Ver acta completa'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.naranja),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}