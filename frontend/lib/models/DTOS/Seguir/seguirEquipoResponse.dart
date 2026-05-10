class SeguirEquipoResponseDTO {
  final String nombreEquipo;
  final String nombreLiga;

  SeguirEquipoResponseDTO({
    required this.nombreEquipo,
    required this.nombreLiga,
  });

  factory SeguirEquipoResponseDTO.fromJson(Map<String, dynamic> json) {
    return SeguirEquipoResponseDTO(
      nombreEquipo: json['nombreEquipo'] ?? '',
      nombreLiga: json['nombreLiga'] ?? '',
    );
  }
}
