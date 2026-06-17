import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3D35CC);

  // Background Colors
  static const Color bgDark = Color(0xFF0F0E1A);
  static const Color bgCard = Color(0xFF1C1B2E);
  static const Color bgCardLight = Color(0xFF252440);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0AEC8);
  static const Color textHint = Color(0xFF6B698A);

  // Category Colors
  static const Color makan = Color(0xFFFF6B6B);
  static const Color belanja = Color(0xFFFF9FF3);
  static const Color kebutuhan = Color(0xFF54A0FF);
  static const Color transportasi = Color(0xFF5AEAB0);
  static const Color hiburan = Color(0xFFC9A0FF);
  static const Color lainnya = Color(0xFFFFC048);

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Makan':
        return makan;
      case 'Belanja':
        return belanja;
      case 'Kebutuhan':
        return kebutuhan;
      case 'Transportasi':
        return transportasi;
      case 'Hiburan':
        return hiburan;
      default:
        return lainnya;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Makan':
        return Icons.restaurant_rounded;
      case 'Belanja':
        return Icons.shopping_bag_rounded;
      case 'Kebutuhan':
        return Icons.home_rounded;
      case 'Transportasi':
        return Icons.directions_car_rounded;
      case 'Hiburan':
        return Icons.movie_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: bgCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Poppins'),
        hintStyle: const TextStyle(color: textHint, fontFamily: 'Poppins'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
