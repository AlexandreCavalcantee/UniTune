import 'package:flutter/material.dart';

/// Centralised theme definitions for UniTune.
///
/// Provides a modern dark-forward look with a deep charcoal surface and
/// vibrant green accents (action/play), matching the project brief.
abstract class AppTheme {
  // ── Brand colours ──────────────────────────────────────────────────────────
  // Purple accent (matches the provided HTML references).
  static const Color primaryLight = Color(0xFFB76DFF);
  static const Color primaryDark = Color(0xFFDDB7FF);

  static const Color secondaryLight = Color(0xFFBDBDBD); // neutral
  static const Color secondaryDark = Color(0xFFE0E0E0); // neutral

  static const Color accentLight = Color(0xFF64FFDA); // mint
  static const Color accentDark = Color(0xFF1DE9B6); // mint

  // ── Gradient helpers ───────────────────────────────────────────────────────
  static const LinearGradient lightHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B0B0D), Color(0xFFB76DFF)],
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000000), Color(0xFF2C0051)],
  );

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get light {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFF0DBFF),
      onPrimaryContainer: Color(0xFF2C0051),
      secondary: secondaryLight,
      onSecondary: Color(0xFF111114),
      secondaryContainer: Color(0xFFF2F2F4),
      onSecondaryContainer: Color(0xFF1A1A1E),
      tertiary: accentLight,
      onTertiary: Color(0xFF2C0051),
      error: Color(0xFFDC2626),
      onError: Colors.white,
      surface: Color(0xFFF7F7F8),
      onSurface: Color(0xFF111114),
      surfaceContainerHighest: Color(0xFFEFEFF2),
      outline: Color(0xFFB8B8C2),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFFF6F6F7),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: primaryLight.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFCBC9E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        prefixIconColor: primaryLight,
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryLight.withValues(alpha: 0.4),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEFEFF2),
        selectedColor: primaryLight,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryLight,
        thumbColor: primaryLight,
        inactiveTrackColor: primaryLight.withValues(alpha: 0.25),
        overlayColor: primaryLight.withValues(alpha: 0.1),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? primaryLight : null),
        trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected)
                ? primaryLight.withValues(alpha: 0.4)
                : null),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? primaryLight : null),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E1B4B),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Color(0xFF2C0051),
      primaryContainer: Color(0xFFB76DFF),
      onPrimaryContainer: Color(0xFF2C0051),
      secondary: secondaryDark,
      onSecondary: Color(0xFF111114),
      secondaryContainer: Color(0xFF2A2A2D),
      onSecondaryContainer: Color(0xFFE4E1E6),
      tertiary: accentDark,
      onTertiary: Color(0xFF2C0051),
      error: Color(0xFFFCA5A5),
      onError: Color(0xFF7F1D1D),
      surface: Color(0xFF131316),
      onSurface: Color(0xFFE4E1E6),
      surfaceContainerHighest: Color(0xFF1F1F22),
      outline: Color(0xFF4D4354),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFF000000),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1F1F22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F1F22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF4D4354)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        prefixIconColor: primaryDark,
        hintStyle: const TextStyle(color: Color(0xFF7B78A0)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: const Color(0xFF1E1B4B),
          elevation: 4,
          shadowColor: Colors.black54,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D2B45),
        selectedColor: primaryDark,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryDark,
        thumbColor: primaryDark,
        inactiveTrackColor: primaryDark.withValues(alpha: 0.25),
        overlayColor: primaryDark.withValues(alpha: 0.1),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? primaryDark : null),
        trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected)
                ? primaryDark.withValues(alpha: 0.4)
                : null),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? primaryDark : null),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2D2B45),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
