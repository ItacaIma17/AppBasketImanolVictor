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
}
