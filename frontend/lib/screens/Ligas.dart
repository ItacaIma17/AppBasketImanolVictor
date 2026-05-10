// lib/screens/LigasPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/data/gestorFavoritos.dart';
import 'package:tfg_appfede/models/liga.dart';
import 'package:tfg_appfede/widgets/BarraInferior.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';
import 'package:tfg_appfede/widgets/tarjetas/TarjetaEntidad.dart';
import 'Clasificacion.dart';
import 'Liga/LigaService.dart';

class LigasPage extends StatefulWidget {
  const LigasPage({super.key});

  @override
  State<LigasPage> createState() => _LigasPageState();
}

class _LigasPageState extends State<LigasPage> {
  List<Liga> _ligasBD = [];
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
    // Obtener categorías únicas de las ligas
    final categoriasLimpias = _ligasBD
        .map((l) => l.nombreLiga)
        .where((nombre) => nombre.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Resetear selección si la categoría ya no existe
    if (!categoriasLimpias.contains(_categoriaSeleccionada) &&
        _categoriaSeleccionada != 'Seleccionar categoría...') {
      _categoriaSeleccionada = 'Seleccionar categoría...';
    }

    // Obtener ligas favoritas desde GestorFavoritos
    final favoritosManager = FavoritosManager();
    final ligasFavoritas = favoritosManager.categoriasFavoritas;

    // Filtrar ligas según categoría seleccionada
    final ligasFiltradas = _categoriaSeleccionada == 'Seleccionar categoría...'
        ? _ligasBD
        : _ligasBD.where((liga) => liga.nombreLiga == _categoriaSeleccionada).toList();

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

                      // Dropdown de categorías
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

                      // Sección de ligas favoritas
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
                        ...ligasFavoritas.map((nombreLiga) => _buildLigaFavoritaCard(nombreLiga)),
                        const SizedBox(height: 30),
                      ],

                      // Sección de todas las ligas
                      if (ligasFiltradas.isNotEmpty) ...[
                        Row(
                          children: const [
                            Icon(Icons.emoji_events, color: AppColors.amarilloAragon),
                            SizedBox(width: 8),
                            Text(
                              'Todas las ligas',
                              style: TextStyle(
                                color: AppColors.blanco,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...ligasFiltradas.map((liga) => _buildLigaCard(liga)),
                      ] else if (!_cargando && ligasFiltradas.isEmpty && _categoriaSeleccionada != 'Seleccionar categoría...') ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No hay ligas en esta categoría',
                              style: TextStyle(color: AppColors.blancoOpacidad70),
                            ),
                          ),
                        ),
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

  // ✅ CORREGIDO: Dropdown envuelto en Material para evitar error
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
          // ✅ FIX: Envolver DropdownButton en Material
          Material(
            color: Colors.transparent,
            child: DropdownButtonHideUnderline(
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
          ),
        ],
      ),
    );
  }

  Widget _buildLigaCard(Liga liga) {
    final infos = <TarjetaInfo>[
      TarjetaInfo(icono: Icons.location_on, texto: liga.pais ?? 'España'),
      TarjetaInfo(
        icono: Icons.people,
        texto: '${liga.numeroEquiposRegistrados} equipos',
      ),
      if (liga.temporada != null)
        TarjetaInfo(icono: Icons.calendar_today, texto: liga.temporada!),
    ];

    return TarjetaEntidad(
      tipo: TipoEntidad.liga,
      titulo: liga.nombreLiga,
      infos: infos,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClasificacionPage(
              id_categoria: liga.id ?? 0,
              categoria: liga.nombreLiga,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLigaFavoritaCard(String nombreLiga) {
    final liga = _ligasBD.firstWhere(
          (l) => l.nombreLiga == nombreLiga,
      orElse: () => Liga(
        id: 0,
        nombreLiga: nombreLiga,
        numeroEquipos: 0,
        numeroEquiposRegistrados: 0,
        descripcion: '',
      ),
    );

    return TarjetaEntidad(
      tipo: TipoEntidad.liga,
      titulo: nombreLiga,
      badge: '★',
      iconoOverride: Icons.star,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClasificacionPage(
              id_categoria: liga.id ?? 0,
              categoria: liga.nombreLiga,
            ),
          ),
        );
      },
    );
  }
}