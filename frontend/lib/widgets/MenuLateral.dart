// lib/widgets/MenuLateral.dart — VERSIÓN MEJORADA
// Navegación fluida, diseño profesional, no usa pushReplacement para poder volver atrás

import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/models/role.dart';
import 'package:tfg_appfede/screens/Admin/ConfiguracionPage.dart';
import 'package:tfg_appfede/screens/Admin/PanelAdminPage.dart';
import 'package:tfg_appfede/screens/Entrenador/EstadisticasEquipoPage.dart';
import 'package:tfg_appfede/screens/Entrenador/MiEquipoPage.dart';
import 'package:tfg_appfede/screens/Entrenador/MisPartidosEntrenadorPage.dart';
import 'package:tfg_appfede/screens/Entrenador/PanelEntrenadorPage.dart'
    hide ProximosPartidosPage, EstadisticasEquipoPage;
import 'package:tfg_appfede/screens/Entrenador/ProximosPartidosPage.dart';
import 'package:tfg_appfede/screens/Entrenador/SeleccionarPartidoEntrenadorPage.dart';
import 'package:tfg_appfede/screens/InicioApp.dart';
import 'package:tfg_appfede/screens/Inicio/InicioSesion.dart';
import 'package:tfg_appfede/screens/Ligas.dart';
import 'package:tfg_appfede/screens/Perfil.dart';
import 'package:tfg_appfede/screens/arbitros/MisPartidosArbitroPage.dart';
import 'package:tfg_appfede/screens/arbitros/SeleccionarPartidoActaPage.dart';
import 'package:tfg_appfede/screens/equipos/SolicitarEquipoPage.dart';
import 'package:tfg_appfede/screens/Favoritos.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';

