class JugadorAlineacion {
  final int id;
  final int jugadorId;
  final String nombre;
  final String apellido;
  final String nombreCompleto;
  final int dorsal;
  final String posicion;
  final bool titular;

  JugadorAlineacion({
    required this.id,
    required this.jugadorId,
    required this.nombre,
    required this.apellido,
    required this.nombreCompleto,
    required this.dorsal,
    required this.posicion,
    required this.titular,
  });

  factory JugadorAlineacion.fromJson(Map<String, dynamic> json) {
    return JugadorAlineacion(
      id: json['id'],
      jugadorId: json['jugadorId'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      nombreCompleto: json['nombreCompleto'],
      dorsal: json['dorsal'],
      posicion: json['posicion'],
      titular: json['titular'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jugadorId': jugadorId,
      'dorsal': dorsal,
      'posicion': posicion,
      'titular': titular,
    };
  }
}