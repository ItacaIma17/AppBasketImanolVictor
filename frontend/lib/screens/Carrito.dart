import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/producto.dart';
import 'package:tfg_appfede/services/tiendaService.dart';

class CarritoPage extends StatefulWidget {
  final Map<int, int> carrito;
  final List<Producto> productos;
  final Function(Map<int, int>) onCarritoActualizado;

  const CarritoPage({
    super.key,
    required this.carrito,
    required this.productos,
    required this.onCarritoActualizado,
  });

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  late Map<int, int> _carritoLocal;
  bool _procesandoPago = false;

  final _tarjetaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _mesCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carritoLocal = Map.from(widget.carrito);
  }

  @override
  void dispose() {
    _tarjetaCtrl.dispose();
    _nombreCtrl.dispose();
    _cvvCtrl.dispose();
    _mesCtrl.dispose();
    _anioCtrl.dispose();
    super.dispose();
  }

  List<int> get _idsValidos =>
      _carritoLocal.keys.where((id) => widget.productos.any((p) => p.id == id)).toList();

  @override
  Widget build(BuildContext context) {
    final idsValidos = _idsValidos;
    final double total = _calcularTotal(idsValidos);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: idsValidos.isEmpty
                    ? _buildEstadoVacio()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: idsValidos.length,
                        itemBuilder: (_, i) {
                          final id = idsValidos[i];
                          final producto = widget.productos.firstWhere((p) => p.id == id);
                          return _buildProductoEnCarrito(producto, _carritoLocal[id]!);
                        },
                      ),
              ),
              if (idsValidos.isNotEmpty) _buildFooter(total),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.negro,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
            onPressed: () {
              widget.onCarritoActualizado(_carritoLocal);
              Navigator.pop(context);
            },
          ),
          const Text('MI CARRITO',
              style: TextStyle(
                  color: AppColors.blanco, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 100, color: AppColors.blancoOpacidad70),
          const SizedBox(height: 16),
          const Text('Tu carrito está vacío',
              style:
                  TextStyle(color: AppColors.blanco, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Añade productos desde la tienda',
              style: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            onPressed: () {
              widget.onCarritoActualizado(_carritoLocal);
              Navigator.pop(context);
            },
            child: const Text('Ir a la tienda', style: TextStyle(color: AppColors.blanco)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoEnCarrito(Producto producto, int cantidad) {
    final subtotal = producto.precio * cantidad;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                gradient: AppColors.gradienteNaranjaAmarillo,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.shopping_bag, color: AppColors.blanco, size: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${producto.precio.toStringAsFixed(2)} € × $cantidad',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text('${subtotal.toStringAsFixed(2)} €',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.naranja)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () => setState(() => _carritoLocal.remove(producto.id)),
              ),
              Container(
                decoration:
                    BoxDecoration(color: AppColors.grisClaro, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 15),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      onPressed: () {
                        setState(() {
                          if (cantidad > 1) {
                            _carritoLocal[producto.id] = cantidad - 1;
                          }
                        });
                      },
                    ),
                    Text('$cantidad', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 15),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      onPressed: () =>
                          setState(() => _carritoLocal[producto.id] = cantidad + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.naranja)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _procesandoPago ? null : _iniciarPago,
              child: _procesandoPago
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: AppColors.blanco, strokeWidth: 2))
                  : const Text('PROCEDER AL PAGO',
                      style: TextStyle(
                          color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarPago() async {
    if (!mounted) return;
    setState(() => _procesandoPago = true);

    final items = _carritoLocal.entries
        .map((e) => {'productoId': e.key, 'cantidad': e.value})
        .toList();

    int pedidoId;
    try {
      final pedido = await TiendaService.crearPedido(items);
      pedidoId = pedido.id;
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesandoPago = false);
      _mostrarError(e.toString().replaceAll('Exception: ', ''));
      return;
    }

    if (!mounted) return;
    setState(() => _procesandoPago = false);

    _tarjetaCtrl.clear();
    _nombreCtrl.clear();
    _cvvCtrl.clear();
    _mesCtrl.clear();
    _anioCtrl.clear();

    final paymentResult = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildDialogPago(pedidoId),
    );

    if (paymentResult == null) return;

    final aprobado = paymentResult['aprobado'] as bool? ?? false;
    final mensaje = paymentResult['mensaje'] as String? ?? '';

    if (aprobado) {
      setState(() => _carritoLocal.clear());
      widget.onCarritoActualizado({});
    }

    if (!mounted) return;
    _mostrarResultadoPago(aprobado, mensaje);
  }

  Widget _buildDialogPago(int pedidoId) {
    final formKey = GlobalKey<FormState>();
    bool procesando = false;

    return StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  gradient: AppColors.gradienteNaranjaAmarillo,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.credit_card, color: AppColors.blanco, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('FAB Pay',
                style: TextStyle(
                    color: AppColors.blanco, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tarjetaCtrl,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: _inputDeco('Número de tarjeta (16 dígitos)', Icons.credit_card),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (v) =>
                      (v == null || !RegExp(r'^\d{16}$').hasMatch(v)) ? 'Debe tener 16 dígitos' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nombreCtrl,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: _inputDeco('Nombre del titular', Icons.person),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mesCtrl,
                        style: const TextStyle(color: AppColors.blanco),
                        decoration: _inputDeco('Mes (MM)', Icons.calendar_today),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        validator: (v) {
                          final m = int.tryParse(v ?? '');
                          return (m == null || m < 1 || m > 12) ? 'MM inválido' : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _anioCtrl,
                        style: const TextStyle(color: AppColors.blanco),
                        decoration: _inputDeco('Año (AAAA)', Icons.calendar_month),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        validator: (v) {
                          final a = int.tryParse(v ?? '');
                          return (a == null || a < DateTime.now().year) ? 'Año inválido' : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cvvCtrl,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: _inputDeco('CVV (3 dígitos)', Icons.lock),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  validator: (v) =>
                      (v == null || !RegExp(r'^\d{3}$').hasMatch(v)) ? '3 dígitos' : null,
                ),
                if (procesando) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: AppColors.naranja),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: procesando ? null : () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            onPressed: procesando
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => procesando = true);
                    try {
                      final result = await TiendaService.procesarPago({
                        'pedidoId': pedidoId,
                        'numeroTarjeta': _tarjetaCtrl.text.trim(),
                        'nombreTitular': _nombreCtrl.text.trim(),
                        'mesExpiracion': int.parse(_mesCtrl.text.trim()),
                        'anioExpiracion': int.parse(_anioCtrl.text.trim()),
                        'cvv': _cvvCtrl.text.trim(),
                      });
                      Navigator.pop(ctx, {
                        'aprobado': result['estado'] == 'APROBADO',
                        'mensaje': result['mensaje'] ?? '',
                      });
                    } catch (e) {
                      setDialogState(() => procesando = false);
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: AppColors.rojoAragon,
                      ));
                    }
                  },
            child: const Text('Pagar',
                style: TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.naranja, size: 18),
      enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.naranja),
          borderRadius: BorderRadius.circular(8)),
      errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.rojoAragon),
          borderRadius: BorderRadius.circular(8)),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.rojoAragon),
          borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      counterStyle: const TextStyle(color: Colors.grey, fontSize: 11),
    );
  }

  void _mostrarResultadoPago(bool aprobado, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              aprobado ? Icons.check_circle : Icons.cancel,
              color: aprobado ? Colors.green : AppColors.rojoAragon,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              aprobado ? '¡Pago realizado!' : 'Pago rechazado',
              style: const TextStyle(
                  color: AppColors.blanco, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              aprobado
                  ? 'Tu pedido está siendo procesado.\nRecibirás un email de confirmación.'
                  : msg,
              style: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: aprobado ? Colors.green : AppColors.naranja,
              minimumSize: const Size(double.infinity, 44),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              if (aprobado) Navigator.pop(context);
            },
            child: Text(
              aprobado ? 'Aceptar' : 'Entendido',
              style: const TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.rojoAragon,
      duration: const Duration(seconds: 4),
    ));
  }

  double _calcularTotal(List<int> ids) {
    double total = 0;
    for (final id in ids) {
      final producto = widget.productos.firstWhere((p) => p.id == id);
      total += producto.precio * _carritoLocal[id]!;
    }
    return total;
  }
}