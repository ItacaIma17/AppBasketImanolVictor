// lib/widgets/SeccionFavoritos.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../screens/JugadorDetallePage.dart';
import '../models/jugador.dart';
import '../services/FavoritosPage.dart';
import 'Header.dart';

// Nota: Necesitarás importar las páginas de equipo y liga
// import '../screens/Equipos.dart';
// import '../screens/GestionLigaPage.dart';

class SeccionFavoritos extends StatefulWidget {
  const SeccionFavoritos({super.key});

  @override
  State<SeccionFavoritos> createState() => _SeccionFavoritosState();
}

class _SeccionFavoritosState extends State<SeccionFavoritos> {
  final FavoritosService _favoritosService = FavoritosService();
  List<Map<String, dynamic>> _jugadoresFavoritos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    if (!mounted) return;

    setState(() => _cargando = true);

    final jugadores = await FavoritosService.obtenerJugadoresFavoritos();

    if (mounted) {
      setState(() {
        _jugadoresFavoritos = jugadores;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.naranja),
        ),
      );
    }

    if (_jugadoresFavoritos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.star_border, size: 32, color: Colors.white54),
            SizedBox(height: 8),
            Text(
              'Tus favoritos aparecerán aquí',
              style: TextStyle(color: Colors.white54),
            ),
            Text(
              'Marca jugadores, equipos o ligas como favoritos',
              style: TextStyle(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text(
                'MIS FAVORITOS',
                style: TextStyle(
                  color: AppColors.naranja,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _jugadoresFavoritos.length,
            itemBuilder: (context, index) {
              final favorito = _jugadoresFavoritos[index];
              return GestureDetector(
                onTap: () {
                  // Navegar al detalle del jugador
                  // Necesitarás cargar el jugador completo o pasar el ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: HeaderApp(titulo: favorito['nombre']),
                        body: Center(
                          child: Text('Detalle del jugador ${favorito['nombre']}'),
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 32, color: Colors.green),
                      const SizedBox(height: 4),
                      Text(
                        favorito['nombre'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (favorito['equipoNombre'] != null)
                        Text(
                          favorito['equipoNombre']!,
                          style: const TextStyle(color: Colors.white54, fontSize: 9),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}