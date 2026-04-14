// lib/models/role.dart
import 'dart:ui';

import 'package:flutter/material.dart';

enum Role {
  USUARIO,
  ENTRENADOR,
  ARBITRO,
  JUGADOR,
  ADMIN;

  String get value => name;

  static Role fromString(String value) {
    switch (value.toUpperCase()) {
      case 'USUARIO':
        return Role.USUARIO;
      case 'ENTRENADOR':
        return Role.ENTRENADOR;
      case 'ARBITRO':
        return Role.ARBITRO;
      case 'JUGADOR':
        return Role.JUGADOR;
      case 'ADMIN':
        return Role.ADMIN;
      default:
        ///Usar el usuario por defecto como rol
        print('Rol desconocido: $value, usando USUARIO por defecto');
        return Role.USUARIO;
    }
  }

  /// Obtener nombre en español para mostrar en UI
  String get displayName {
    switch (this) {
      case Role.USUARIO:
        return 'Aficionado';
      case Role.ENTRENADOR:
        return 'Entrenador';
      case Role.ARBITRO:
        return 'Árbitro';
      case Role.JUGADOR:
        return 'Jugador';
      case Role.ADMIN:
        return 'Administrador';
    }
  }

  String get toLowerCase => name.toLowerCase();


  /// Obtener icono según el rol
  IconData get icon {
    switch (this) {
      case Role.USUARIO:
        return Icons.favorite;
      case Role.ENTRENADOR:
        return Icons.sports;
      case Role.ARBITRO:
        return Icons.sports_score;
      case Role.JUGADOR:
        return Icons.sports_basketball;
      case Role.ADMIN:
        return Icons.admin_panel_settings;
    }
  }

  /// Obtener color según el rol
  Color get color {
    switch (this) {
      case Role.USUARIO:
        return Colors.blue;
      case Role.ENTRENADOR:
        return Colors.green;
      case Role.ARBITRO:
        return Colors.orange;
      case Role.JUGADOR:
        return Colors.purple;
      case Role.ADMIN:
        return Colors.red;
    }
  }
}