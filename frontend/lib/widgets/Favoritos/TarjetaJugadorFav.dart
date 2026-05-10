import 'package:flutter/material.dart';
import 'package:tfg_appfede/widgets/tarjetas/TarjetaEntidad.dart';

class TarjetaJugador extends StatelessWidget {
  final String nombre;
  final String equipo;
  final double puntos;
  final double rebotes;
  final double asistencias;
  final VoidCallback onTap;

  const TarjetaJugador({
    super.key,
    required this.nombre,
    required this.equipo,
    required this.puntos,
    required this.rebotes,
    required this.asistencias,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaEntidad(
      tipo: TipoEntidad.jugador,
      titulo: nombre,
      subtitulo: equipo,
      chips: [
        TarjetaChip('${puntos.toStringAsFixed(1)} PTS',
            icono: Icons.sports_basketball),
        TarjetaChip('${rebotes.toStringAsFixed(1)} REB',
            icono: Icons.swap_vert),
        TarjetaChip('${asistencias.toStringAsFixed(1)} AST',
            icono: Icons.handshake),
      ],
      onTap: onTap,
    );
  }
}
