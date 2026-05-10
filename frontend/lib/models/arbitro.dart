import 'package:tfg_appfede/models/partidoAsignado.dart';

class Arbitro {
  final int? id;
  final String username;
  final String email;
  final String? nombre;
  final String? apellido;
  final int? edad;
  final String? codigoArbitro;
  final bool verificado;
  final String? telefono;
  final bool activo;

  final bool tienePartidos;
  final int? partidosAsignados;
  final List<PartidoAsignado>? proximosPartidos;

  Arbitro({
    this.id,
    required this.username,
    required this.email,
    this.nombre,
    this.apellido,
    this.edad,
    this.codigoArbitro,
    this.verificado = false,
    this.telefono,
    this.activo = true,
    this.tienePartidos = false,
    this.partidosAsignados,
    this.proximosPartidos,
  });

  String get nombreCompleto {
    if (nombre != null && apellido != null) {
      return '$nombre $apellido';
    } else if (nombre != null) {
      return nombre!;
    } else if (apellido != null) {
      return apellido!;
    }
    return username;
  }

  String get iniciales {
    String primera = nombre != null && nombre!.isNotEmpty ? nombre![0] : '';
    String segunda = apellido != null && apellido!.isNotEmpty ? apellido![0] : '';
    if (primera.isEmpty && segunda.isEmpty) {
      return username.isNotEmpty ? username[0].toUpperCase() : 'A';
    }
    return '$primera$segunda'.toUpperCase();
  }

  bool get tieneCodigo => codigoArbitro != null && codigoArbitro!.isNotEmpty;
  bool get isActivo => activo;
  bool get isInactivo => !activo;

  factory Arbitro.fromJson(Map<String, dynamic> json) {
    return Arbitro(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'],
      apellido: json['apellido'] ?? json['apellidos'],
      edad: json['edad'],
      codigoArbitro: json['codigoArbitro'] ?? json['codigo_arbitro'],
      verificado: json['verificado'] ?? false,
      telefono: json['telefono']?.toString(),
      activo: json['activo'] ?? json['enabled'] ?? true,
      tienePartidos: json['partidosAsignados'] != null && json['partidosAsignados'] > 0,
      partidosAsignados: json['partidosAsignados'],
      proximosPartidos: json['proximosPartidos'] != null
          ? (json['proximosPartidos'] as List)
          .map((p) => PartidoAsignado.fromJson(p))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'codigoArbitro': codigoArbitro,
      'verificado': verificado,
      'telefono': telefono,
      'activo': activo,
      'partidosAsignados': partidosAsignados,
    };
  }

  Arbitro copyWith({
    int? id,
    String? username,
    String? email,
    String? nombre,
    String? apellido,
    int? edad,
    String? codigoArbitro,
    bool? verificado,
    String? telefono,
    bool? activo,
    bool? tienePartidos,
    int? partidosAsignados,
    List<PartidoAsignado>? proximosPartidos,
  }) {
    return Arbitro(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      edad: edad ?? this.edad,
      codigoArbitro: codigoArbitro ?? this.codigoArbitro,
      verificado: verificado ?? this.verificado,
      telefono: telefono ?? this.telefono,
      activo: activo ?? this.activo,
      tienePartidos: tienePartidos ?? this.tienePartidos,
      partidosAsignados: partidosAsignados ?? this.partidosAsignados,
      proximosPartidos: proximosPartidos ?? this.proximosPartidos,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Arbitro && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Arbitro{id: $id, username: $username, email: $email, nombre: $nombre, apellido: $apellido, activo: $activo}';
  }
}
