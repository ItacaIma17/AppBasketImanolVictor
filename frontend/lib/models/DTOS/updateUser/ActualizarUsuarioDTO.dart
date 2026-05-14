class ActualizarUsuarioDTO {
  final String? username;
  final String? nombre;
  final String? apellido;
  final int? edad;
  final String? oldPassword;
  final String? newPassword;

  ActualizarUsuarioDTO({
    this.username,
    this.nombre,
    this.apellido,
    this.edad,
    this.oldPassword,
    this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}