import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/partido.dart';
import 'package:tfg_appfede/services/PartidoService.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/NavegadorJornadas.dart';
import 'package:tfg_appfede/widgets/partidos/TarjetasPartidos.dart';

class PartidosPage extends StatefulWidget {
  const PartidosPage({super.key});

  @override
  State<PartidosPage> createState() => _PartidosPageState();
}

class _PartidosPageState extends State<PartidosPage> {
  int _jornadaActual = 15; // Jornada actual seleccionada
  final int _totalJornadas = 22; // Total de jornadas en la temporada

  List<Partido> _partidos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  /// Cargar partidos desde la BD
  void _cargarPartidos() async {
    try {
      final partidos = await PartidoService.listarPartidos();
      setState(() {
        _partidos = partidos;
        _cargando = false;
      });
    } catch (e) {
      print("Error cargando partidos: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderApp(titulo: 'Partidos'),
      drawer: const MenuLateral(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Navegación de jornadas
              NavegadorJornadas(
                jornadaActual: _jornadaActual,
                totalJornadas: _totalJornadas,
                onJornadaChanged: (nuevaJornada) {
                  setState(() {
                    _jornadaActual = nuevaJornada;
                  });
                },
              ),

              // Contenido - Lista de ligas con sus partidos
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

  /// Contenido principal - Partidos
  Widget _buildContenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: AppColors.blanco));
    }

    if (_partidos.isEmpty) {
      return _buildEstadoVacio();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _partidos.length,
      itemBuilder: (context, index) {
        final partido = _partidos[index];
        return TarjetaPartido(partido: partido);
      },
    );
  }

  /// Estado vacío cuando no hay partidos
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sports_basketball_outlined,
            size: 100,
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
}