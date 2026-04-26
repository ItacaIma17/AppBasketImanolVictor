// Pantalla para ver acta (árbitro)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/actaPartido.dart';
import '../../services/actaService.dart';

class VerActaArbitroPage extends StatefulWidget {
  final int partidoId;

  const VerActaArbitroPage({super.key, required this.partidoId});

  @override
  State<VerActaArbitroPage> createState() => _VerActaArbitroPageState();
}

class _VerActaArbitroPageState extends State<VerActaArbitroPage> {
  bool _isLoading = true;
  ActaPartido? _acta;
  String? _error;

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
    try {
      final file = await ActaService.descargarActaPdf(widget.partidoId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF guardado en: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acta del Partido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _descargarPdf,
            tooltip: 'Descargar PDF',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarActa,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      )
          : _acta == null
          ? const Center(child: Text('No se encontró el acta'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '${_acta!.equipoLocal} vs ${_acta!.equipoVisitante}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(_acta!.fechaActa)}'),
                    Text('Árbitro: ${_acta!.arbitroNombre}'),
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
                          const Icon(Icons.emoji_events, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Resultado: ${_acta!.resultadoLocal} - ${_acta!.resultadoVisitante}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_acta!.eventos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('No hay eventos registrados')),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _acta!.eventos.length,
                        itemBuilder: (context, index) {
                          final evento = _acta!.eventos[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getTipoColor(evento.tipo),
                              child: Text(_getTipoIcon(evento.tipo)),
                            ),
                            title: Text('${evento.nombreJugador} - ${evento.nombreEquipo}'),
                            subtitle: Text('Minuto ${evento.minuto}: ${evento.descripcion ?? evento.tipo}'),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_acta!.observaciones != null && _acta!.observaciones!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Observaciones',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_acta!.observaciones!),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
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
        return '⚠️';
      case 'TECNICA':
        return '📋';
      case 'EXPULSION':
        return '🚫';
      default:
        return '📌';
    }
  }
}