// lib/models/arbitro.dart
import 'package:tfg_appfede/models/partidoAsignado.dart';
import 'package:tfg_appfede/models/role.dart';

class Arbitro {
  final int? id;
  final String username;
  final String email;
  final String? nombre;
  final String? apellidos;
  final int? edad;
  final String? codigoArbitro;
  final bool verificado;
  final String? telefono;

  // Campos adicionales para el frontend
  final bool tienePartidos;
  final int? partidosAsignados;
  final List<PartidoAsignado>? proximosPartidos;

  Arbitro({
    this.id,
    required this.username,
    required this.email,
    this.nombre,
    this.apellidos,
    this.edad,
    this.codigoArbitro,
    this.verificado = false,
    this.telefono,
    this.tienePartidos = false,
    this.partidosAsignados,
    this.proximosPartidos,
  });

  // ============================================================
  // GETTERS
  // ============================================================

  String get nombreCompleto {
    if (nombre != null && apellidos != null) {
      return '$nombre $apellidos';
    } else if (nombre != null) {
      return nombre!;
    } else if (apellidos != null) {
      return apellidos!;
    }
    return username;
  }

  String get iniciales {
    String primera = nombre != null && nombre!.isNotEmpty ? nombre![0] : '';
    String segunda = apellidos != null && apellidos!.isNotEmpty ? apellidos![0] : '';
    if (primera.isEmpty && segunda.isEmpty) {
      return username.isNotEmpty ? username[0].toUpperCase() : 'A';
    }
    return '$primera$segunda'.toUpperCase();
  }

  bool get tieneCodigo => codigoArbitro != null && codigoArbitro!.isNotEmpty;

  // ============================================================
  // FROM JSON
  // ============================================================

  factory Arbitro.fromJson(Map<String, dynamic> json) {
    return Arbitro(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'],
      apellidos: json['apellidos'] ?? json['apellido'],
      edad: json['edad'],
      codigoArbitro: json['codigoArbitro'] ?? json['codigo_arbitro'],
      verificado: json['verificado'] ?? false,
      telefono: json['telefono']?.toString(),
      tienePartidos: json['partidosAsignados'] != null && json['partidosAsignados'] > 0,
      partidosAsignados: json['partidosAsignados'],
      proximosPartidos: json['proximosPartidos'] != null
          ? (json['proximosPartidos'] as List)
          .map((p) => PartidoAsignado.fromJson(p))
          .toList()
          : [],
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nombre': nombre,
      'apellidos': apellidos,
      'edad': edad,
      'codigoArbitro': codigoArbitro,
      'verificado': verificado,
      'telefono': telefono,
      'partidosAsignados': partidosAsignados,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  Arbitro copyWith({
    int? id,
    String? username,
    String? email,
    String? nombre,
    String? apellidos,
    int? edad,
    String? codigoArbitro,
    bool? verificado,
    String? telefono,
    bool? tienePartidos,
    int? partidosAsignados,
    List<PartidoAsignado>? proximosPartidos,
  }) {
    return Arbitro(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      edad: edad ?? this.edad,
      codigoArbitro: codigoArbitro ?? this.codigoArbitro,
      verificado: verificado ?? this.verificado,
      telefono: telefono ?? this.telefono,
      tienePartidos: tienePartidos ?? this.tienePartidos,
      partidosAsignados: partidosAsignados ?? this.partidosAsignados,
      proximosPartidos: proximosPartidos ?? this.proximosPartidos,
    );
  }

  // ============================================================
  // EQUALS y HASHCODE
  // ============================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Arbitro && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Arbitro{id: $id, username: $username, email: $email, nombre: $nombre, codigoArbitro: $codigoArbitro}';
  }
}


