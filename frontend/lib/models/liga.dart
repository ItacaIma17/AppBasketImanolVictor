// lib/models/liga.dart
class Liga {
  final int? id;
  final String nombreLiga;
  final String? pais;
  final int numeroEquipos;
  final String? temporada;
  final int numeroEquiposRegistrados;

  Liga({
    this.id,
    required this.nombreLiga,
    this.pais,
    required this.numeroEquipos,
    this.temporada,
    required this.numeroEquiposRegistrados,
  });

  factory Liga.fromJson(Map<String, dynamic> json) {
    return Liga(
      id: json['id'],
      nombreLiga: json['nombreLiga'] ?? '',
      pais: json['pais'],
      numeroEquipos: json['numeroEquipos'] ?? 0,
      temporada: json['temporada'],
      numeroEquiposRegistrados: json['numeroEquiposRegistrados'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreLiga': nombreLiga,
      'pais': pais,
      'numeroEquipos': numeroEquipos,
      'temporada': temporada,
      'numeroEquiposRegistrados': numeroEquiposRegistrados,
    };
  }
}