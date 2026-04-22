// lib/config/app_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Para web - usa localhost o la IP
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      // Para emulador Android
      return 'http://10.0.2.2:8080';
    } else {
      // Para dispositivo físico - usa tu IP real
      return 'http://192.168.1.145:8080';
    }
  }

  static String get apiUrl => '$baseUrl/api';

  static String get registro => '$apiUrl/usuarios/registro';
  static String get login => '$apiUrl/usuarios/login';
  static String get verificar => '$apiUrl/usuarios/verificar';
  static String get reenviarCodigo => '$apiUrl/usuarios/reenviar-codigo';
  static String get refreshToken => '$apiUrl/usuarios/refresh-token';
  static String get logout => '$apiUrl/usuarios/logout';
  static String get cambiarPassword => '$apiUrl/usuarios/cambiar-password';

  static String perfil(String username) => '$apiUrl/usuarios/perfil/$username';
  static String seguirJugador(int id) => '$apiUrl/usuarios/seguirJugador/$id';
  static String seguirEquipo(int id) => '$apiUrl/usuarios/seguirEquipo/$id';
  static String actualizarPerfil(String username, String oldPassword,
      String newPassword) => '$apiUrl/usuarios/actualizar';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}