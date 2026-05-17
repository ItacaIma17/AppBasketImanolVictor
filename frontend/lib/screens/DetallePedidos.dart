import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/pedido.dart';
import 'package:tfg_appfede/services/tiendaService.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';

class DetallePedidosPage extends StatefulWidget {
  const DetallePedidosPage({super.key});

  @override
  State<DetallePedidosPage> createState() => _DetallePedidosPageState();
}

class _DetallePedidosPageState extends State<DetallePedidosPage> {
  List<Pedido> _pedidos = [];
  bool _isLoading = true;
  String? _error;

  final _dateFormat = DateFormat('dd/MM/yyyy · HH:mm', 'es_ES');

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final lista = await TiendaService.misPedidos();
      setState(() {
        _pedidos = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: 'Mis Pedidos'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
              : _error != null
                  ? _buildError()
                  : _pedidos.isEmpty
                      ? _buildVacio()
                      : _buildLista(),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.rojoAragon, size: 52),
          const SizedBox(height: 12),
          const Text('Error al cargar pedidos',
              style: TextStyle(color: AppColors.blanco, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            onPressed: _cargarPedidos,
            child: const Text('Reintentar', style: TextStyle(color: AppColors.blanco)),
          ),
        ],
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 90, color: AppColors.blancoOpacidad70),
          const SizedBox(height: 20),
          const Text('No tienes pedidos aún',
              style:
                  TextStyle(color: AppColors.blanco, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tus compras aparecerán aquí',
              style: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return RefreshIndicator(
      onRefresh: _cargarPedidos,
      color: AppColors.naranja,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pedidos.length,
        itemBuilder: (_, i) => _buildPedidoCard(_pedidos[i]),
      ),
    );
  }

  Widget _buildPedidoCard(Pedido pedido) {
    final color = _colorEstado(pedido.estado);
    final icon = _iconoEstado(pedido.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pedido #${pedido.id}',
                          style: const TextStyle(
                              color: AppColors.blanco,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      Text(_dateFormat.format(pedido.fechaPedido),
                          style: TextStyle(
                              color: AppColors.grisClaro.withOpacity(0.6), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(pedido.estado,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Líneas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...pedido.lineas.map((linea) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                  color: AppColors.naranja, shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(linea.nombreProducto,
                                style:
                                    const TextStyle(color: AppColors.blanco, fontSize: 13)),
                          ),
                          Text('×${linea.cantidad}',
                              style: TextStyle(
                                  color: AppColors.grisClaro.withOpacity(0.7), fontSize: 12)),
                          const SizedBox(width: 10),
                          Text('${linea.subtotal.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                  color: AppColors.naranja,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),

                const Divider(color: Color(0xFF3A3A3A), height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            color: AppColors.blanco,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text('${pedido.total.toStringAsFixed(2)} €',
                        style: const TextStyle(
                            color: AppColors.naranja,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),

                if (pedido.pago != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card, color: Colors.green, size: 15),
                        const SizedBox(width: 8),
                        Text('**** ${pedido.pago!.ultimosCuatroDigitos}',
                            style: const TextStyle(color: Colors.green, fontSize: 13)),
                        const Spacer(),
                        Text(
                          'ID: ${pedido.pago!.transaccionId.length >= 8 ? pedido.pago!.transaccionId.substring(0, 8) : pedido.pago!.transaccionId}...',
                          style: TextStyle(
                              color: AppColors.grisClaro.withOpacity(0.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],

                if (pedido.estado == 'PENDIENTE') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.rojoAragon),
                        shape:
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.cancel_outlined,
                          color: AppColors.rojoAragon, size: 18),
                      label: const Text('Cancelar pedido',
                          style: TextStyle(color: AppColors.rojoAragon)),
                      onPressed: () => _cancelarPedido(pedido),
                    ),
                  ),
                ],

                _buildTrackingBar(pedido.estado),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingBar(String estado) {
    final pasos = ['PENDIENTE', 'PAGADO', 'ENVIADO', 'ENTREGADO'];
    final indexActual = pasos.indexOf(estado);

    if (estado == 'CANCELADO') {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            const Icon(Icons.cancel, color: AppColors.rojoAragon, size: 16),
            const SizedBox(width: 6),
            Text('Pedido cancelado',
                style: TextStyle(color: AppColors.rojoAragon.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: pasos.asMap().entries.map((entry) {
          final i = entry.key;
          final label = _labelPaso(entry.value);
          final completado = indexActual >= i;
          final esActual = indexActual == i;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: completado ? AppColors.naranja : const Color(0xFF3A3A3A),
                        ),
                      ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: completado ? AppColors.naranja : const Color(0xFF3A3A3A),
                        shape: BoxShape.circle,
                        border: esActual
                            ? Border.all(color: AppColors.amarilloAragon, width: 2)
                            : null,
                      ),
                      child: completado
                          ? const Icon(Icons.check, color: AppColors.blanco, size: 10)
                          : null,
                    ),
                    if (i < pasos.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: indexActual > i ? AppColors.naranja : const Color(0xFF3A3A3A),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: completado ? AppColors.naranja : AppColors.grisClaro.withOpacity(0.4),
                    fontSize: 9,
                    fontWeight: esActual ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _cancelarPedido(Pedido pedido) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar pedido', style: TextStyle(color: AppColors.blanco)),
        content: Text('¿Seguro que quieres cancelar el pedido #${pedido.id}?',
            style: TextStyle(color: AppColors.blancoOpacidad70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('No', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojoAragon),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Sí, cancelar', style: TextStyle(color: AppColors.blanco)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await TiendaService.cancelarPedido(pedido.id);
      _cargarPedidos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppColors.rojoAragon,
      ));
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return AppColors.naranja;
      case 'PAGADO':
        return Colors.green;
      case 'ENVIADO':
        return Colors.blue;
      case 'ENTREGADO':
        return Colors.teal;
      case 'CANCELADO':
        return AppColors.rojoAragon;
      default:
        return AppColors.grisClaro;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Icons.hourglass_empty;
      case 'PAGADO':
        return Icons.check_circle_outline;
      case 'ENVIADO':
        return Icons.local_shipping;
      case 'ENTREGADO':
        return Icons.home;
      case 'CANCELADO':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt;
    }
  }

  String _labelPaso(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'PAGADO':
        return 'Pagado';
      case 'ENVIADO':
        return 'Enviado';
      case 'ENTREGADO':
        return 'Entregado';
      default:
        return estado;
    }
  }
}