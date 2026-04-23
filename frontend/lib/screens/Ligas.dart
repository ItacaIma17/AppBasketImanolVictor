// lib/services/liga_service.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import 'package:tfg_appfede/services/LigaService.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';
import 'Clasificacion.dart';

class LigasPage extends StatefulWidget {
  const LigasPage({super.key});

  @override
  State<LigasPage> createState() => _LigasPageState();
}

class _LigasPageState extends State<LigasPage> {
  List<Map<String, dynamic>> _ligasBD = [];
  bool _cargando = true;
  String _categoriaSeleccionada = 'Seleccionar categoría...';

@override
void initState() {
  super.initState();
  _cargarLigas();
}

void _cargarLigas() async {
  try {
    final ligas = await LigaService.listarLigas();
    setState(() {
      _ligasBD = ligas;
      _cargando = false;
    });
  } catch (e) {
    print("Error cargando ligas: $e");
    setState(() => _cargando = false);
  }
}


  @override
Widget build(BuildContext context) {
  final categoriasLimpias = _ligasBD
      .map((l) => (l['nombreLiga'] ?? '').toString().trim())
      .where((nombre) => nombre.isNotEmpty)
      .toSet() // elimina duplicados
      .toList()
    ..sort();


  if (!categoriasLimpias.contains(_categoriaSeleccionada)) {
    _categoriaSeleccionada = 'Seleccionar categoría...';
  }

  // FAVORITOS
  final ligasFavoritas = FavoritosManager()
      .categoriasFavoritas
      .map((nombre) => {'categoria': nombre})
      .toList();

  return Scaffold(
    drawer: const MenuLateral(),
    appBar: const HeaderApp(titulo: "Ligas"),
    bottomNavigationBar: const BarraInferior(selectedIndex: 0),
    body: Container(
      decoration: const BoxDecoration(
        gradient: AppColors.gradienteAragon,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona una liga',
                      style: TextStyle(
                        color: AppColors.blanco,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // DROPDOWN
                    if (_cargando)
                      const Center(
                        child: CircularProgressIndicator(color: AppColors.blanco),
                      )
                    else
                      _buildDropdown(
                        label: 'Categoría',
                        value: _categoriaSeleccionada,
                        items: [
                          'Seleccionar categoría...',
                          ...categoriasLimpias,
                        ],
                        onChanged: (value) {
                          setState(() {
                            _categoriaSeleccionada = value!;
                          });
                        },
                      ),

                    const SizedBox(height: 30),

                    // FAVORITOS
                    if (ligasFavoritas.isNotEmpty) ...[
                      Row(
                        children: const [
                          Icon(Icons.star, color: AppColors.amarilloAragon),
                          SizedBox(width: 8),
                          Text(
                            'Mis ligas favoritas',
                            style: TextStyle(
                              color: AppColors.blanco,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...ligasFavoritas
                          .map((liga) => _buildLigaFavoritaCard(liga)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
              style: const TextStyle(
                color: AppColors.negro,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLigaFavoritaCard(Map<String, dynamic> liga) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClasificacionPage(
              categoriaEdad: liga['categoria'], //
              categoriaNivel: '', // ya no se usa
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.gradienteNaranjaAmarillo,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events,
                color: AppColors.blanco, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    liga['categoria'],
                    style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.blanco, size: 16),
          ],
        ),
      ),
    );
  }
}
