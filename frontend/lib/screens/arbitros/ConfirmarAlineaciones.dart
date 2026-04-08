import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/widgets/Arbitros/MostrarRevisionAliniaciones.dart';
import 'package:tfg_appfede/widgets/Arbitros/TarjetaPartidoArbitro.dart';
import 'package:tfg_appfede/widgets/HeaderJornadaNavegacion.dart';


class ConfirmarAlineacionesPage extends StatefulWidget {
  const ConfirmarAlineacionesPage({super.key});

  @override
  State<ConfirmarAlineacionesPage> createState() => _ConfirmarAlineacionesPageState();
}

class _ConfirmarAlineacionesPageState extends State<ConfirmarAlineacionesPage> {
  // Jornada actual
  int _jornadaActual = 15;
  final int _totalJornadas = 22;

  // Partidos asignados al árbitro en esta jornada (vendrán de BD)
  final List<Map<String, dynamic>> _partidosAsignados = [
    {
      'id': 1,
      'equipoLocal': 'Basket Zaragoza',
      'equipoVisitante': 'CD Huesca',
      'fecha': '08/03/2026',
      'hora': '18:00',
      'pabellon': 'Pabellón Príncipe Felipe',
      'categoria': 'Senior A',
      'alineacionesConfirmadas': false,
    },
    {
      'id': 2,
      'equipoLocal': 'Oliver Basket',
      'equipoVisitante': 'Caspe Basket',
      'fecha': '08/03/2026',
      'hora': '20:00',
      'pabellon': 'Pabellón Municipal',
      'categoria': 'Senior A',
      'alineacionesConfirmadas': true,
    },
  ];

  // Alineaciones del partido seleccionado
  Map<String, dynamic>? _alineacionEquipoLocal;
  Map<String, dynamic>? _alineacionEquipoVisitante;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ Widget refactorizado - Header con navegación de jornadas
              HeaderJornadaNavegacion(
                jornadaActual: _jornadaActual,
                totalJornadas: _totalJornadas,
                titulo: 'CONFIRMAR ALINEACIONES',
                onJornadaChanged: (nuevaJornada) {
                  setState(() {
                    _jornadaActual = nuevaJornada;
                  });
                },
              ),

              // Lista de partidos asignados
              Expanded(
                child: _buildListaPartidos(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lista de partidos asignados
  Widget _buildListaPartidos() {
    if (_partidosAsignados.isEmpty) {
      return _buildEstadoVacio();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _partidosAsignados.length,
      itemBuilder: (context, index) {
        final partido = _partidosAsignados[index];
        
        // ✅ Widget refactorizado - Card de partido
        return PartidoArbitroCard(
          partido: partido,
          onRevisar: () => _mostrarModalRevisionAlineaciones(partido),
        );
      },
    );
  }

  /// Estado vacío
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 100,
            color: AppColors.blancoOpacidad70,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes partidos asignados',
            style: TextStyle(
              color: AppColors.blanco,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'En esta jornada no tienes partidos para arbitrar',
            style: TextStyle(
              color: AppColors.blancoOpacidad70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Ver alineaciones del partido (abre el modal)
  void _mostrarModalRevisionAlineaciones(Map<String, dynamic> partido) {
    // TODO: Cargar alineaciones desde BD
    _cargarAlineaciones(partido['id']);

    // ✅ Uso del widget refactorizado
    MostrarRevisionAlineaciones.mostrar(
      context: context,
      partido: partido,
      alineacionLocal: _alineacionEquipoLocal,
      alineacionVisitante: _alineacionEquipoVisitante,
      onConfirmar: () => _confirmarAlineaciones(partido),
    );
  }

  /// Cargar alineaciones desde BD
  void _cargarAlineaciones(int partidoId) {
    // TODO: Implementar carga desde BD
    // Por ahora datos de ejemplo
    setState(() {
      _alineacionEquipoLocal = {
        'equipo': 'Basket Zaragoza',
        'jugadores': [
          {'nombre': 'Pablo Pérez', 'dorsal': 7, 'posicion': 'Escolta'},
          {'nombre': 'Adrián Fernández', 'dorsal': 10, 'posicion': 'Pívot'},
          {'nombre': 'Miguel Torres', 'dorsal': 23, 'posicion': 'Base'},
          {'nombre': 'Carlos López', 'dorsal': 15, 'posicion': 'Alero'},
          {'nombre': 'David Martín', 'dorsal': 5, 'posicion': 'Ala-Pívot'},
        ],
      };

      _alineacionEquipoVisitante = {
        'equipo': 'CD Huesca',
        'jugadores': [
          {'nombre': 'Luis García', 'dorsal': 8, 'posicion': 'Base'},
          {'nombre': 'Javier Ruiz', 'dorsal': 12, 'posicion': 'Escolta'},
          {'nombre': 'Antonio Sanz', 'dorsal': 20, 'posicion': 'Alero'},
          {'nombre': 'Fernando Gil', 'dorsal': 14, 'posicion': 'Ala-Pívot'},
          {'nombre': 'Raúl Jiménez', 'dorsal': 6, 'posicion': 'Pívot'},
        ],
      };
    });
  }

  /// Confirmar alineaciones (callback del modal)
  void _confirmarAlineaciones(Map<String, dynamic> partido) {
    // TODO: Actualizar en BD que las alineaciones están confirmadas
    setState(() {
      partido['alineacionesConfirmadas'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Alineaciones confirmadas correctamente!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}