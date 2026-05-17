import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/producto.dart';
import 'package:tfg_appfede/screens/Carrito.dart';
import 'package:tfg_appfede/screens/DetallePedidos.dart';
import 'package:tfg_appfede/services/tiendaService.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';

class TiendaPage extends StatefulWidget {
  const TiendaPage({super.key});

  @override
  State<TiendaPage> createState() => _TiendaPageState();
}

class _TiendaPageState extends State<TiendaPage> {
  final List<String> _categorias = ['Todo', 'Camisetas', 'Balones', 'Accesorios', 'Equipamiento'];
  String _categoriaSeleccionada = 'Todo';
  List<Producto> _productos = [];
  final Map<int, int> _carrito = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final lista = await TiendaService.listarProductos();
      setState(() {
        _productos = lista.where((p) => p.activo).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Producto> get _productosFiltrados {
    if (_categoriaSeleccionada == 'Todo') return _productos;
    return _productos
        .where((p) => p.categoria.toLowerCase() == _categoriaSeleccionada.toLowerCase())
        .toList();
  }

  void _addToCarrito(Producto p) {
    setState(() {
      _carrito[p.id] = (_carrito[p.id] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${p.nombre} añadido al carrito'),
      duration: const Duration(seconds: 1),
      backgroundColor: AppColors.naranja,
    ));
  }

  void _abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarritoPage(
          carrito: Map.from(_carrito),
          productos: _productos,
          onCarritoActualizado: (nuevo) {
            setState(() {
              _carrito.clear();
              _carrito.addAll(nuevo);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int cantidadTotal = _carrito.values.fold(0, (s, c) => s + c);

    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: 'Tienda'),
      bottomNavigationBar: const BarraInferior(selectedIndex: 1),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(cantidadTotal),
              _buildCategorias(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int cantidadTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DetallePedidosPage()),
            ),
            icon: const Icon(Icons.receipt_long, color: AppColors.blanco, size: 20),
            label: const Text('Mis pedidos', style: TextStyle(color: AppColors.blanco, fontSize: 13)),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: AppColors.blanco),
                iconSize: 28,
                onPressed: _abrirCarrito,
              ),
              if (cantidadTotal > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: AppColors.rojoAragon, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '$cantidadTotal',
                      style: const TextStyle(
                          color: AppColors.blanco,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorias() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categorias.length,
        itemBuilder: (_, i) {
          final cat = _categorias[i];
          final isSelected = cat == _categoriaSeleccionada;
          return GestureDetector(
            onTap: () => setState(() => _categoriaSeleccionada = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.gradienteNaranjaAmarillo : null,
                color: isSelected ? null : AppColors.blanco.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.blanco.withOpacity(0.3),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: AppColors.blanco,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.naranja));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.rojoAragon, size: 48),
            const SizedBox(height: 12),
            const Text('Error al cargar productos',
                style: TextStyle(color: AppColors.blanco, fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: _cargarProductos,
              child: const Text('Reintentar', style: TextStyle(color: AppColors.blanco)),
            ),
          ],
        ),
      );
    }
    final filtrados = _productosFiltrados;
    if (filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.blancoOpacidad70),
            const SizedBox(height: 16),
            Text(
              _productos.isEmpty
                  ? 'No hay productos disponibles'
                  : 'Sin productos en esta categoría',
              style: const TextStyle(color: AppColors.blanco, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: filtrados.length,
      itemBuilder: (_, i) => _buildProductoCard(filtrados[i]),
    );
  }

  Widget _buildProductoCard(Producto producto) {
    final enCarrito = _carrito[producto.id] ?? 0;
    final sinStock = producto.stock <= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteNaranjaAmarillo,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Center(
                    child: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: Image.network(
                              producto.imagenUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.shopping_bag, size: 56, color: AppColors.blanco),
                            ),
                          )
                        : const Icon(Icons.shopping_bag, size: 56, color: AppColors.blanco),
                  ),
                ),
                if (sinStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: const Center(
                        child: Text('Sin stock',
                            style: TextStyle(
                                color: AppColors.blanco, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${producto.precio.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.naranja),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sinStock ? Colors.grey : AppColors.naranja,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: sinStock ? null : () => _addToCarrito(producto),
                    child: Text(
                      enCarrito > 0 ? 'Añadir ($enCarrito)' : 'Añadir',
                      style: const TextStyle(
                          color: AppColors.blanco, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}