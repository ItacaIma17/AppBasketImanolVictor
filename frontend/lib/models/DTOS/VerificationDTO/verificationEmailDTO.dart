class VerificacionEmailDTO {
  final String codigo;

  VerificacionEmailDTO({required this.codigo});

  Map<String, dynamic> toJson() {
    return {'codigo': codigo};
  }
}