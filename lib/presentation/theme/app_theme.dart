import 'package:flutter/material.dart';

/// Centralised theme definitions for UniTune.
///
/// Provides a modern look with a purple/violet primary palette,
/// coral/pink accents, and fully-specified light and dark schemes.
abstract class AppTheme {
  // ── Brand colours ──────────────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF6C63FF);   // violet
  static const Color primaryDark  = Color(0xFF9D97FF);   // soft violet

  static const Color secondaryLight = Color(0xFFFF6584); // coral/pink
  static const Color secondaryDark  = Color(0xFFFF8FA3); // soft coral

  static const Color accentLight = Color(0xFF43CEA2);    // teal
  static const Color accentDark  = Color(0xFF6EEFC2);    // soft teal

  // ── Gradient helpers ───────────────────────────────────────────────────────
  static const LinearGradient lightHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF43CEA2)],
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF312E81), Color(0xFF0F4C75)],
  );

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get light {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEDE9FE),
      onPrimaryContainer: Color(0xFF3730A3),
      secondary: secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFE4E6),
      onSecondaryContainer: Color(0xFF9F1239),
      tertiary: accentLight,
      onTertiary: Colors.white,
      error: Color(0xFFDC2626),
      onError: Colors.white,
      surface: Color(0xFFF8F7FF),
      onSurface: Color(0xFF1E1B4B),
      surfaceContainerHighest: Color(0xFFEDE9FE),
      outline: Color(0xFFCBC9E2),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFFF5F4FF),
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
      cardTheme: CardTheme(
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
        backgroundColor: const Color(0xFFEDE9FE),
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
      onPrimary: Color(0xFF1E1B4B),
      primaryContainer: Color(0xFF312E81),
      onPrimaryContainer: Color(0xFFEDE9FE),
      secondary: secondaryDark,
      onSecondary: Color(0xFF4C0519),
      secondaryContainer: Color(0xFF881337),
      onSecondaryContainer: Color(0xFFFFE4E6),
      tertiary: accentDark,
      onTertiary: Color(0xFF064E3B),
      error: Color(0xFFFCA5A5),
      onError: Color(0xFF7F1D1D),
      surface: Color(0xFF1A1625),
      onSurface: Color(0xFFE2E0FF),
      surfaceContainerHighest: Color(0xFF2D2B45),
      outline: Color(0xFF4C4970),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFF120F1E),
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
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1B2E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2B45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF4C4970)),
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
