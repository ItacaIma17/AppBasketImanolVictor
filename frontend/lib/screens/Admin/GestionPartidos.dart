// lib/screens/Admin/GestionPartidosPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import '../../models/equipo.dart';
import '../../models/partido.dart';
import '../../models/role.dart';
import '../../services/autenticacion_service.dart';
import '../../services/equipoService.dart';
import '../../services/loggerService.dart';
import '../../services/partidoService.dart';

class GestionPartidosPage extends StatefulWidget {
  const GestionPartidosPage({super.key});

  @override
  State<GestionPartidosPage> createState() => _GestionPartidosPageState();
}

class _GestionPartidosPageState extends State<GestionPartidosPage> {
  List<Partido> _partidos = [];
  List<Equipo> _equipos = [];
  bool _isLoading = true;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  Equipo? _equipoLocal;
  Equipo? _equipoVisitante;
  DateTime _fechaPartido = DateTime.now();
  TimeOfDay _horaPartido = TimeOfDay.now();
  String _ubicacion = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // lib/screens/Admin/GestionPartidosPage.dart

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Verificar autenticación antes de cargar
      final token = AutenticacionService.token;
      final usuario = AutenticacionService.usuarioActual;

      LoggerService.info('Cargando datos de partidos', tag: 'PARTIDOS', data: {
        'token_existe': token != null,
        'rol_usuario': usuario?.role.toString(),
      });

      if (token == null) {
        throw Exception('No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      if (usuario?.role != Role.ADMIN) {
        throw Exception('No tienes permisos de administrador para ver esta página');
      }

      final partidos = await PartidoService.listarPartidos();
      final equipos = await EquipoService.listarEquipos();

      setState(() {
        _partidos = partidos;
        _equipos = equipos;
        _isLoading = false;
      });

      LoggerService.info('Datos cargados correctamente', tag: 'PARTIDOS',
          data: {'partidos': _partidos.length, 'equipos': _equipos.length});
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('403')) {
        errorMsg = 'No tienes permisos para ver los partidos. Asegúrate de haber iniciado sesión como administrador.';
      } else if (errorMsg.contains('401')) {
        errorMsg = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
        // Redirigir al login
        if (mounted) {
          await AutenticacionService.cerrarSesion();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }

      setState(() {
        _error = errorMsg;
        _isLoading = false;
      });

      LoggerService.error('Error cargando datos', tag: 'PARTIDOS', error: e);
    }
  }

  Future<void> _crearPartido() async {
    if (!_formKey.currentState!.validate()) return;
    if (_equipoLocal == null || _equipoVisitante == null) {
      _mostrarError('Selecciona ambos equipos');
      return;
    }
    if (_equipoLocal!.id == _equipoVisitante!.id) {
      _mostrarError('Un equipo no puede jugar contra sí mismo');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fechaHora = DateTime(
        _fechaPartido.year,
        _fechaPartido.month,
        _fechaPartido.day,
        _horaPartido.hour,
        _horaPartido.minute,
      );

      final partidoData = {
        'equipoLocalId': _equipoLocal!.id,
        'equipoVisitanteId': _equipoVisitante!.id,
        'fecha': fechaHora.toIso8601String(),
        'ubicacion': _ubicacion,
        'estado': 'PROGRAMADO',
      };

      await PartidoService.crearPartido(partidoData);

      // ✅ Recargar datos sin recargar toda la página
      await _cargarDatos();
      _limpiarFormulario();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Partido programado exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _mostrarError('Error al crear partido: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _equipoLocal = null;
      _equipoVisitante = null;
      _fechaPartido = DateTime.now();
      _horaPartido = TimeOfDay.now();
      _ubicacion = '';
    });
  }

  void _mostrarDialogoCrear() {
    _limpiarFormulario();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Programar Nuevo Partido'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Equipo Local
                    DropdownButtonFormField<Equipo>(
                      decoration: const InputDecoration(labelText: 'Equipo Local'),
                      value: _equipoLocal,
                      items: _equipos.map((equipo) {
                        return DropdownMenuItem(
                          value: equipo,
                          child: Text(equipo.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _equipoLocal = value;
                        });
                      },
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Equipo Visitante
                    DropdownButtonFormField<Equipo>(
                      decoration: const InputDecoration(labelText: 'Equipo Visitante'),
                      value: _equipoVisitante,
                      items: _equipos.map((equipo) {
                        return DropdownMenuItem(
                          value: equipo,
                          child: Text(equipo.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _equipoVisitante = value;
                        });
                      },
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Fecha
                    ListTile(
                      title: const Text('Fecha'),
                      subtitle: Text(_fechaPartido.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _fechaPartido,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() {
                            _fechaPartido = date;
                          });
                        }
                      },
                    ),

                    // Hora
                    ListTile(
                      title: const Text('Hora'),
                      subtitle: Text(_horaPartido.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _horaPartido,
                        );
                        if (time != null) {
                          setDialogState(() {
                            _horaPartido = time;
                          });
                        }
                      },
                    ),

                    // Ubicación
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                      onChanged: (value) => _ubicacion = value,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _crearPartido,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                child: const Text('Programar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gestión de Partidos', style: TextStyle(color: AppColors.blanco, fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Programar Partido'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                onPressed: _mostrarDialogoCrear,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView.builder(
                itemCount: _partidos.length,
                itemBuilder: (context, index) {
                  final partido = _partidos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.sports_basketball, color: AppColors.naranja),
                      title: Text('${partido.equipoLocal} vs ${partido.equipoVisitante}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📅 ${_formatFecha(partido.fecha)}'),
                          Text('📍 ${partido.ubicacion ?? 'Sin ubicación'}'),
                          if (partido.resultadoLocal != null)
                            Text('🏆 Resultado: ${partido.resultadoLocal} - ${partido.resultadoVisitante}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _actualizarResultado(partido),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarPartido(partido),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _actualizarResultado(Partido partido) async {
    final resultadoLocalCtrl = TextEditingController(text: partido.resultadoLocal?.toString());
    final resultadoVisitanteCtrl = TextEditingController(text: partido.resultadoVisitante?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Resultado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: resultadoLocalCtrl,
              decoration: const InputDecoration(labelText: 'Resultado Local'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: resultadoVisitanteCtrl,
              decoration: const InputDecoration(labelText: 'Resultado Visitante'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await PartidoService.actualizarResultado(partido.id!, {
                'resultadoLocal': int.tryParse(resultadoLocalCtrl.text),
                'resultadoVisitante': int.tryParse(resultadoVisitanteCtrl.text),
              });
              Navigator.pop(context);
              await _cargarDatos(); // ✅ Recargar sin recargar página
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarPartido(Partido partido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar el partido entre ${partido.equipoLocal} y ${partido.equipoVisitante}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _isLoading = true);
      try {
        await PartidoService.eliminarPartido(partido.id!);
        await _cargarDatos(); // ✅ Recargar sin recargar página
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Partido eliminado'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        _mostrarError('Error al eliminar: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}