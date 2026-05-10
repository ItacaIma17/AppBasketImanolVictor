import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/screens/Favoritos.dart';
import 'package:tfg_appfede/screens/InicioApp.dart';
import 'package:tfg_appfede/screens/Ligas.dart';
import 'package:tfg_appfede/screens/Perfil.dart';
import 'package:tfg_appfede/screens/Tienda.dart';
import 'package:tfg_appfede/models/role.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/screens/Admin/PanelAdminPage.dart';
import 'package:tfg_appfede/screens/Entrenador/PanelEntrenadorPage.dart';
import 'package:tfg_appfede/screens/Entrenador/MiEquipoPage.dart';
import 'package:tfg_appfede/screens/arbitros/MisPartidosArbitroPage.dart';
import 'package:tfg_appfede/screens/arbitros/SeleccionarPartidoActaPage.dart';

class BarraInferior extends StatelessWidget {
  final int selectedIndex;

  const BarraInferior({super.key, required this.selectedIndex});

  static const List<String> _rutas = [
    '/ligas',
    '/tienda',
    '/inicio',
    '/favoritos',
    '/perfil',
  ];

  @override
  Widget build(BuildContext context) {
    final rol = AutenticacionService.usuarioActual?.role;
    final tabs = _tabsPorRol(rol);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.negro,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (int i = 0; i < tabs.length; i++)
                i == 2
                    ? _buildTabCentral(context, tabs[i])
                    : _buildTab(context, i, tabs[i]),
            ],
          ),
        ),
      ),
    );
  }

  List<_TabDef> _tabsPorRol(Role? rol) {
    switch (rol) {
      case Role.ADMIN:
        return [
          _TabDef(
            Icons.admin_panel_settings_outlined,
            Icons.admin_panel_settings,
            'Panel',
                () => const PanelAdminPage(),
          ),
          _TabDef(
            Icons.emoji_events_outlined,
            Icons.emoji_events,
            'Ligas',
                () => const LigasPage(),
          ),
          _TabDef(
            Icons.home_outlined,
            Icons.home,
            'Inicio',
                () => const InicioPage(),
          ),
          _TabDef(
            Icons.star_outline,
            Icons.star,
            'Favoritos',
                () => const FavoritosPage(),
          ),
          _TabDef(
            Icons.person_outline,
            Icons.person,
            'Perfil',
                () => const PerfilPage(),
          ),
        ];
      case Role.ENTRENADOR:
        return [
          _TabDef(
            Icons.dashboard_outlined,
            Icons.dashboard,
            'Panel',
                () => const PanelEntrenadorPage(),
          ),
          _TabDef(
            Icons.sports_basketball_outlined,
            Icons.sports_basketball,
            'Equipo',
                () => const MiEquipoPage(),
          ),
          _TabDef(
            Icons.home_outlined,
            Icons.home,
            'Inicio',
                () => const InicioPage(),
          ),
          _TabDef(
            Icons.star_outline,
            Icons.star,
            'Favoritos',
                () => const FavoritosPage(),
          ),
          _TabDef(
            Icons.person_outline,
            Icons.person,
            'Perfil',
                () => const PerfilPage(),
          ),
        ];
      case Role.ARBITRO:
        return [
          _TabDef(
            Icons.assignment_outlined,
            Icons.assignment,
            'Partidos',
                () => const MisPartidosArbitroPage(),
          ),
          _TabDef(
            Icons.description_outlined,
            Icons.description,
            'Acta',
                () => const SeleccionarPartidoActaPage(),
          ),
          _TabDef(
            Icons.home_outlined,
            Icons.home,
            'Inicio',
                () => const InicioPage(),
          ),
          _TabDef(
            Icons.star_outline,
            Icons.star,
            'Favoritos',
                () => const FavoritosPage(),
          ),
          _TabDef(
            Icons.person_outline,
            Icons.person,
            'Perfil',
                () => const PerfilPage(),
          ),
        ];
      case Role.JUGADOR:
      case Role.AFICIONADO:
      case Role.USUARIO:
      default:
        return [
          _TabDef(
            Icons.emoji_events_outlined,
            Icons.emoji_events,
            'Ligas',
                () => const LigasPage(),
          ),
          _TabDef(
            Icons.shopping_bag_outlined,
            Icons.shopping_bag,
            'Tienda',
                () => const TiendaPage(),
          ),
          _TabDef(
            Icons.home_outlined,
            Icons.home,
            'Inicio',
                () => const InicioPage(),
          ),
          _TabDef(
            Icons.star_outline,
            Icons.star,
            'Favoritos',
                () => const FavoritosPage(),
          ),
          _TabDef(
            Icons.person_outline,
            Icons.person,
            'Perfil',
                () => const PerfilPage(),
          ),
        ];
    }
  }

  Widget _buildTab(BuildContext context, int index, _TabDef tab) {
    final isActive = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _navegar(context, index, tab),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? tab.activo : tab.normal,
              color: isActive ? AppColors.naranja : AppColors.grisClaro,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: TextStyle(
                color: isActive ? AppColors.naranja : AppColors.grisClaro,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 3),
              height: 2,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteRojoNaranja,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabCentral(BuildContext context, _TabDef tab) {
    final isActive = selectedIndex == 2;
    return Expanded(
      child: GestureDetector(
        onTap: () => _navegar(context, 2, tab),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: isActive ? AppColors.gradienteRojoNaranja : null,
              color: isActive ? null : AppColors.grisClaro.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/LogoFAB.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  tab.activo,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navegar(BuildContext context, int index, _TabDef tab) {
    if (index == selectedIndex) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => tab.builder(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 220),
      ),
          (route) => false,
    );
  }
}

class _TabDef {
  final IconData normal;
  final IconData activo;
  final String label;
  final Widget Function() builder;

  _TabDef(this.normal, this.activo, this.label, this.builder);
}
