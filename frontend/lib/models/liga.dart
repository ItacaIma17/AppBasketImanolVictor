// lib/models/liga.dart - CORREGIDO (parámetros opcionales)

class Liga {
  final int? id;
  final String nombreLiga;
  final String? pais;
  final int? numeroEquipos;  // ← Hacer opcional
  final String? temporada;
  final int? numeroEquiposRegistrados;  // ← Hacer opcional
  final String? descripcion;  // ← Hacer opcional

  Liga({
    this.id,
    required this.nombreLiga,
    this.pais,
    this.numeroEquipos,
    this.temporada,
    this.numeroEquiposRegistrados,
    this.descripcion,
  });

  factory Liga.fromJson(Map<String, dynamic> json) {
    return Liga(
      id: json['id'],
      nombreLiga: json['nombreLiga'] ?? '',
      pais: json['pais'],
      descripcion: json['descripcion'],
      numeroEquipos: json['numeroEquipos'],
      temporada: json['temporada'],
      numeroEquiposRegistrados: json['numeroEquiposRegistrados'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreLiga': nombreLiga,
      'pais': pais,
      'descripcion': descripcion,
      'numeroEquipos': numeroEquipos,
      'temporada': temporada,
      'numeroEquiposRegistrados': numeroEquiposRegistrados,
    };
  }
}