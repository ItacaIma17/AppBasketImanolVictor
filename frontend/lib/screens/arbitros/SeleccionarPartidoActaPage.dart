// lib/screens/Arbitro/SeleccionarPartidoActaPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import 'CrearActaPage.dart';

class SeleccionarPartidoActaPage extends StatefulWidget {
  const SeleccionarPartidoActaPage({super.key});

  @override
  State<SeleccionarPartidoActaPage> createState() =>
      _SeleccionarPartidoActaPageState();
}

class _SeleccionarPartidoActaPageState
    extends State<SeleccionarPartidoActaPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;
  String? _error;

  get ArbitroService => null;

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
        _partidos = partidos.where((p) => !p.estaFinalizado).toList();
        _isLoading = false;
      });
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
      appBar: const HeaderApp(titulo: "Seleccionar Partido para Acta"),
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
            onPressed: _cargarPartidos,
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
              'No hay partidos pendientes',
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
        itemCount: _partidos.length,
        itemBuilder: (context, index) {
          final partido = _partidos[index];
          return _buildPartidoCard(partido);
        },
      ),
    );
  }

  Widget _buildPartidoCard(Partido partido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrearActaPage(partido: partido),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${partido.equipoLocal} vs ${partido.equipoVisitante}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(partido.fecha),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    partido.ubicacion ?? 'Sin ubicación',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Crear acta del partido'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}