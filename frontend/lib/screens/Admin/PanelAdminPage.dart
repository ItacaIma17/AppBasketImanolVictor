// lib/screens/Admin/PanelAdminPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/role.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/widgets/Header.dart';
import 'package:tfg_appfede/widgets/MenuLateral.dart';
import 'ConfiguracionPage.dart';
import 'EstadisticasPage.dart';
import 'GestionEntrenadoresPage.dart';
import 'GestionEquiposPage.dart';
import 'GestionLigaPage.dart';
import 'GestionPartidos.dart';
import 'GestionUsuariosPage.dart';


class PanelAdminPage extends StatefulWidget {
  const PanelAdminPage({super.key});

  @override
  State<PanelAdminPage> createState() => _PanelAdminPageState();
}

class _PanelAdminPageState extends State<PanelAdminPage> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> _estadisticasFuture;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  void _cargarEstadisticas() {
    _estadisticasFuture = _obtenerEstadisticas();
  }

  Future<Map<String, dynamic>> _obtenerEstadisticas() async {
    // Aquí se llamarían a los servicios reales
    await Future.delayed(const Duration(seconds: 1));
    return {
      'totalUsuarios': 156,
      'totalEntrenadores': 12,
      'totalJugadores': 89,
      'totalEquipos': 24,
      'totalLigas': 4,
      'totalPartidos': 48,
      'usuariosActivos': 142,
      'partidosHoy': 3,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Panel de Administración"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Menú lateral de administración
              _buildAdminDrawer(),

              // Contenido principal
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildDashboard(),
                    const GestionUsuariosPage(),
                    const GestionEntrenadoresPage(),
                    const GestionEquiposPage(),
                    const GestionLigasPage(),
                    const GestionPartidosPage(),
                    const EstadisticasPage(),
                    const ConfiguracionPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.negro,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAdminHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildAdminMenuItem(
                  index: 0,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  color: Colors.blue,
                ),
                const Divider(color: AppColors.blancoOpacidad70),

                // SECCIÓN USUARIOS
                _buildMenuSection('USUARIOS'),
                _buildAdminMenuItem(
                  index: 1,
                  icon: Icons.people,
                  title: 'Gestionar Usuarios',
                  color: Colors.teal,
                ),
                _buildAdminMenuItem(
                  index: 2,
                  icon: Icons.person_add,
                  title: 'Gestionar Entrenadores',
                  color: Colors.orange,
                ),

                const Divider(color: AppColors.blancoOpacidad70),

                // SECCIÓN COMPETICIONES
                _buildMenuSection('COMPETICIONES'),
                _buildAdminMenuItem(
                  index: 3,
                  icon: Icons.sports_basketball,
                  title: 'Gestionar Equipos',
                  color: Colors.green,
                ),
                _buildAdminMenuItem(
                  index: 4,
                  icon: Icons.emoji_events,
                  title: 'Gestionar Ligas',
                  color: Colors.purple,
                ),
                _buildAdminMenuItem(
                  index: 5,
                  icon: Icons.calendar_today,
                  title: 'Gestionar Partidos',
                  color: Colors.red,
                ),

                const Divider(color: AppColors.blancoOpacidad70),

                // SECCIÓN REPORTES
                _buildMenuSection('REPORTES'),
                _buildAdminMenuItem(
                  index: 6,
                  icon: Icons.bar_chart,
                  title: 'Estadísticas',
                  color: Colors.amber,
                ),

                const Divider(color: AppColors.blancoOpacidad70),

                // SECCIÓN SISTEMA
                _buildMenuSection('SISTEMA'),
                _buildAdminMenuItem(
                  index: 7,
                  icon: Icons.settings,
                  title: 'Configuración',
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          _buildAdminFooter(),
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    final usuario = AutenticacionService.usuarioActual;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppColors.gradienteNaranjaAmarillo,
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.blanco,
            child: Icon(Icons.admin_panel_settings, size: 50, color: AppColors.naranja),
          ),
          const SizedBox(height: 12),
          Text(
            usuario?.nombre ?? 'Administrador',
            style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Administrador',
              style: TextStyle(color: AppColors.blanco, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.blancoOpacidad70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAdminMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final isSelected = _selectedIndex == index;

    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      leading: Icon(icon, color: isSelected ? AppColors.naranja : color),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.naranja : AppColors.blanco,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget _buildAdminFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.blancoOpacidad70)),
      ),
      child: Column(
        children: [
          const Text(
            'Federación de Baloncesto',
            style: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Versión 1.0.0',
            style: TextStyle(color: AppColors.blancoOpacidad54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ==================== DASHBOARD ====================

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido Administrador',
            style: TextStyle(
              color: AppColors.blanco,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Panel de control general de la plataforma',
            style: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Tarjetas de estadísticas
          FutureBuilder<Map<String, dynamic>>(
            future: _estadisticasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.naranja),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error al cargar estadísticas', style: TextStyle(color: Colors.red)),
                );
              }

              final stats = snapshot.data ?? {};
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Usuarios', '${stats['totalUsuarios']}', Icons.people, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Entrenadores', '${stats['totalEntrenadores']}', Icons.person_add, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Jugadores', '${stats['totalJugadores']}', Icons.sports_basketball, Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Equipos', '${stats['totalEquipos']}', Icons.sports_basketball, Colors.purple)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Ligas', '${stats['totalLigas']}', Icons.emoji_events, Colors.amber)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Partidos', '${stats['totalPartidos']}', Icons.calendar_today, Colors.red)),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Acciones rápidas
          const Text(
            'ACCIONES RÁPIDAS',
            style: TextStyle(
              color: AppColors.blanco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickAction(
                icon: Icons.person_add,
                label: 'Crear\nEntrenador',
                color: Colors.orange,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              const SizedBox(width: 16),
              _buildQuickAction(
                icon: Icons.sports_basketball,
                label: 'Crear\nEquipo',
                color: Colors.green,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
              const SizedBox(width: 16),
              _buildQuickAction(
                icon: Icons.emoji_events,
                label: 'Crear\nLiga',
                color: Colors.purple,
                onTap: () => setState(() => _selectedIndex = 4),
              ),
              const SizedBox(width: 16),
              _buildQuickAction(
                icon: Icons.calendar_today,
                label: 'Crear\nPartido',
                color: Colors.red,
                onTap: () => setState(() => _selectedIndex = 5),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Actividad reciente
          const Text(
            'ACTIVIDAD RECIENTE',
            style: TextStyle(
              color: AppColors.blanco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final actividades = [
      {'accion': 'Nuevo usuario registrado', 'usuario': 'juan_perez', 'fecha': 'Hace 5 minutos'},
      {'accion': 'Equipo actualizado', 'usuario': 'admin', 'fecha': 'Hace 1 hora'},
      {'accion': 'Partido programado', 'usuario': 'entrenador1', 'fecha': 'Hace 2 horas'},
      {'accion': 'Nueva liga creada', 'usuario': 'admin', 'fecha': 'Hace 3 horas'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actividades.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = actividades[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.naranja.withOpacity(0.1),
              child: const Icon(Icons.notifications, color: AppColors.naranja),
            ),
            title: Text(item['accion']!),
            subtitle: Text(item['usuario']!),
            trailing: Text(
              item['fecha']!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}