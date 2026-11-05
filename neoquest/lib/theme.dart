import 'package:flutter/material.dart';

abstract final class NeoColors {
  static const ink = Color(0xFF181C34);
  static const muted = Color(0xFF777B8C);
  static const paper = Color(0xFFF8F7F3);
  static const surface = Color(0xFFFFFFFF);
  static const violet = Color(0xFF3F7055);
  static const violetDark = Color(0xFF284B39);
  static const lilac = Color(0xFFE6EFE5);
  static const lime = Color(0xFFD8EF86);
  static const line = Color(0xFFE4E7E1);
  static const coral = Color(0xFFF18D72);
}

abstract final class NeoTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: NeoColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: NeoColors.violet,
      primary: NeoColors.violet,
      surface: NeoColors.surface,
      onSurface: NeoColors.ink,
    ),
    fontFamily: 'Arial',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 46,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.6,
        color: NeoColors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: NeoColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: NeoColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: NeoColors.ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: NeoColors.ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: NeoColors.muted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: NeoColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NeoColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NeoColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NeoColors.violet, width: 1.5),
      ),
    ),
  );
}
