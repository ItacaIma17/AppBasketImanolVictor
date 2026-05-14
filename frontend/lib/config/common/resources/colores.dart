import 'package:flutter/material.dart';

class AppColors {

  static const Color rojoAragon = Color(0xFFC4161C);

  static const Color amarilloAragon = Color(0xFFF2C200);

  static const Color naranja = Color(0xFFF28C00);

  static const Color negro = Color(0xFF0D0D0D);

  static const Color blanco = Color(0xFFFFFFFF);

  static const Color grisClaro = Color(0xFFD9D9D9);

  static const LinearGradient gradienteAragon = LinearGradient(
    colors: [rojoAragon, amarilloAragon],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradienteRojoNaranja = LinearGradient(
    colors: [rojoAragon, naranja],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteNaranjaAmarillo = LinearGradient(
    colors: [naranja, amarilloAragon],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Color negroOpacidad50 = Color(0x800D0D0D);

  static const Color blancoOpacidad70 = Color(0xB3FFFFFF);

  static const Color blancoOpacidad54 = Color(0x8AFFFFFF);

  // Superficies oscuras para cards
  static const Color superficie1 = Color(0xFF1A1A1A);
  static const Color superficie2 = Color(0xFF242424);

  // Colores de rol
  static const Color rolAdmin     = rojoAragon;
  static const Color rolEntrenador = naranja;
  static const Color rolArbitro   = amarilloAragon;
  static const Color rolJugador   = Color(0xFFE07000); // naranja oscuro

  static const LinearGradient gradienteAdmin = LinearGradient(
    colors: [Color(0xFF8B0000), rojoAragon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteEntrenador = LinearGradient(
    colors: [Color(0xFFB85E00), naranja],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteArbitro = LinearGradient(
    colors: [naranja, amarilloAragon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteJugador = LinearGradient(
    colors: [rojoAragon, naranja],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
