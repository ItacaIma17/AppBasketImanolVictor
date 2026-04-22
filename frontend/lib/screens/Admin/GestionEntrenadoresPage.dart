// lib/screens/Admin/GestionEntrenadoresPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';

import '../../models/entrenador.dart';
import '../../models/equipo.dart';
import '../../services/entrenadorService.dart';
import '../../services/equipoService.dart';

class GestionEntrenadoresPage extends StatefulWidget {
  const GestionEntrenadoresPage({super.key});

  @override
  State<GestionEntrenadoresPage> createState() => _GestionEntrenadoresPageState();
}

class _GestionEntrenadoresPageState extends State<GestionEntrenadoresPage> {
  List<Entrenador> _entrenadores = [];
  List<Equipo> _equipos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entrenadores = await EntrenadorService.listarEntrenadoresSinEquipo();
      final equipos = await EquipoService.listarEquiposSinEntrenador();

      setState(() {
        _entrenadores = entrenadores;
        _equipos = equipos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generarCodigo() async {
    try {
      final codigo = await EntrenadorService.generarCodigo();
      if (mounted) {
        _mostrarDialogoCodigo(codigo);
      }
    } catch (e) {
      _mostrarError('Error al generar código: $e');
    }
  }

  void _mostrarDialogoCodigo(String codigo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código de Entrenador Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.vpn_key, size: 64, color: AppColors.naranja),
            const SizedBox(height: 16),
            const Text(
              'Comparte este código con el entrenador:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.naranja.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.naranja),
              ),
              child: SelectableText(
                codigo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.naranja,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'El entrenador deberá usar este código al registrarse',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAsignacion(Entrenador entrenador) {
    Equipo? equipoSeleccionado;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Asignar equipo a ${entrenador.nombre} ${entrenador.apellido ?? ''}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_basketball, size: 48, color: AppColors.naranja),
                const SizedBox(height: 16),
                const Text('Selecciona el equipo que dirigirá:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<Equipo>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  hint: const Text('Seleccionar equipo'),
                  items: _equipos.map((equipo) {
                    return DropdownMenuItem(
                      value: equipo,
                      child: Text(equipo.nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      equipoSeleccionado = value;
                    });
                  },
                ),
                if (_equipos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'No hay equipos sin entrenador disponibles',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: equipoSeleccionado == null ? null : () async {
                  Navigator.pop(context);
                  await _asignarEquipo(entrenador, equipoSeleccionado!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,
                ),
                child: const Text('Asignar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _asignarEquipo(Entrenador entrenador, Equipo equipo) async {
    setState(() => _isLoading = true);

    try {
      await EntrenadorService.asignarEquipo(
        codigoEntrenador: entrenador.codigoEntrenador,
        equipoId: equipo.id!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Equipo "${equipo.nombre}" asignado a ${entrenador.nombre}'),
            backgroundColor: Colors.green,
          ),
        );
        await _cargarDatos();
      }
    } catch (e) {
      _mostrarError('Error al asignar equipo: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Gestionar Entrenadores"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.amarilloAragon),
                  ),
                )
                    : _error != null
                    ? _buildErrorWidget()
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _generarCodigo,
              icon: const Icon(Icons.vpn_key, color: AppColors.blanco),
              label: const Text(
                'Generar Código',
                style: TextStyle(color: AppColors.blanco),
              ),
            ),
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
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.blanco),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarDatos,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_entrenadores.isEmpty && _equipos.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    '¡Todo está al día!',
                    style: TextStyle(color: AppColors.blanco, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No hay entrenadores sin equipo pendientes',
                    style: TextStyle(color: AppColors.blancoOpacidad70),
                  ),
                ],
              ),
            )
          else ...[
            if (_entrenadores.isNotEmpty) ...[
              const Text(
                'ENTRENADORES SIN EQUIPO',
                style: TextStyle(
                  color: AppColors.blanco,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ..._entrenadores.map((entrenador) => _buildEntrenadorCard(entrenador)),
              const SizedBox(height: 24),
            ],
            if (_equipos.isNotEmpty) ...[
              const Text(
                'EQUIPOS DISPONIBLES',
                style: TextStyle(
                  color: AppColors.blanco,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ..._equipos.map((equipo) => _buildEquipoCard(equipo)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEntrenadorCard(Entrenador entrenador) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.naranja.withOpacity(0.2),
          child: Text(
            entrenador.nombre[0].toUpperCase(),
            style: const TextStyle(color: AppColors.naranja, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${entrenador.nombre} ${entrenador.apellido ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entrenador.email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Código: ${entrenador.codigoEntrenador}',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _mostrarDialogoAsignacion(entrenador),
          child: const Text('Asignar Equipo', style: TextStyle(color: AppColors.blanco)),
        ),
      ),
    );
  }

  Widget _buildEquipoCard(Equipo equipo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.sports_basketball, color: AppColors.naranja),
        title: Text(equipo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Liga: ${equipo.nombreLiga ?? "Sin liga"}'),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
}