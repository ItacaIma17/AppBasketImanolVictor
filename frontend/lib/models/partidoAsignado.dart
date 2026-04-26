class PartidoAsignado {
  final int partidoId;
  final String equipoLocal;
  final String equipoVisitante;
  final String fecha;
  final String? ubicacion;

  PartidoAsignado({
    required this.partidoId,
    required this.equipoLocal,
    required this.equipoVisitante,
    required this.fecha,
    this.ubicacion,
  });

  factory PartidoAsignado.fromJson(Map<String, dynamic> json) {
    return PartidoAsignado(
      partidoId: json['partidoId'] ?? json['id'],
      equipoLocal: json['equipoLocal'] ?? '',
      equipoVisitante: json['equipoVisitante'] ?? '',
      fecha: json['fecha'] ?? '',
      ubicacion: json['ubicacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partidoId': partidoId,
      'equipoLocal': equipoLocal,
      'equipoVisitante': equipoVisitante,
      'fecha': fecha,
      'ubicacion': ubicacion,
    };
  }

  String get enfrentamiento => '$equipoLocal vs $equipoVisitante';

  @override
  String toString() {
    return 'PartidoAsignado{partidoId: $partidoId, enfrentamiento: $enfrentamiento, fecha: $fecha}';
  }
}