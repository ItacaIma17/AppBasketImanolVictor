class JugadorAlineacion {

  final int? id;
  final int jugadorId;
  final String nombre;
  final String? apellido;
  final int dorsal;
  final String posicion;
  final bool titular;

  JugadorAlineacion({
    this.id,
    required this.jugadorId,
    required this.nombre,
    this.apellido,
    required this.dorsal,
    required this.posicion,
    required this.titular,
  });

  String get nombreCompleto {
    final ap = (apellido ?? '').trim();
    if (ap.isEmpty) return nombre;
    return '$nombre $ap';
  }

  static int _toInt(dynamic v, {int defaultValue = 0}) {
    if (v == null) return defaultValue;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory JugadorAlineacion.fromJson(Map<String, dynamic> json) {
    return JugadorAlineacion(
      id: _toIntOrNull(json['id']),
      jugadorId: _toInt(json['jugadorId']),

      nombre: (json['nombre'] ?? json['nombreJugador'] ?? '').toString(),
      apellido: json['apellido']?.toString(),
      dorsal: _toInt(json['dorsal']),
      posicion: (json['posicion'] ?? '').toString(),
      titular: json['titular'] ?? json['esTitular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jugadorId': jugadorId,
      'nombre': nombre,
      'apellido': apellido,
      'dorsal': dorsal,
      'posicion': posicion,
      'titular': titular,
    };
  }
}
