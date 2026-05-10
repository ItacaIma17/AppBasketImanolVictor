class cambiarContrasenaDTO {
  final String email;
  final String password;
  final String newPassword;

  cambiarContrasenaDTO({
    required this.email,
    required this.password,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'newPassword': newPassword,
    };
  }
}

