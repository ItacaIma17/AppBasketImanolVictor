// lib/screens/Arbitro/SeleccionarPartidoPage.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/common/resources/colores.dart';
import '../../models/partido.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';
import '../arbitros/verAlineacionesPage.dart';

class SeleccionarPartidoPage extends StatefulWidget {
  const SeleccionarPartidoPage({super.key});

  @override
  State<SeleccionarPartidoPage> createState() => _SeleccionarPartidoPageState();
}

class _SeleccionarPartidoPageState extends State<SeleccionarPartidoPage> {
  List<Partido> _partidos = [];
  bool _isLoading = true;

  get ArbitroService => null;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    try {
      final partidos = await ArbitroService.getMisPartidos();
      setState(() {
        _partidos = partidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Seleccionar Partido"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _partidos.length,
          itemBuilder: (context, index) {
            final partido = _partidos[index];
            return Card(
              child: ListTile(
                title: Text('${partido.equipoLocal} vs ${partido.equipoVisitante}'),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(partido.fecha)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerAlineacionesPage(partidoId: partido.id!),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}