// lib/screens/PartidosPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../models/partido.dart';
import '../services/partidoService.dart';
import '../widgets/MenuLateral.dart';
import '../widgets/Header.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/NavegadorJornadas.dart';
import '../widgets/Partidos/TarjetasPartidos.dart';

class PartidosPage extends StatefulWidget {
  const PartidosPage({super.key});

  @override
  State<PartidosPage> createState() => _PartidosPageState();
}

class _PartidosPageState extends State<PartidosPage> {
  int _jornadaActual = 1;
  final int _totalJornadas = 22;

  List<Partido> _todosPartidos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final partidos = await PartidoService.listarPartidos();
      setState(() {
        _todosPartidos = partidos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  List<Partido> get _partidosFiltrados {
    return _todosPartidos
        .where((p) => p.jornada == _jornadaActual)
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderApp(titulo: 'Partidos'),
      drawer: const MenuLateral(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Column(
            children: [
              NavegadorJornadas(
                jornadaActual: _jornadaActual,
                totalJornadas: _totalJornadas,
                onJornadaChanged: (nuevaJornada) {
                  setState(() {
                    _jornadaActual = nuevaJornada;
                  });
                },
              ),
              Expanded(
                child: _buildContenido(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BarraInferior(selectedIndex: 3),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blanco),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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

    if (_partidosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_basketball_outlined,
              size: 80,
              color: AppColors.blancoOpacidad70,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay partidos en esta jornada',
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Navega a otras jornadas usando las flechas',
              style: TextStyle(
                color: AppColors.blancoOpacidad70,
                fontSize: 14,
              ),
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
          return TarjetaPartido(partido: partido);
        },
      ),
    );
  }
}