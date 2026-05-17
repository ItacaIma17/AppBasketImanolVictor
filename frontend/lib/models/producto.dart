class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final int stock;
  final double precio;
  final String categoria;
  final String? imagenUrl;
  final bool activo;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.stock,
    required this.precio,
    required this.categoria,
    this.imagenUrl,
    required this.activo,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['idProducto'] as int,
      nombre: json['nombreProducto'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      categoria: json['categoria'] as String? ?? '',
      imagenUrl: json['imagenUrl'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }
}