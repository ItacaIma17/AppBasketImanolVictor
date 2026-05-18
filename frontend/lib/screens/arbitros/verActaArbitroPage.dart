import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/actaPartido.dart';
import '../../models/partido.dart';
import '../../services/actaService.dart';
import '../../utils/descarga_pdf.dart';
import 'CrearActaPage.dart';

class VerActaArbitroPage extends StatefulWidget {
  final Partido partido;

  const VerActaArbitroPage({super.key, required this.partido});

  @override
  State<VerActaArbitroPage> createState() => _VerActaArbitroPageState();
}

class _VerActaArbitroPageState extends State<VerActaArbitroPage> {
  bool _isLoading = true;
  ActaPartido? _acta;
  String? _error;
  bool _descargando = false;

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
      final acta = await ActaService.obtenerActaPorPartido(widget.partido.id);
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
      final bytes = await ActaService.descargarActaPdf(widget.partido.id);
      await guardarYAbrirPdf(bytes, 'acta_partido_${widget.partido.id}.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acta del Partido'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(_error!, textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarActa,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _acta == null
                  ? const Center(child: Text('No se encontró el acta'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final acta = _acta!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (acta.tieneArchivoSubido)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.picture_as_pdf,
                          color: Colors.orange, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            'Acta subida como archivo — usa el botón para descargar el PDF.',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                  ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${acta.equipoLocal} vs ${acta.equipoVisitante}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(acta.fechaActa)}'),
                        Text('Árbitro: ${acta.arbitroNombre}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.emoji_events,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'Resultado: ${acta.resultadoLocal} - ${acta.resultadoVisitante}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Eventos del Partido',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (acta.eventos.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: Text('No hay eventos registrados')),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: acta.eventos.length,
                            itemBuilder: (context, index) {
                              final evento = acta.eventos[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _getTipoColor(evento.tipo),
                                  child: Text(_getTipoIcon(evento.tipo)),
                                ),
                                title: Text(
                                    '${evento.nombreJugador} - ${evento.nombreEquipo}'),
                                subtitle: Text(
                                    'Minuto ${evento.minuto}: ${evento.descripcion ?? evento.tipo}'),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                if (acta.observaciones != null &&
                    acta.observaciones!.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Observaciones',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(acta.observaciones!),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CrearActaPage(
                        partido: widget.partido,
                        actaExistente: _acta,
                      ),
                    ),
                  ).then((_) => _cargarActa()),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Editar Acta',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    _descargando ? 'Generando...' : 'Descargar PDF',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'CANASTA':
      case 'TIRO_LIBRE':
      case 'TIRO_3PUNTOS':
        return Colors.green;
      case 'FALTA':
      case 'TECNICA':
        return Colors.orange;
      case 'EXPULSION':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'CANASTA':
        return '🏀';
      case 'TIRO_LIBRE':
        return '⬜';
      case 'TIRO_3PUNTOS':
        return '3️⃣';
      case 'FALTA':
        return '✋';
      case 'TECNICA':
        return '🟡';
      case 'EXPULSION':
        return '⛔';
      default:
        return '•';
    }
  }
}
