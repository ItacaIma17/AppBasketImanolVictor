class JugadorAlineacion {
  // ✅ FIX: el backend (JugadorAlineacionRequestDTO) NO envía `id` ni
  // `nombreCompleto`, así que estos campos se vuelven opcionales y
  // `nombreCompleto` se calcula a partir de `nombre + apellido`.
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
      // El backend serializa nombre/apellido por separado.
      // Aceptamos también `nombreJugador` por compatibilidad con
      // /alineaciones/partido/{id}/equipo/{equipoId}.
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