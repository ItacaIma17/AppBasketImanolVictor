import 'dart:ffi';

class LigaRequestDTO {
  final String nombreLiga;
  final String descripcion;
  final int numeroEquipos;

  LigaRequestDTO({
    required this.nombreLiga,
    required this.descripcion,
    required this.numeroEquipos,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreLiga': nombreLiga,
      'descripcion': descripcion,
      'numeroEquipos':numeroEquipos
    };
  }
}
