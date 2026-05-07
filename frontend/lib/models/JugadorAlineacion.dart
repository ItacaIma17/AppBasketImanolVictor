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
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return JugadorAlineacion(
      id: _parseInt(json['id']),
      jugadorId: _parseInt(json['jugadorId']),
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      dorsal: _parseInt(json['dorsal']),
      posicion: json['posicion'] ?? '',
      titular: json['titular'] ?? false,
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