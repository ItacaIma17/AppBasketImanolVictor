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
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? _parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Liga(
      id: _parseIntNullable(json['id']),
      nombreLiga: json['nombreLiga'] ?? '',
      pais: json['pais'],
      numeroEquipos: _parseInt(json['numeroEquipos']),
      temporada: json['temporada'],
      numeroEquiposRegistrados: _parseInt(json['numeroEquiposRegistrados']),
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