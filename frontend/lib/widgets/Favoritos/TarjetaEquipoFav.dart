import 'package:flutter/material.dart';
import 'package:tfg_appfede/widgets/tarjetas/TarjetaEntidad.dart';

class TarjetaEquipo extends StatelessWidget {
  final String nombre;
  final String posicion;
  final String proximoPartido;
  final String rival;
  final bool esLocal;
  final VoidCallback onTap;

  const TarjetaEquipo({
    super.key,
    required this.nombre,
    required this.posicion,
    required this.proximoPartido,
    required this.rival,
    required this.esLocal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final infos = <TarjetaInfo>[];

    if (proximoPartido != 'Descanso' && proximoPartido.isNotEmpty) {
      infos.add(TarjetaInfo(
        icono: Icons.calendar_today,
        texto: proximoPartido,
      ));
    }
    if (rival.isNotEmpty) {
      infos.add(TarjetaInfo(
        icono: esLocal ? Icons.home : Icons.flight_takeoff,
        texto: rival,
      ));
    }
    if (proximoPartido == 'Descanso') {
      infos.add(const TarjetaInfo(
        icono: Icons.bedtime,
        texto: 'Descanso',
      ));
    }

    return TarjetaEntidad(
      tipo: TipoEntidad.equipo,
      titulo: nombre,
      badge: posicion,
      infos: infos,
      onTap: onTap,
    );
  }
}
