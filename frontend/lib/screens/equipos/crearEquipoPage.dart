// lib/screens/Equipos/CrearEquipoPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

import '../../models/equipo.dart';
import '../../services/equipoService.dart';
import '../Liga/LigaService.dart';

class CrearEquipoPage extends StatefulWidget {
  const CrearEquipoPage({super.key});

  @override
  State<CrearEquipoPage> createState() => _CrearEquipoPageState();
}

class _CrearEquipoPageState extends State<CrearEquipoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _estadioController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _anoController = TextEditingController();
  final _escudoUrlController = TextEditingController();

  int? _ligaId;
  List<Map<String, dynamic>> _ligas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarLigas();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _estadioController.dispose();
    _ciudadController.dispose();
    _anoController.dispose();
    _escudoUrlController.dispose();
    super.dispose();
  }

  Future<void> _cargarLigas() async {
    try {
      final ligas = await LigaService.listarLigas();
      setState(() {
        _ligas = ligas;
      });
    } catch (e) {
      print('Error cargando ligas: $e');
    }
  }

  Future<void> _crearEquipo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ligaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una liga'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final equipo = Equipo(
          nombre: _nombreController.text,
          nombreEstadio: _estadioController.text,
          ciudad: _ciudadController.text,
          anoFundacion: int.parse(_anoController.text),
          escudoUrl: _escudoUrlController.text.isNotEmpty ? _escudoUrlController.text : null,
    ligaId: _ligaId,
    );

    await EquipoService.crearEquipo(equipo as Map<String, dynamic>);

    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Equipo creado exitosamente'), backgroundColor: Colors.green),
    );
    Navigator.pop(context, true);
    }
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
    } finally {
    setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Equipo'),
        backgroundColor: AppColors.naranja,
        foregroundColor: AppColors.blanco,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nombreController, 'Nombre del equipo', Icons.sports_basketball),
                  const SizedBox(height: 16),
                  _buildTextField(_estadioController, 'Estadio', Icons.stadium),
                  const SizedBox(height: 16),
                  _buildTextField(_ciudadController, 'Ciudad', Icons.location_city),
                  const SizedBox(height: 16),
                  _buildTextField(_anoController, 'Año de fundación', Icons.calendar_today, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(_escudoUrlController, 'URL del escudo (opcional)', Icons.image),
                  const SizedBox(height: 16),
                  _buildLigaSelector(),
                  const SizedBox(height: 24),
                  _buildCrearButton(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.naranja),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.naranja),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  Widget _buildLigaSelector() {
    return DropdownButtonFormField<int>(
      value: _ligaId,
      decoration: const InputDecoration(
        labelText: 'Liga',
        prefixIcon: Icon(Icons.emoji_events, color: AppColors.naranja),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('Selecciona una liga')),
        ..._ligas.map((liga) => DropdownMenuItem<int>(
          value: liga['id'],
          child: Text(liga['nombreLiga']),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _ligaId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona una liga';
        }
        return null;
      },
    );
  }

  Widget _buildCrearButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _isLoading ? null : _crearEquipo,
        child: const Text(
          'CREAR EQUIPO',
          style: TextStyle(color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}