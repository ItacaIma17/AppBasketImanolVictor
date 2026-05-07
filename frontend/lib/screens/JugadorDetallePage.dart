import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../data/gestorFavoritos.dart';
import '../models/jugador.dart';
import '../widgets/Header.dart';
import '../widgets/MenuLateral.dart';

class JugadorDetallePage extends StatefulWidget {
  final Jugador jugador;
  final String? equipoNombre;

  const JugadorDetallePage({
    super.key,
    required this.jugador,
    this.equipoNombre,
  });

  @override
  State<JugadorDetallePage> createState() => _JugadorDetallePageState();
}

class _JugadorDetallePageState extends State<JugadorDetallePage> {
  @override
  Widget build(BuildContext context) {
    final esFavorito = FavoritosManager().esJugadorFavorito(widget.jugador.id!);

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
                FavoritosManager().toggleJugadorFavorito(widget.jugador.id!);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    FavoritosManager().esJugadorFavorito(widget.jugador.id!)
                        ? 'Jugador añadido a favoritos'
                        : 'Jugador eliminado de favoritos',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
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
                _buildPromedios(),
                const SizedBox(height: 16),
                if (widget.equipoNombre != null) _buildInfoEquipo(),
                const SizedBox(height: 20),
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
                  widget.jugador.dorsal.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.jugador.nombreCompleto,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
              const SizedBox(height: 12),
              _buildInfoRow('Posición', widget.jugador.posicion),
              _buildInfoRow('Edad', '${widget.jugador.edad} años'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromedios() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              Expanded(
                child: _buildPromedioCard(
                  'Puntos',
                  widget.jugador.promedioPuntos.toStringAsFixed(1),
                  AppColors.naranja,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPromedioCard(
                  'Rebotes',
                  widget.jugador.promedioRebotes.toStringAsFixed(1),
                  AppColors.amarilloAragon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPromedioCard(
                  'Asistencias',
                  widget.jugador.promedioAsistencias.toStringAsFixed(1),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPromedioCard(
                  'Robos',
                  widget.jugador.promedioRobos.toStringAsFixed(1),
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromedioCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
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
            const Icon(Icons.sports_basketball,
                size: 40, color: AppColors.naranja),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Equipo Actual',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.equipoNombre!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}