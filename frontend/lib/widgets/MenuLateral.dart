// lib/widgets/MenuLateral.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/role.dart';
import 'package:tfg_appfede/screens/Admin/ConfiguracionPage.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import '../screens/Admin/GestionEntrenadoresPage.dart';
import '../screens/Admin/PanelAdminPage.dart';
import '../screens/Entrenador/MiEquipoPage.dart';
import '../screens/Entrenador/PanelEntrenadorPage.dart' hide ProximosPartidosPage, EstadisticasEquipoPage; 
import '../screens/Entrenador/ProximosPartidosPage.dart';
import '../screens/Entrenador/EstadisticasEquipoPage.dart';
import '../screens/InicioApp.dart';
import '../screens/Inicio/InicioSesion.dart';
import '../screens/Partidos/SeleccionarPartidoPage.dart';
import '../screens/Perfil.dart';
import '../screens/arbitros/MisPartidosPage.dart';
import '../screens/arbitros/SeleccionarPartidoActaPage.dart';
import '../screens/entrenador/ListadoEquipoPage.dart';
import '../screens/entrenador/SeleccionarPartidoEntrenadorPage.dart';
import '../screens/entrenador/misPartidosEntrenadorPage.dart';
import '../screens/equipos/SolicitarEquipoPage.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = AutenticacionService.usuarioActual;
    final entrenador = AutenticacionService.entrenadorActual;
    final jugador = AutenticacionService.jugadorActual;
    final rol = usuario?.role;

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(usuario?.nombreCompleto ?? 'Usuario'),
            const Divider(color: AppColors.blancoOpacidad70),

            // Opciones comunes para todos
            _buildDrawerItem(
              icon: Icons.home,
              title: 'Inicio',
              onTap: () => _navigateTo(context, const InicioPage()),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Mi Perfil',
              onTap: () => _navigateTo(context, const PerfilPage()),
            ),
            const Divider(color: AppColors.blancoOpacidad70),

            // ============================================
            // OPCIONES PARA ENTRENADOR
            // ============================================
            if (rol == Role.ENTRENADOR && entrenador != null) ...[
              _buildDrawerItem(
                icon: Icons.dashboard,
                title: 'Panel de Entrenador',
                onTap: () => _navigateTo(context, const PanelEntrenadorPage()),
              ),
              _buildDrawerItem(
                icon: Icons.sports_basketball,
                title: 'Mi Equipo',
                onTap: () => _navigateTo(context, const MiEquipoPage()),
              ),

              // Mostrar "Solicitar Equipo" solo si NO tiene equipo
              if (!entrenador.tieneEquipo) ...[
                _buildDrawerItem(
                  icon: Icons.vpn_key,
                  title: 'Solicitar Equipo',
                  onTap: () => _navigateTo(context, const SolicitarEquipoPage()),
                ),
              ],


              // Mostrar opciones solo si TIENE equipo
              if (entrenador.tieneEquipo && entrenador.equipoId != null) ...[
                _buildDrawerItem(
                  icon: Icons.calendar_today,
                  title: 'Próximos Partidos',
                  onTap: () => _navigateTo(context, const ProximosPartidosPage()), 
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: 'Estadísticas Equipo',
                  onTap: () => _navigateTo(context, EstadisticasEquipoPage()),  
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_today,
                  title: 'Mis Partidos',
                  onTap: () => _navigateTo(context, const MisPartidosEntrenadorPage()),
                ),
                _buildDrawerItem(
                  icon: Icons.line_style,
                  title: 'Presentar Alineación',
                  onTap: () => _navigateTo(context, const SeleccionarPartidoEntrenadorPage()),
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Configuración',
                  onTap: () => _navigateTo(context, const ConfiguracionPage()),
                ),
              ],
              const Divider(color: AppColors.blancoOpacidad70),
            ],

            // ============================================
            // OPCIONES PARA ÁRBITRO
            // ============================================
            if (rol == Role.ARBITRO) ...[
              _buildDrawerItem(
                icon: Icons.assignment,
                title: 'Mis Partidos',
                onTap: () => _navigateTo(context, const MisPartidosPage()),
              ),
              _buildDrawerItem(
                icon: Icons.people,
                title: 'Ver Alineaciones',
                onTap: () => _navigateTo(context, const SeleccionarPartidoPage()),
              ),
              _buildDrawerItem(
                icon: Icons.description,
                title: 'Crear Acta',
                onTap: () => _navigateTo(context, const SeleccionarPartidoActaPage()),
              ),
              const Divider(color: AppColors.blancoOpacidad70),
            ],

            // ============================================
            // OPCIONES PARA ADMIN
            // ============================================
            if (rol == Role.ADMIN) ...[
              _buildDrawerItem(
                icon: Icons.admin_panel_settings,
                title: 'Panel de Control',
                onTap: () => _navigateTo(context, const PanelAdminPage()),
              ),
              _buildDrawerItem(
                icon: Icons.people,
                title: 'Gestionar Entrenadores',
                onTap: () => _navigateTo(context, const GestionEntrenadoresPage()),
              ),
              _buildDrawerItem(
                icon: Icons.sports_basketball,
                title: 'Gestionar Equipos',
                onTap: () => _navigateTo(context, const ListadoEquiposPage()),
              ),
              const Divider(color: AppColors.blancoOpacidad70),
            ],

            // ============================================
            // OPCIONES PARA JUGADOR
            // ============================================
            if (rol == Role.JUGADOR && jugador != null) ...[
              _buildDrawerItem(
                icon: Icons.sports_basketball,
                title: 'Mi Equipo',
                onTap: () {},
              ),
              if (jugador.tieneEquipo) ...[
                _buildDrawerItem(
                  icon: Icons.calendar_today,
                  title: 'Mis Partidos',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.assessment,
                  title: 'Mis Estadísticas',
                  onTap: () {},
                ),
              ],
              const Divider(color: AppColors.blancoOpacidad70),
            ],

            // Opciones comunes
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Configuración',
              onTap: () => _navigateTo(context, const ConfiguracionPage()),
            ),
            _buildDrawerItem(
              icon: Icons.info,
              title: 'Acerca de',
              onTap: () => _showAboutDialog(context),
            ),
            const Divider(color: AppColors.blancoOpacidad70),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Cerrar Sesión',
              onTap: () => _showLogoutDialog(context),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(String nombre) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(gradient: AppColors.gradienteNaranjaAmarillo),
      accountName: Text(nombre, style: const TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold)),
      accountEmail: const Text('Bienvenido', style: TextStyle(color: AppColors.blanco)),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: AppColors.blanco,
        child: Icon(Icons.person, color: AppColors.naranja, size: 40),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.blanco,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await AutenticacionService.cerrarSesion();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const InicioSesionPage()),
                );
              }
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_basketball, size: 50, color: AppColors.naranja),
            SizedBox(height: 10),
            Text('App de la Federación de Baloncesto'),
            SizedBox(height: 5),
            Text('Versión 1.0.0'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

