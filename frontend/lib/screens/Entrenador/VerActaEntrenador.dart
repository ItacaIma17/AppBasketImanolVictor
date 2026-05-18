import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/actaPartido.dart';
import '../../services/actaService.dart';
import '../../utils/descarga_pdf.dart';

class VerActaEntrenadorPage extends StatefulWidget {
  final int partidoId;

  const VerActaEntrenadorPage({super.key, required this.partidoId});

  @override
  State<VerActaEntrenadorPage> createState() => _VerActaEntrenadorPageState();
}

class _VerActaEntrenadorPageState extends State<VerActaEntrenadorPage> {
  ActaPartido? _acta;
  bool _isLoading = true;
  String? _error;
  bool _descargando = false;

  static const _acento = AppColors.naranja;

  @override
  void initState() {
    super.initState();
    _cargarActa();
  }

  Future<void> _cargarActa() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final acta = await ActaService.obtenerActaPorPartido(widget.partidoId);
      setState(() {
        _acta = acta;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _descargarPdf() async {
    if (_descargando) return;
    setState(() => _descargando = true);
    try {
      final bytes = await ActaService.descargarActaPdf(widget.partidoId);
      await guardarYAbrirPdf(bytes, 'acta_partido_${widget.partidoId}.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _acento))
          : _error != null
              ? _buildError()
              : _acta == null
                  ? const Center(child: Text('No se encontró el acta', style: TextStyle(color: AppColors.blanco)))
                  : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(_error!,
              style: const TextStyle(color: AppColors.blanco),
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _cargarActa,
          style: ElevatedButton.styleFrom(backgroundColor: _acento),
          child: const Text('Reintentar'),
        ),
      ]),
    );
  }

  Widget _buildContent() {
    final acta = _acta!;
    final eventos = [...acta.eventos]
      ..sort((a, b) => a.minuto.compareTo(b.minuto));

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              if (acta.tieneArchivoSubido) _buildArchivoNotice(),
              _buildScoreCard(acta),
              const SizedBox(height: 12),
              _buildInfoCard(acta),
              if (acta.observaciones != null &&
                  acta.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildObservacionesCard(acta.observaciones!),
              ],
              const SizedBox(height: 16),
              _buildEventosSection(eventos),
              const SizedBox(height: 16),
              _buildPdfButton(),
            ]),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _acento,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.gradienteEntrenador),
          child: const SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 48),
                  Icon(Icons.description, color: AppColors.blanco, size: 28),
                  SizedBox(height: 6),
                  Text('Acta del Partido',
                      style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ]),
          ),
        ),
        title: const Text('Acta del Partido',
            style: TextStyle(
                color: AppColors.blanco,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildScoreCard(ActaPartido acta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _acento.withOpacity(0.3)),
      ),
      child: Row(children: [
        Expanded(
          child: Text(
            acta.equipoLocal,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 14,
                fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.gradienteEntrenador,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${acta.resultadoLocal} - ${acta.resultadoVisitante}',
            style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            acta.equipoVisitante,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 14,
                fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  Widget _buildInfoCard(ActaPartido acta) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(children: [
        _buildInfoRow(Icons.sports, 'Árbitro', acta.arbitroNombre),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.calendar_today,
          'Fecha',
          DateFormat('dd/MM/yyyy HH:mm').format(acta.fechaActa),
        ),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: _acento, size: 16),
      const SizedBox(width: 8),
      Text('$label: ',
          style:
              const TextStyle(color: AppColors.grisClaro, fontSize: 12)),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 12,
              fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _buildObservacionesCard(String obs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _acento.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _acento.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.notes, color: _acento, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Observaciones',
                style: TextStyle(
                    color: AppColors.naranja,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(obs,
                style: const TextStyle(
                    color: AppColors.blanco, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 5),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEventosSection(List<EventoActa> eventos) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.sports_basketball, color: _acento, size: 18),
        const SizedBox(width: 8),
        Text(
          'Eventos del Partido (${eventos.length})',
          style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
      ]),
      const SizedBox(height: 10),
      if (eventos.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.superficie1,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('Sin eventos registrados',
                style: TextStyle(
                    color: AppColors.grisClaro, fontSize: 13)),
          ),
        )
      else
        ...eventos.map(_buildEventoItem),
    ]);
  }

  Widget _buildEventoItem(EventoActa evento) {
    final info = _tipoInfo(evento.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: info.color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(info.icon, color: info.color, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nombreJugador,
                  style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '${evento.nombreEquipo} · ${info.label}',
                  style: const TextStyle(
                      color: AppColors.grisClaro, fontSize: 11),
                ),
              ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            "${evento.minuto}'",
            style: TextStyle(
                color: info.color,
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
          if (evento.puntos != null)
            Text(
              '+${evento.puntos}pts',
              style: const TextStyle(
                  color: AppColors.grisClaro, fontSize: 10),
            ),
        ]),
      ]),
    );
  }

  _TipoInfo _tipoInfo(String tipo) {
    switch (tipo) {
      case 'CANASTA':
        return _TipoInfo(Icons.sports_basketball, _acento, 'Canasta (2 pts)');
      case 'TIRO_3PUNTOS':
        return _TipoInfo(Icons.filter_3, Colors.green, 'Triple (3 pts)');
      case 'TIRO_LIBRE':
        return _TipoInfo(Icons.sports_score, Colors.blue, 'Tiro libre (1 pt)');
      case 'FALTA':
        return _TipoInfo(Icons.warning_amber, Colors.orange, 'Falta');
      case 'TECNICA':
        return _TipoInfo(Icons.credit_card, Colors.red, 'T. Técnica');
      case 'EXPULSION':
        return _TipoInfo(Icons.cancel, Colors.red, 'Expulsión');
      default:
        return _TipoInfo(Icons.circle, AppColors.grisClaro, tipo);
    }
  }

  Widget _buildArchivoNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _acento.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _acento.withOpacity(0.4)),
      ),
      child: const Row(children: [
        Icon(Icons.picture_as_pdf, color: _acento, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text('Acta subida como archivo — usa el botón para descargar el PDF.',
              style: TextStyle(color: AppColors.blanco, fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _buildPdfButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _descargando ? null : _descargarPdf,
        icon: _descargando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: Text(
          _descargando ? 'Generando PDF...' : 'Descargar PDF',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _acento,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _TipoInfo {
  final IconData icon;
  final Color color;
  final String label;
  const _TipoInfo(this.icon, this.color, this.label);
}
