import 'package:flutter/material.dart';
import 'common/resources/colores.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rojoAragon,
        primary: AppColors.rojoAragon,
        secondary: AppColors.naranja,
        tertiary: AppColors.amarilloAragon,
        surface: AppColors.negro,
        onPrimary: AppColors.blanco,
        onSecondary: AppColors.blanco,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.negro,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.negro,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.blanco,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: AppColors.blanco),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rojoAragon,
          foregroundColor: AppColors.blanco,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.naranja,
          side: const BorderSide(color: AppColors.naranja, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.naranja,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.blancoOpacidad54),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.blancoOpacidad54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.blancoOpacidad70, fontSize: 14),
        prefixIconColor: AppColors.naranja,
        suffixIconColor: AppColors.blancoOpacidad70,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: AppColors.naranja,
        labelStyle: const TextStyle(color: AppColors.blanco, fontSize: 13),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.12),
        thickness: 1,
        space: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.negro,
        selectedItemColor: AppColors.naranja,
        unselectedItemColor: AppColors.grisClaro,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.negro,
        contentTextStyle: const TextStyle(color: AppColors.blanco),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: AppColors.blanco,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        contentTextStyle: TextStyle(
          color: AppColors.blancoOpacidad70,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.naranja,
        unselectedLabelColor: AppColors.grisClaro,
        indicatorColor: AppColors.naranja,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Roboto'),
        unselectedLabelStyle: TextStyle(fontSize: 13, fontFamily: 'Roboto'),
      ),
    );
  }
}

class FabCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const FabCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class EstadoBadge extends StatelessWidget {
  final String texto;
  final Color? color;

  const EstadoBadge({super.key, required this.texto, this.color});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    switch (texto.toUpperCase()) {
      case 'FINALIZADO':
        bgColor = Colors.green.shade700;
        break;
      case 'EN_CURSO':
      case 'EN CURSO':
        bgColor = AppColors.naranja;
        break;
      case 'PROGRAMADO':
        bgColor = Colors.blue.shade700;
        break;
      case 'SUSPENDIDO':
        bgColor = Colors.red.shade700;
        break;
      default:
        bgColor = color ?? Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final Color? color;

  const StatBox({
    super.key,
    required this.valor,
    required this.etiqueta,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            color: color ?? AppColors.amarilloAragon,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: const TextStyle(
            color: AppColors.grisClaro,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class FabPrimaryButton extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icono;

  const FabPrimaryButton({
    super.key,
    required this.texto,
    this.onPressed,
    this.isLoading = false,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? null
              : AppColors.gradienteRojoNaranja,
          color: onPressed == null ? Colors.grey.shade800 : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: AppColors.blanco,
              strokeWidth: 2.5,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icono != null) ...[
                Icon(icono, color: AppColors.blanco, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                texto,
                style: const TextStyle(
                  color: AppColors.blanco,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String titulo;
  final Widget? trailing;

  const SectionHeader({super.key, required this.titulo, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.gradienteRojoNaranja,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

