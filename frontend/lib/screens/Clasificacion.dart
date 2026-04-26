// lib/screens/Clasificacion.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../data/gestorFavoritos.dart';
import '../models/equipo.dart';
import '../models/liga.dart';
import '../services/equipoService.dart';
import '../services/autenticacion_service.dart';
import '../widgets/Header.dart';
import '../widgets/MenuLateral.dart';
import 'equipos/DetalleEquipoPage.dart';

class ClasificacionPage extends StatefulWidget {
  final String categoriaEdad;
  final String categoriaNivel;

  const ClasificacionPage({
    super.key,
    required this.categoriaEdad,
    required this.categoriaNivel,
  });

  @override
  State<ClasificacionPage> createState() => _ClasificacionPageState();
}

class _ClasificacionPageState extends State<ClasificacionPage> {
  List<Equipo> _equipos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarClasificacion();
  }

  Future<void> _cargarClasificacion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final todosEquipos = await EquipoService.listarEquipos();

      // Filtrar equipos por liga
      final equiposFiltrados = todosEquipos.where((e) =>
      e.nombreLiga == widget.categoriaEdad
      ).toList();

      // Ordenar por puntos (descendente)
      equiposFiltrados.sort((a, b) => (b.puntos ?? 0).compareTo(a.puntos ?? 0));

      setState(() {
        _equipos = equiposFiltrados;
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
      appBar: const HeaderApp(titulo: "Clasificación"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : _buildClasificacion(),
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
            onPressed: _cargarClasificacion,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildClasificacion() {
    if (_equipos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No hay equipos en esta liga',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeaderLiga(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _equipos.length,
            itemBuilder: (context, index) {
              final equipo = _equipos[index];
              final esFavorito = FavoritosManager().equiposFavoritos.contains(equipo.nombre);
              return _buildEquipoRow(equipo, index + 1, esFavorito);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderLiga() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradienteNaranjaAmarillo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            widget.categoriaEdad,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_equipos.length} equipos',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipoRow(Equipo equipo, int posicion, bool esFavorito) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EquipoDetallePage(equipo: equipo),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: posicion <= 4 ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$posicion',
                    style: const TextStyle(
                      color: Colors.white,
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
                      equipo.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PJ: ${equipo.partidosJugados ?? 0} | PG: ${equipo.partidosGanados ?? 0} | PP: ${equipo.partidosPerdidos ?? 0}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '${equipo.puntos ?? 0} pts',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.naranja,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  esFavorito ? Icons.star : Icons.star_border,
                  color: esFavorito ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (esFavorito) {
                      FavoritosManager().eliminarEquipoFavorito(equipo.nombre);
                    } else {
                      FavoritosManager().agregarEquipoFavorito(equipo.nombre);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}