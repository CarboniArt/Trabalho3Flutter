import 'package:flutter/material.dart';

class CoresApp {
  CoresApp._();

  // Cores Primarias
  static const Color azulPrincipal = Color(0xFF3B82F6); // Azul principal
  static const Color azulClaro = Color(0xFF60A5FA); // Azul claro
  static const Color azulEscuro = Color(0xFF2563EB); // Azul escuro

  static const Color azulBrapi1 = Color(0xFF3B82F6);
  static const Color azulBrapi2 = Color.fromARGB(
    255,
    121,
    160,
    223,
  );

  //Fundos
  static const Color fundoEscuro = Color(0xFF0F172A); // Fundo principal
  static const Color fundoCard = Color(0xFF1E293B); // Fundo dos cards

  //Textos
  static const Color textoBranco = Colors.white; // Texto principal
  static const Color textoBranco70 = Colors.white70; // Texto secundario
  static const Color textoClaro54 = Colors.white54; // Texto terciario
  static const Color textoAzul = Color(0xFF60A5FA); // Texto com destaque azul

  // State
  static const Color verde = Color(0xFF10B981);
  static const Color vermelho = Colors.red;

  // aux
  static Color azulComOpacity(double opacity) =>
      azulPrincipal.withOpacity(opacity);
  static Color verdeComOpacity(double opacity) => verde.withOpacity(opacity);
  static Color vermelhoComOpacity(double opacity) =>
      vermelho.withOpacity(opacity);
}
