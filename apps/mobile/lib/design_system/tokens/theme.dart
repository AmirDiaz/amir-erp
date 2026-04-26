// Amir ERP — design system tokens & theme builder.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmirColors {
  static const primary = Color(0xFF4F46E5);   // indigo-600
  static const secondary = Color(0xFF06B6D4); // cyan-500
  static const accent = Color(0xFFF59E0B);    // amber-500
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const surface = Color(0xFFF8FAFC);
  static const surfaceDark = Color(0xFF0F172A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const muted = Color(0xFF94A3B8);
}

class AmirRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

class AmirSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AmirTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AmirColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AmirRadius.lg)),
        color: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AmirRadius.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AmirRadius.md)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AmirColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }
}
