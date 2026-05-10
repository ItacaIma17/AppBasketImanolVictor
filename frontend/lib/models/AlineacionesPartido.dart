import 'alineacion.dart';

class AlineacionesPartido {
  final int partidoId;
  final String equipoLocal;
  final String equipoVisitante;
  final Alineacion? alineacionLocal;
  final Alineacion? alineacionVisitante;
  final bool ambasPresentadas;
  final bool alineacionLocalConfirmada;
  final bool alineacionVisitanteConfirmada;
  final bool partidoListoParaComenzar;

  AlineacionesPartido({
    required this.partidoId,
    required this.equipoLocal,
    required this.equipoVisitante,
    this.alineacionLocal,
    this.alineacionVisitante,
    required this.ambasPresentadas,
    required this.alineacionLocalConfirmada,
    required this.alineacionVisitanteConfirmada,
    required this.partidoListoParaComenzar,
  });

  factory AlineacionesPartido.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return AlineacionesPartido(
      partidoId: _parseInt(json['partidoId']),
      equipoLocal: json['equipoLocal'] ?? '',
      equipoVisitante: json['equipoVisitante'] ?? '',
      alineacionLocal: json['alineacionLocal'] != null
          ? Alineacion.fromJson(json['alineacionLocal'])
          : null,
      alineacionVisitante: json['alineacionVisitante'] != null
          ? Alineacion.fromJson(json['alineacionVisitante'])
          : null,
      ambasPresentadas: json['ambasPresentadas'] ?? false,
      alineacionLocalConfirmada: json['alineacionLocalConfirmada'] ?? false,
      alineacionVisitanteConfirmada: json['alineacionVisitanteConfirmada'] ?? false,
      partidoListoParaComenzar: json['partidoListoParaComenzar'] ?? false,
    );
  }
}
