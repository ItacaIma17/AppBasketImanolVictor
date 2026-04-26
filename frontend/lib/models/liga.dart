class Liga {
  final String categoria;

  Liga({
    required this.categoria,
  });

  String get nombre => "$categoria";

  @override
  bool operator ==(Object other) =>
      other is Liga && other.nombre == nombre;

  @override
  int get hashCode => nombre.hashCode;
}
