// lib/screens/Entrenador/PresentarAlineacionPage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/JugadorAlineacionTemp.dart';
import '../../models/partido.dart';
import '../../models/jugador.dart';
import '../../models/equipo.dart';
import '../../services/alineacionService.dart';
import '../../services/entrenadorService.dart';
import '../../services/equipoService.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class PresentarAlineacionPage extends StatefulWidget {
  final Partido partido;
  final bool esLocal;

  const PresentarAlineacionPage({
    super.key,
    required this.partido,
    required this.esLocal,
  });

  @override
  State<PresentarAlineacionPage> createState() => _PresentarAlineacionPageState();
}

class _PresentarAlineacionPageState extends State<PresentarAlineacionPage> {
  List<Jugador> _jugadoresEquipo = [];
  List<JugadorAlineacionTemp> _titulares = [];
  List<JugadorAlineacionTemp> _suplentes = [];
  bool _isLoading = true;
  bool _confirmada = false;
  String get _claveAlineacionFija => 'alineacion_fija_equipo_${widget.esLocal ? widget.partido.idLocal : widget.partido.idVisitante}';

  @override
  void initState() {
    super.initState();
    _cargarJugadores();
  }

  // lib/screens/Entrenador/PresentarAlineacionPage.dart

  // lib/screens/Entrenador/PresentarAlineacionPage.dart

  Future<void> _cargarJugadores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Usar el método del entrenador en lugar del de equipo
      final jugadores = await EntrenadorService.getMisJugadores();

      setState(() {
        _jugadoresEquipo = jugadores;
        _isLoading = false;
      });

