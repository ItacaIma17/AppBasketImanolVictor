import 'package:tfg_appfede/models/role.dart';

class Usuario {
  final int? id;
  final String email;
  final String username;
  final String nombre;
  final String? apellido;
  final String? licencia;
  final int edad;
  final Role role;
  final bool verificado;
  final bool bloqueado;

  Usuario({
    this.id,
    required this.email,
    required this.username,
    required this.nombre,
    this.apellido,
    this.licencia,
    required this.edad,
    required this.role,
    this.verificado = false,
    this.bloqueado = false,
  });

  bool get isAdmin => role == Role.ADMIN;
  bool get isEntrenador => role == Role.ENTRENADOR;
  bool get isJugador => role == Role.JUGADOR;
  bool get isArbitro => role == Role.ARBITRO;

  bool get tieneLicencia => licencia != null && licencia!.isNotEmpty;

  String get nombreCompleto => '$nombre ${apellido ?? ''}'.trim();

  String get iniciales {
    String primeraLetra = nombre.isNotEmpty ? nombre[0] : '';
    String segundaLetra = apellido != null && apellido!.isNotEmpty ? apellido![0] : '';
    return '$primeraLetra$segundaLetra'.toUpperCase();
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {

    String roleStr = '';
    if (json['role'] != null && json['role'] is String) {
      roleStr = json['role'];
    } else if (json['rol'] != null && json['rol'] is String) {
      roleStr = json['rol'];
    } else {
      roleStr = 'USUARIO';
    }

    final role = Role.fromString(roleStr);

    return Usuario(
      id: json['id'],
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      licencia: json['licencia'],
      edad: json['edad'] ?? 0,
      role: role,
      verificado: json['verificado'] ?? false,
      bloqueado: json['bloqueado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'nombre': nombre,
      'apellido': apellido,
      'licencia': licencia,
      'edad': edad,
      'role': role.name,
      'verificado': verificado,
      'bloqueado': bloqueado,
    };
  }

  Usuario copyWith({
    int? id,
    String? email,
    String? username,
    String? nombre,
    String? apellido,
    String? licencia,
    int? edad,
    Role? role,
    bool? verificado,
    bool? bloqueado,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      licencia: licencia ?? this.licencia,
      edad: edad ?? this.edad,
      role: role ?? this.role,
      verificado: verificado ?? this.verificado,
      bloqueado: bloqueado ?? this.bloqueado,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Usuario{id: $id, username: $username, email: $email, nombre: $nombre, role: ${role.name}}';
  }
}
