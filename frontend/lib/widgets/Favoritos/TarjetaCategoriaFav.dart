import 'package:flutter/material.dart';
import 'package:tfg_appfede/widgets/tarjetas/TarjetaEntidad.dart';

class TarjetaCategoria extends StatelessWidget {
  final String nombre;
  final String categoriaEdad;
  final String categoriaNivel;
  final VoidCallback onTap;

  const TarjetaCategoria({
    super.key,
    required this.nombre,
    required this.categoriaEdad,
    required this.categoriaNivel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaEntidad(
      tipo: TipoEntidad.liga,
      titulo: nombre,
      subtitulo: '$categoriaEdad · $categoriaNivel',
      onTap: onTap,
    );
  }
}
