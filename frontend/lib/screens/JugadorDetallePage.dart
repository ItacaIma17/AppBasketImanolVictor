// lib/screens/JugadorDetallePage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../data/gestorFavoritos.dart';
import '../models/jugador.dart';
import '../widgets/Header.dart';
import '../widgets/MenuLateral.dart';

class JugadorDetallePage extends StatefulWidget {
  final Jugador jugador;
  final String? equipoNombre;

  const JugadorDetallePage({super.key, required this.jugador, this.equipoNombre});

  @override
  State<JugadorDetallePage> createState() => _JugadorDetallePageState();
}

class _JugadorDetallePageState extends State<JugadorDetallePage> {
  @override
  Widget build(BuildContext context) {
    final esFavorito = FavoritosManager().esJugadorFavorito(widget.jugador.nombreCompleto);

    return Scaffold(
      drawer: const MenuLateral(),
      appBar: HeaderApp(
        titulo: widget.jugador.nombreCompleto,
        actions: [
          IconButton(
            icon: Icon(
              esFavorito ? Icons.star : Icons.star_border,
              color: esFavorito ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (esFavorito) {
                  FavoritosManager().eliminarJugadorFavorito(widget.jugador.nombreCompleto);
                } else {
                  FavoritosManager().agregarJugadorFavorito(widget.jugador.nombreCompleto);
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoJugador(),
                const SizedBox(height: 16),
                _buildEstadisticas(),
                const SizedBox(height: 16),
                if (widget.equipoNombre != null) _buildInfoEquipo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoJugador() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradienteNaranjaAmarillo,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  widget.jugador.iniciales,
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.jugador.nombreCompleto,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(widget.jugador.posicion),
                backgroundColor: Colors.white.withOpacity(0.3),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem('Dorsal', widget.jugador.dorsal.toString()),
                  _buildInfoItem('Altura', '${widget.jugador.altura}m'),
                  _buildInfoItem('Peso', '${widget.jugador.peso}kg'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildEstadisticas() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas de la temporada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildEstadisticaItem('Puntos', widget.jugador.promedioPuntos.toStringAsFixed(1)),
                _buildEstadisticaItem('Rebotes', widget.jugador.promedioRebotes.toStringAsFixed(1)),
                _buildEstadisticaItem('Asistencias', widget.jugador.promedioAsistencias.toStringAsFixed(1)),
                _buildEstadisticaItem('Robos', widget.jugador.promedioRobos.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.naranja),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoEquipo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.sports_basketball, size: 40, color: AppColors.naranja),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Equipo Actual', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.equipoNombre!, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}