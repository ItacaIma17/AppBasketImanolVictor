// lib/screens/JugadorDetallePage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../models/jugador.dart';
import '../services/FavoritosPage.dart';
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
  bool _esFavorito = false;
  bool _cargandoFavorito = true;

  @override
  void initState() {
    super.initState();
    _verificarFavorito();
  }

  Future<void> _verificarFavorito() async {
    try {
      final esFav = await FavoritosService.esJugadorFavorito(widget.jugador.id);
      if (mounted) {
        setState(() {
          _esFavorito = esFav;
          _cargandoFavorito = false;
        });
      }
    } catch (e) {
      print('Error verificando favorito: $e');
      if (mounted) {
        setState(() {
          _cargandoFavorito = false;
        });
      }
    }
  }

  Future<void> _toggleFavorito() async {
    if (widget.jugador.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede guardar favorito: ID inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _cargandoFavorito = true);

    try {
      if (_esFavorito) {
        await FavoritosService.eliminarJugadorFavorito(widget.jugador.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Eliminado de favoritos'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await FavoritosService.agregarJugadorFavorito(
          widget.jugador.id,
          widget.jugador.nombreCompleto,
          equipoNombre: widget.equipoNombre ?? widget.jugador.nombreEquipo,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⭐ Añadido a favoritos'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _esFavorito = !_esFavorito;
        });
      }
    } catch (e) {
      print('Error toggling favorito: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar favorito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargandoFavorito = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: HeaderApp(
        titulo: widget.jugador.nombreCompleto,
        actions: [
          if (!_cargandoFavorito && widget.jugador.id != null)
            IconButton(
              icon: Icon(
                _esFavorito ? Icons.star : Icons.star_border,
                color: _esFavorito ? Colors.amber : Colors.white,
                size: 28,
              ),
              onPressed: _toggleFavorito,
              tooltip: _esFavorito ? 'Eliminar de favoritos' : 'Añadir a favoritos',
            ),
          if (_cargandoFavorito)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
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
                if ((widget.equipoNombre ?? widget.jugador.nombreEquipo) != null)
                  _buildInfoEquipo(),
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
                  _buildInfoItem('Altura', widget.jugador.alturaFormateada),
                  _buildInfoItem('Peso', widget.jugador.pesoFormateado),
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
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoSmall('Partidos', widget.jugador.partidosJugados.toString()),
                _buildInfoSmall('Puntos Totales', widget.jugador.puntosTotales.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSmall(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.naranja),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
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
    final equipo = widget.equipoNombre ?? widget.jugador.nombreEquipo;
    if (equipo == null) return const SizedBox.shrink();

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
                  Text(equipo, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}