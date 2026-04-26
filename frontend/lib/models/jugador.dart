class Jugador {
  final int id;
  final String id_equipo;
  final String nombre;
  final String apellido;
  final String posicion;
  final double altura;
  final double peso;
  final double promedioPuntos;
  final double promedioRebotes;
  final double promedioAsistencias;
  final double promedioRobos;

  Jugador({
    required this.id,
    required this.id_equipo,
    required this.nombre,
    required this.apellido,
    required this.posicion,
    required this.altura,
    required this.peso,
    required this.promedioPuntos,
    required this.promedioRebotes,
    required this.promedioAsistencias,
    required this.promedioRobos,
  });

  String get nombreCompleto => "$nombre $apellido";

  factory Jugador.fromJson(dynamic json) {
    return Jugador(
      id: json['id'] ?? 0,
      id_equipo: (json['id_equipo'] ?? json['equipoId']).toString(),
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      posicion: json['posicion'] ?? '',
      altura: (json['altura'] ?? 0).toDouble(),
      peso: (json['peso'] ?? 0).toDouble(),
      promedioPuntos: (json['promedioPuntos'] ?? json['puntos'] ?? 0).toDouble(),
      promedioRebotes: (json['promedioRebotes'] ?? json['rebotes'] ?? 0).toDouble(),
      promedioAsistencias: (json['promedioAsistencias'] ?? json['asistencias'] ?? 0).toDouble(),
      promedioRobos: (json['promedioRobos'] ?? json['robos'] ?? 0).toDouble(),
    );
  }
}