import '../screens/Entrenador/ListadoEquipoPage.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = AutenticacionService.usuarioActual;
    final entrenador = AutenticacionService.entrenadorActual;
    final jugador = AutenticacionService.jugadorActual;
    final arbitro = AutenticacionService.arbitroActual;
    final rol = usuario?.role;
    final nombreMostrar = usuario?.nombreCompleto ??
        entrenador?.nombreCompleto ??
        arbitro?.nombreCompleto ??
        jugador?.nombreCompleto ??
        'Invitado';
    final emailMostrar = usuario?.email ?? '';
    final inicialAvatar = nombreMostrar.isNotEmpty
        ? nombreMostrar[0].toUpperCase()
        : '?';

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0A0A), Color(0xFF0D0D0D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────
            _buildHeader(inicialAvatar, nombreMostrar, emailMostrar, rol),

            // ── ITEMS CON SCROLL ────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildItem(context,
                      icono: Icons.home_outlined,
                      iconoActivo: Icons.home,
                      titulo: 'Inicio',
                      onTap: () => _navegar(context, const InicioPage())),

                  _buildItem(context,
                      icono: Icons.emoji_events_outlined,
                      iconoActivo: Icons.emoji_events,
                      titulo: 'Ligas',
                      onTap: () => _navegar(context, const LigasPage())),

                  _buildItem(context,
                      icono: Icons.star_outline,
                      iconoActivo: Icons.star,
                      titulo: 'Favoritos',
                      onTap: () => _navegar(context, const FavoritosPage())),

                  _buildItem(context,
                      icono: Icons.person_outline,
                      iconoActivo: Icons.person,
                      titulo: 'Mi Perfil',
                      onTap: () => _navegar(context, const PerfilPage())),

                  // ══ ENTRENADOR ══════════════════════════════════
                  if (rol == Role.ENTRENADOR && entrenador != null) ...[
                    _buildSeparador('MI EQUIPO'),
                    _buildItem(context,
                        icono: Icons.dashboard_outlined,
                        iconoActivo: Icons.dashboard,
                        titulo: 'Panel Entrenador',
                        badge: null,
                        onTap: () =>
                            _navegar(context, const PanelEntrenadorPage())),

                    if (!entrenador.tieneEquipo)
                      _buildItem(context,
                          icono: Icons.vpn_key_outlined,
                          iconoActivo: Icons.vpn_key,
                          titulo: 'Solicitar Equipo',
                          accentColor: AppColors.amarilloAragon,
                          onTap: () =>
                              _navegar(context, const SolicitarEquipoPage())),

                    if (entrenador.tieneEquipo) ...[
                      _buildItem(context,
                          icono: Icons.sports_basketball_outlined,
                          iconoActivo: Icons.sports_basketball,
                          titulo: 'Mi Equipo',
                          onTap: () =>
                              _navegar(context, const MiEquipoPage())),
                      _buildItem(context,
                          icono: Icons.calendar_month_outlined,
                          iconoActivo: Icons.calendar_month,
                          titulo: 'Próximos Partidos',
                          onTap: () => _navegar(
                              context, const ProximosPartidosPage())),
                      _buildItem(context,
                          icono: Icons.bar_chart_outlined,
                          iconoActivo: Icons.bar_chart,
                          titulo: 'Estadísticas',
                          onTap: () =>
                              _navegar(context, EstadisticasEquipoPage())),
                      _buildItem(context,
                          icono: Icons.history_outlined,
                          iconoActivo: Icons.history,
                          titulo: 'Mis Partidos',
                          onTap: () => _navegar(
                              context,
                              const MisPartidosEntrenadorPage())),
                      _buildItem(context,
                          icono: Icons.line_style_outlined,
                          iconoActivo: Icons.line_style,
                          titulo: 'Presentar Alineación',
                          accentColor: AppColors.naranja,
                          onTap: () => _navegar(
                              context,
                              const SeleccionarPartidoEntrenadorPage())),
                    ],
                  ],

                  // ══ ÁRBITRO ═════════════════════════════════════
                  if (rol == Role.ARBITRO) ...[
                    _buildSeparador('ÁRBITRO'),
                    _buildItem(context,
                        icono: Icons.assignment_outlined,
                        iconoActivo: Icons.assignment,
                        titulo: 'Mis Partidos',
                        onTap: () =>
                            _navegar(context, const MisPartidosArbitroPage())),
                    _buildItem(context,
                        icono: Icons.checklist_outlined,
                        iconoActivo: Icons.checklist,
                        titulo: 'Confirmar Alineaciones',
                        accentColor: Colors.blue.shade400,
                        onTap: () =>
                            _navegar(context, const MisPartidosArbitroPage())),
                    _buildItem(context,
                        icono: Icons.description_outlined,
                        iconoActivo: Icons.description,
                        titulo: 'Subir Acta',
                        accentColor: AppColors.naranja,
                        onTap: () => _navegar(
                            context, const SeleccionarPartidoActaPage())),
                  ],

                  // ══ JUGADOR ═════════════════════════════════════
                  if (rol == Role.JUGADOR && jugador != null) ...[
                    _buildSeparador('JUGADOR'),
                    if (jugador.tieneEquipo) ...[
                      _buildItem(context,
                          icono: Icons.sports_basketball_outlined,
                          iconoActivo: Icons.sports_basketball,
                          titulo: 'Mi Equipo',
                          onTap: () {}),
                      _buildItem(context,
                          icono: Icons.calendar_month_outlined,
                          iconoActivo: Icons.calendar_month,
                          titulo: 'Mis Partidos',
                          onTap: () {}),
                      _buildItem(context,
                          icono: Icons.assessment_outlined,
                          iconoActivo: Icons.assessment,
                          titulo: 'Mis Estadísticas',
                          onTap: () {}),
                    ] else
                      _buildItem(context,
                          icono: Icons.sports_basketball_outlined,
                          iconoActivo: Icons.sports_basketball,
                          titulo: 'Sin equipo asignado',
                          enabled: false,
                          onTap: () {}),
                  ],

                  // ══ ADMIN ════════════════════════════════════════
                  if (rol == Role.ADMIN) ...[
                    _buildSeparador('ADMINISTRACIÓN'),
                    _buildItem(context,
                        icono: Icons.admin_panel_settings_outlined,
                        iconoActivo: Icons.admin_panel_settings,
                        titulo: 'Panel de Control',
                        accentColor: AppColors.amarilloAragon,
                        onTap: () =>
                            _navegar(context, const PanelAdminPage())),
                    _buildItem(context,
                        icono: Icons.sports_basketball_outlined,
                        iconoActivo: Icons.sports_basketball,
                        titulo: 'Gestionar Equipos',
                        onTap: () =>
                            _navegar(context, const ListadoEquiposPage())),
                  ],

                  // ══ COMÚN ════════════════════════════════════════
                  _buildSeparador('AJUSTES'),
                  _buildItem(context,
                      icono: Icons.settings_outlined,
                      iconoActivo: Icons.settings,
                      titulo: 'Configuración',
                      onTap: () =>
                          _navegar(context, const ConfiguracionPage())),
                  _buildItem(context,
                      icono: Icons.info_outline,
                      iconoActivo: Icons.info,
                      titulo: 'Acerca de',
                      onTap: () => _mostrarAcercaDe(context)),

                  const SizedBox(height: 8),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 4),
                  _buildItem(context,
                      icono: Icons.logout,
                      iconoActivo: Icons.logout,
                      titulo: 'Cerrar Sesión',
                      accentColor: Colors.red.shade400,
                      onTap: () => _mostrarLogout(context)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────

  Widget _buildHeader(
      String inicial, String nombre, String email, Role? rol) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.gradienteRojoNaranja,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(inicial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Text(nombre,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          if (email.isNotEmpty)
            Text(email,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12)),
          if (rol != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _labelRol(rol),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── ITEM DE MENÚ ────────────────────────────────────────────────────────

  Widget _buildItem(
      BuildContext context, {
        required IconData icono,
        required IconData iconoActivo,
        required String titulo,
        required VoidCallback onTap,
        Color accentColor = AppColors.blanco,
        String? badge,
        bool enabled = true,
      }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icono, color: accentColor, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(titulo,
                      style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.rojoAragon,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(badge,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── SEPARADOR DE SECCIÓN ────────────────────────────────────────────────

  Widget _buildSeparador(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 4),
      child: Text(titulo,
          style: TextStyle(
              color: AppColors.naranja.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }

  // ─── NAVEGACIÓN MEJORADA ─────────────────────────────────────────────────

  void _navegar(BuildContext context, Widget page) {
    Navigator.pop(context); // cerrar drawer
    final destino = page.runtimeType;
    // Si ya estamos en esa pantalla, no apilar duplicado
    if (ModalRoute.of(context)?.settings.name == destino.toString()) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        settings: RouteSettings(name: destino.toString()),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  String _labelRol(Role rol) {
    switch (rol) {
      case Role.ADMIN: return '🔧 Administrador';
      case Role.ENTRENADOR: return '📋 Entrenador';
      case Role.ARBITRO: return '⚖️ Árbitro';
      case Role.JUGADOR: return '🏀 Jugador';
      case Role.AFICIONADO: return '👤 Aficionado';
      default: return 'Usuario';
    }
  }

  void _mostrarAcercaDe(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Acerca de',
            style: TextStyle(color: AppColors.blanco)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteRojoNaranja,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.sports_basketball,
                    color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Aragón Basket',
                style: TextStyle(
                    color: AppColors.blanco,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Federación Aragonesa de Baloncesto',
                style: TextStyle(color: AppColors.grisClaro, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Versión 1.0.0 · 2026',
                style: TextStyle(color: AppColors.naranja, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar',
                  style: TextStyle(color: AppColors.naranja))),
        ],
      ),
    );
  }

  void _mostrarLogout(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Sesión',
            style: TextStyle(color: AppColors.blanco)),
        content: const Text(
            '¿Estás seguro de que deseas cerrar tu sesión?',
            style: TextStyle(color: AppColors.grisClaro)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.grisClaro))),
          ElevatedButton(
            onPressed: () async {
              await AutenticacionService.cerrarSesion();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const InicioSesionPage()),
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
