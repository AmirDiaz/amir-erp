// Amir ERP — design system tokens & theme builder.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AmirColors {
  // Brand
  static const primary = Color(0xFF6366F1); // indigo-500
  static const primaryDeep = Color(0xFF4338CA); // indigo-700
  static const secondary = Color(0xFF06B6D4); // cyan-500
  static const accent = Color(0xFFF59E0B); // amber-500
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Surfaces (dark first — modern SaaS look)
  static const bg = Color(0xFF0B0F1A);
  static const surface = Color(0xFF111827);
  static const surfaceAlt = Color(0xFF1F2937);
  static const card = Color(0xFF131A2A);
  static const stroke = Color(0xFF1F2A3D);
  static const muted = Color(0xFF94A3B8);
  static const onPrimary = Color(0xFFFFFFFF);

  // Light surfaces
  static const lightBg = Color(0xFFF8FAFC);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightStroke = Color(0xFFE2E8F0);
}

class AmirGradients {
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
  );
  static const brandSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF818CF8), Color(0xFF22D3EE)],
  );
  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  );
  static const success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
  );
  static const surfaceGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F2937), Color(0xFF0B0F1A)],
  );
}

class AmirRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const pill = 999.0;
}

class AmirSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AmirShadows {
  static const card = [
    BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const glow = [
    BoxShadow(color: Color(0x556366F1), blurRadius: 36, spreadRadius: -6, offset: Offset(0, 12)),
  ];
  static const subtle = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

class AmirTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AmirColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      surface: AmirColors.lightCard,
      primary: AmirColors.primary,
      secondary: AmirColors.secondary,
    );
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light, colorScheme: scheme);
    return _decorate(base, isDark: false);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AmirColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      surface: AmirColors.surface,
      primary: AmirColors.primary,
      secondary: AmirColors.secondary,
    );
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: scheme);
    return _decorate(base, isDark: true);
  }

  static ThemeData _decorate(ThemeData base, {required bool isDark}) {
    final cardColor = isDark ? AmirColors.card : AmirColors.lightCard;
    final stroke = isDark ? AmirColors.stroke : AmirColors.lightStroke;
    return base.copyWith(
      scaffoldBackgroundColor: isDark ? AmirColors.bg : AmirColors.lightBg,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: isDark ? Colors.white : const Color(0xFF0B1220),
        displayColor: isDark ? Colors.white : const Color(0xFF0B1220),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AmirRadius.lg),
          side: BorderSide(color: stroke, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AmirRadius.md)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.2),
          backgroundColor: AmirColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AmirRadius.md)),
          side: BorderSide(color: stroke),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AmirColors.surfaceAlt.withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: TextStyle(color: AmirColors.muted.withValues(alpha: 0.7)),
        labelStyle: TextStyle(color: AmirColors.muted, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AmirRadius.md),
          borderSide: BorderSide(color: stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AmirRadius.md),
          borderSide: BorderSide(color: stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AmirRadius.md),
          borderSide: const BorderSide(color: AmirColors.primary, width: 1.6),
        ),
      ),
      dividerColor: stroke,
      iconTheme: IconThemeData(color: AmirColors.muted),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardColor,
        indicatorColor: AmirColors.primary.withValues(alpha: 0.18),
        selectedIconTheme: const IconThemeData(color: AmirColors.primary),
        selectedLabelTextStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AmirColors.primary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AmirColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AmirRadius.sm),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static SystemUiOverlayStyle get sysUI => const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AmirColors.bg,
      );
}
