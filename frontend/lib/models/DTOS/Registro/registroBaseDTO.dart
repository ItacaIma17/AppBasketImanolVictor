// lib/models/DTOS/Registro/registroBaseDTO.dart

import '../../role.dart';

class RegistroBaseDTO {
  String email;
  String username;
  String nombre;
  String apellido;
  int edad;
  String password;
  Role? rol;

  RegistroBaseDTO({
    required this.email,
    required this.username,
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.password,
    this.rol,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'password': password,
      'rol': rol?.value ?? 'USUARIO',
    };
  }
}