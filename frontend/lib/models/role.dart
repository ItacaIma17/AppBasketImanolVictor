enum Role {
  USUARIO,
  ENTRENADOR,
  JUGADOR,
  ARBITRO,
  AFICIONADO,
  ADMIN;

  static Role fromString(String value) {
    switch (value.toUpperCase()) {
      case 'USUARIO':
        return Role.USUARIO;
      case 'ENTRENADOR':
        return Role.ENTRENADOR;
      case 'JUGADOR':
        return Role.JUGADOR;
      case 'ARBITRO':
        return Role.ARBITRO;
      case 'ADMIN':
        return Role.ADMIN;
      default:
        return Role.USUARIO;
    }
  }

  String get value {
    switch (this) {
      case Role.USUARIO:
        return 'USUARIO';
      case Role.ENTRENADOR:
        return 'ENTRENADOR';
      case Role.JUGADOR:
        return 'JUGADOR';
      case Role.ARBITRO:
        return 'ARBITRO';
      case Role.AFICIONADO:
        return 'AFICIONADO';
      case Role.ADMIN:
        return 'ADMIN';
    }
  }

  String get displayName {
    switch (this) {
      case Role.USUARIO:
        return 'Aficionado';
      case Role.ENTRENADOR:
        return 'Entrenador';
      case Role.JUGADOR:
        return 'Jugador';
      case Role.ARBITRO:
        return 'Árbitro';
      case Role.AFICIONADO:
        return 'AFICIONADO';
      case Role.ADMIN:
        return 'Administrador';
    }
  }
}
