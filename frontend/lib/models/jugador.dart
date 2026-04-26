// lib/models/jugador.dart
class Jugador {
  final int? id;
  final String nombre;
  final String apellido;
  final String posicion;
  final double altura;
  final double peso;
  final int? dorsal;  // ← Añadir dorsal
  final double promedioPuntos;
  final double promedioRebotes;
  final double promedioAsistencias;
  final double promedioRobos;

  Jugador({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.posicion,
    required this.altura,
    required this.peso,
    this.dorsal,
    required this.promedioPuntos,
    required this.promedioRebotes,
    required this.promedioAsistencias,
    required this.promedioRobos,
  });

  String get nombreCompleto => "$nombre $apellido";

  @override
  bool operator ==(Object other) =>
      other is Jugador && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      posicion: json['posicion'] ?? '',
      altura: (json['altura'] ?? 0).toDouble(),
      peso: (json['peso'] ?? 0).toDouble(),
      dorsal: json['dorsal'],
      promedioPuntos: (json['promedioPuntos'] ?? 0).toDouble(),
      promedioRebotes: (json['promedioRebotes'] ?? 0).toDouble(),
      promedioAsistencias: (json['promedioAsistencias'] ?? 0).toDouble(),
      promedioRobos: (json['promedioRobos'] ?? 0).toDouble(),
    );
  }
}