      if (jugadores.isEmpty) {
        print('⚠️ No hay jugadores en este equipo');
      } else {
        print('✅ Cargados ${jugadores.length} jugadores');
      }
    } catch (e) {
      print('❌ Error cargando jugadores: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando jugadores: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _agregarTitular(Jugador jugador) {
    if (_titulares.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya has seleccionado 5 titulares'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_titulares.any((j) => j.jugador.id == jugador.id)) return;
    if (_suplentes.any((j) => j.jugador.id == jugador.id)) return;

    setState(() {
      _titulares.add(JugadorAlineacionTemp(
        jugador: jugador,
        dorsal: jugador.dorsal ?? 0,  // ← Usar valor por defecto 0 si es null
        posicion: jugador.posicion,
      ));
    });
  }


  void _agregarSuplente(Jugador jugador) {
    if (_titulares.any((j) => j.jugador.id == jugador.id)) return;
    if (_suplentes.any((j) => j.jugador.id == jugador.id)) return;

    setState(() {
      _suplentes.add(JugadorAlineacionTemp(
        jugador: jugador,
        dorsal: jugador.dorsal ?? 0,  // ← Usar valor por defecto 0 si es null
        posicion: jugador.posicion,
      ));
    });
  }

  void _removerTitular(int index) {
    setState(() {
      _titulares.removeAt(index);
    });
  }

  void _removerSuplente(int index) {
    setState(() {
      _suplentes.removeAt(index);
    });
  }

  Future<void> _guardarAlineacion() async {
    if (_titulares.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar exactamente 5 jugadores titulares'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final equipoId = widget.esLocal
          ? widget.partido.idLocal
          : widget.partido.idVisitante;

      final data = {
        'partidoId': widget.partido.id,
        'equipoId': equipoId,
        'titulares': _titulares.map((j) => {
          'jugadorId': j.jugador.id,
          'dorsal': j.dorsal,
          'posicion': j.posicion,
          'titular': true,
        }).toList(),
        'suplentes': _suplentes.map((j) => {
          'jugadorId': j.jugador.id,
          'dorsal': j.dorsal,
          'posicion': j.posicion,
          'titular': false,
        }).toList(),
        'confirmada': _confirmada,
      };

      await AlineacionService.presentarAlineacion(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Alineación presentada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarComoFija() async {
    if (_titulares.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes tener 5 titulares para guardar alineación fija')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final titularesIds = _titulares.map((e) => e.jugador.id).join(',');
    final suplentesIds = _suplentes.map((e) => e.jugador.id).join(',');
    await prefs.setString(_claveAlineacionFija, '$titularesIds|$suplentesIds');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Alineación fija guardada')),
      );
    }
  }

  Future<void> _cargarAlineacionFija() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_claveAlineacionFija);
    if (raw == null || raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay alineación fija guardada para este equipo')),
      );
      return;
    }
    final parts = raw.split('|');
    final titularesIds = (parts.isNotEmpty ? parts[0] : '')
        .split(',')
        .where((e) => e.isNotEmpty)
        .map(int.parse)
        .toSet();
    final suplentesIds = (parts.length > 1 ? parts[1] : '')
        .split(',')
        .where((e) => e.isNotEmpty)
        .map(int.parse)
        .toSet();
    setState(() {
      _titulares = _jugadoresEquipo
          .where((j) => titularesIds.contains(j.id))
          .map((j) => JugadorAlineacionTemp(jugador: j, dorsal: j.dorsal ?? 0, posicion: j.posicion))
          .toList();
      _suplentes = _jugadoresEquipo
          .where((j) => suplentesIds.contains(j.id))
          .map((j) => JugadorAlineacionTemp(jugador: j, dorsal: j.dorsal ?? 0, posicion: j.posicion))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreEquipo = widget.esLocal
        ? widget.partido.nombreLocal
        : widget.partido.nombreVisitante;

    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Presentar Alineación"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                nombreEquipo,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'vs ${widget.esLocal ? widget.partido.nombreVisitante : widget.partido.nombreLocal}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSeccionJugadores(),
                      const SizedBox(height: 16),
                      _buildSeccionTitulares(),
                      const SizedBox(height: 16),
                      _buildSeccionSuplentes(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _cargarAlineacionFija,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Usar alineación fija'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _guardarComoFija,
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar fija'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _confirmada,
                            onChanged: (value) {
                              setState(() {
                                _confirmada = value ?? false;
                              });
                            },
                          ),
                          const Text('Confirmar alineación (definitiva)'),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              _buildBotonGuardar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionJugadores() {
    if (_jugadoresEquipo.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: const Center(
            child: Text('No hay jugadores en este equipo'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jugadores del Equipo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _jugadoresEquipo.map((jugador) {
                final yaSeleccionado = _titulares.any((j) => j.jugador.id == jugador.id) ||
                    _suplentes.any((j) => j.jugador.id == jugador.id);
                return FilterChip(
                  label: Text('${jugador.dorsal} - ${jugador.nombreCompleto}'),
                  selected: yaSeleccionado,
                  onSelected: yaSeleccionado ? null : (selected) {
                    _mostrarDialogoPosicion(jugador);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionTitulares() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Titulares (${_titulares.length}/5)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_titulares.length < 5)
                  const Text(
                    'Selecciona 5 jugadores',
                    style: TextStyle(color: Colors.orange),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_titulares.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No hay titulares seleccionados')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _titulares.length,
                itemBuilder: (context, index) {
                  final item = _titulares[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(item.dorsal.toString()),
                    ),
                    title: Text(item.jugador.nombreCompleto),
                    subtitle: Text('Posición: ${item.posicion}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerTitular(index),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionSuplentes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suplentes (${_suplentes.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_suplentes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No hay suplentes seleccionados')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suplentes.length,
                itemBuilder: (context, index) {
                  final item = _suplentes[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(item.dorsal.toString()),
                    ),
                    title: Text(item.jugador.nombreCompleto),
                    subtitle: Text('Posición: ${item.posicion}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerSuplente(index),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonGuardar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _guardarAlineacion,
          child: const Text('Guardar Alineación', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  void _mostrarDialogoPosicion(Jugador jugador) {
    final dorsalCtrl = TextEditingController(text: jugador.dorsal.toString());
    final posicionCtrl = TextEditingController(text: jugador.posicion);
    bool esTitular = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(jugador.nombreCompleto),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dorsalCtrl,
                  decoration: const InputDecoration(labelText: 'Dorsal'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: posicionCtrl,
                  decoration: const InputDecoration(labelText: 'Posición'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('¿Titular?'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Titular')),
                          ButtonSegment(value: false, label: Text('Suplente')),
                        ],
                        selected: {esTitular},
                        onSelectionChanged: (set) {
                          setDialogState(() {
                            esTitular = set.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final dorsal = int.tryParse(dorsalCtrl.text) ?? jugador.dorsal;
                  final posicion = posicionCtrl.text.trim();

                  if (posicion.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Ingrese una posición'), backgroundColor: Colors.orange),
                    );
                    return;
                  }

                  setState(() {
                    if (esTitular) {
                      if (_titulares.length >= 5) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Ya tienes 5 titulares'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      _titulares.add(JugadorAlineacionTemp(
                        jugador: jugador,
                        dorsal: dorsal ?? 0,
                        posicion: posicion,
                      ));
                    } else {
                      _suplentes.add(JugadorAlineacionTemp(
                        jugador: jugador,
                        dorsal: dorsal ?? 0,
                        posicion: posicion,
                      ));
                    }
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text('Agregar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
