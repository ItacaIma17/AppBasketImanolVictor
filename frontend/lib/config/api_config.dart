class ApiConfig {
  // URL base del backend
  static const String baseUrl = 'http://localhost:8080/api';

  // Endpoints de usuarios
  static const String registroEndpoint = '$baseUrl/usuarios/registro';
  static const String loginEndpoint = '$baseUrl/usuarios/verificar';
  static const String perfilEndpoint = '$baseUrl/usuarios/perfil';
}
