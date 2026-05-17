class LineaPedido {
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const LineaPedido({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory LineaPedido.fromJson(Map<String, dynamic> json) {
    return LineaPedido(
      productoId: json['productoId'] as int,
      nombreProducto: json['nombreProducto'] as String? ?? '',
      cantidad: json['cantidad'] as int? ?? 0,
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PagoResumen {
  final String transaccionId;
  final String estado;
  final String ultimosCuatroDigitos;
  final DateTime fechaPago;

  const PagoResumen({
    required this.transaccionId,
    required this.estado,
    required this.ultimosCuatroDigitos,
    required this.fechaPago,
  });

  factory PagoResumen.fromJson(Map<String, dynamic> json) {
    return PagoResumen(
      transaccionId: json['transaccionId'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      ultimosCuatroDigitos: json['ultimosCuatroDigitos'] as String? ?? '????',
      fechaPago: DateTime.parse(json['fechaPago'] as String),
    );
  }
}

class Pedido {
  final int id;
  final String estado;
  final double total;
  final DateTime fechaPedido;
  final List<LineaPedido> lineas;
  final PagoResumen? pago;

  const Pedido({
    required this.id,
    required this.estado,
    required this.total,
    required this.fechaPedido,
    required this.lineas,
    this.pago,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] as int,
      estado: json['estado'] as String? ?? 'PENDIENTE',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      fechaPedido: DateTime.parse(json['fechaPedido'] as String),
      lineas: (json['lineas'] as List<dynamic>?)
              ?.map((l) => LineaPedido.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      pago: json['pago'] != null
          ? PagoResumen.fromJson(json['pago'] as Map<String, dynamic>)
          : null,
    );
  }
}