import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/jugador.dart';
import '../../services/equipoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import '../JugadorDetallePage.dart';

class JugadoresEquipoPage extends StatefulWidget {
  final int equipoId;

  const JugadoresEquipoPage({super.key, required this.equipoId});

  @override
  State<JugadoresEquipoPage> createState() => _JugadoresEquipoPageState();
}

class _JugadoresEquipoPageState extends State<JugadoresEquipoPage> {
  List<Jugador> _jugadores = [];
  List<Jugador> _jugadoresFiltrados = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _filtroPosicion = 'Todos';
  String _ordenarPor = 'dorsal';

  final List<String> _posiciones = [
    'Todos', 'Base', 'Escolta', 'Alero', 'Ala-Pívot', 'Pívot',
  ];

  @override
  void initState() {
    super.initState();
    _cargarJugadores();
  }

  Future<void> _cargarJugadores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jugadores = await EquipoService.getJugadoresEquipo(widget.equipoId);
      setState(() {
        _jugadores = jugadores;
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltros() {
    List<Jugador> filtrados = List.from(_jugadores);

    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((j) =>
      j.nombreCompleto.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.posicion.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_filtroPosicion != 'Todos') {
      filtrados = filtrados.where((j) => j.posicion == _filtroPosicion).toList();
    }

    switch (_ordenarPor) {
      case 'dorsal':
        filtrados.sort((a, b) => a.dorsal.compareTo(b.dorsal));
        break;
      case 'puntos':
        filtrados.sort((a, b) => b.promedioPuntos.compareTo(a.promedioPuntos));
        break;
      case 'rebotes':
        filtrados.sort((a, b) => b.promedioRebotes.compareTo(a.promedioRebotes));
        break;
      case 'asistencias':
        filtrados.sort((a, b) => b.promedioAsistencias.compareTo(a.promedioAsistencias));
        break;
    }

    setState(() {
      _jugadoresFiltrados = filtrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Jugadores del Equipo"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
          : _error != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildFiltros(),
                    Expanded(
                      child: _jugadoresFiltrados.isEmpty
                          ? _buildSinResultados()
                          : _buildJugadoresList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.rojoAragon),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppColors.blanco)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarJugadores,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: AppColors.blanco),
            decoration: InputDecoration(
              hintText: 'Buscar jugador...',
              hintStyle: const TextStyle(color: AppColors.grisClaro),
              prefixIcon: const Icon(Icons.search, color: AppColors.grisClaro),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _aplicarFiltros();
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _posiciones.map((posicion) {
                final isSelected = _filtroPosicion == posicion;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(posicion),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filtroPosicion = posicion;
                        _aplicarFiltros();
                      });
                    },
                    backgroundColor: AppColors.superficie1,
                    selectedColor: AppColors.naranja,
                    side: BorderSide(
                      color: isSelected ? AppColors.naranja : Colors.white.withOpacity(0.2)),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.negro : AppColors.grisClaro,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ordenar por:', style: TextStyle(color: AppColors.grisClaro)),

              Material(
                color: Colors.transparent,
                child: DropdownButton<String>(
                  value: _ordenarPor,
                  dropdownColor: AppColors.negro,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'dorsal', child: Text('Dorsal')),
                    DropdownMenuItem(value: 'puntos', child: Text('Puntos')),
                    DropdownMenuItem(value: 'rebotes', child: Text('Rebotes')),
                    DropdownMenuItem(value: 'asistencias', child: Text('Asistencias')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _ordenarPor = value;
                        _aplicarFiltros();
                      });
                    }
                  },
                  style: const TextStyle(color: AppColors.blanco),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: AppColors.grisClaro),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron jugadores para "$_searchQuery"'
                : 'No hay jugadores en este equipo',
            style: const TextStyle(color: AppColors.grisClaro, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildJugadoresList() {
    return RefreshIndicator(
      onRefresh: _cargarJugadores,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jugadoresFiltrados.length,
        itemBuilder: (context, index) {
          final jugador = _jugadoresFiltrados[index];
          return _buildJugadorCard(jugador);
        },
      ),
    );
  }

  Widget _buildJugadorCard(Jugador jugador) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JugadorDetallePage(
              jugador: jugador,
              equipoNombre: null,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.superficie1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppColors.naranja.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  jugador.dorsal.toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: AppColors.naranja),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jugador.nombreCompleto,
                      style: const TextStyle(color: AppColors.blanco, fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.naranja.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(jugador.posicion,
                            style: const TextStyle(fontSize: 11, color: AppColors.naranja)),
                      ),
                      const SizedBox(width: 8),
                      Text('${jugador.altura}m',
                          style: const TextStyle(fontSize: 11, color: AppColors.grisClaro)),
                      const SizedBox(width: 6),
                      Text('${jugador.peso}kg',
                          style: const TextStyle(fontSize: 11, color: AppColors.grisClaro)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(children: [
                  const Icon(Icons.sports_basketball, size: 14, color: AppColors.grisClaro),
                  const SizedBox(width: 2),
                  Text('${jugador.promedioPuntos.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          color: AppColors.naranja)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.trending_up, size: 14, color: AppColors.grisClaro),
                  const SizedBox(width: 2),
                  Text('${jugador.promedioRebotes.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.blanco)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.people, size: 14, color: AppColors.grisClaro),
                  const SizedBox(width: 2),
                  Text('${jugador.promedioAsistencias.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.blanco)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
