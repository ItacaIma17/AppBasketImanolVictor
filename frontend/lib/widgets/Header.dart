// lib/widgets/Header.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

class HeaderApp extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget>? actions;  // ← Añadir este parámetro

  const HeaderApp({
    super.key,
    required this.titulo,
    this.actions,  // ← Añadir
  });


  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.blanco,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.naranja,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.blanco),
      actions: actions,  // ← Usar el parámetro
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}