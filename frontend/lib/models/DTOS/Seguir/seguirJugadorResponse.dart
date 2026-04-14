// lib/models/dtos/seguir_response.dart
class SeguirJugadorResponseDTO {
  final String nombreJugador;
  final String posicion;
  final String nombreEquipoJugador;

  SeguirJugadorResponseDTO({
    required this.nombreJugador,
    required this.posicion,
    required this.nombreEquipoJugador,
  });

  factory SeguirJugadorResponseDTO.fromJson(Map<String, dynamic> json) {
    return SeguirJugadorResponseDTO(
      nombreJugador: json['nombreJugador'] ?? '',
      posicion: json['posicion'] ?? '',
      nombreEquipoJugador: json['nombreEquipoJugador'] ?? '',
    );
  }
}

