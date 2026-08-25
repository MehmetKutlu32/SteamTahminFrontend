import 'package:flutter/material.dart';

class SteamColors {
  // Primary Steam Palette
  static const Color darkBg = Color(0xFF0E141B);
  static const Color navyBg = Color(0xFF171A21);
  static const Color cardBg = Color(0xFF1B2838);
  static const Color cardSurface = Color(0xFF213244);
  static const Color cardBorder = Color(0xFF2A475E);

  // Steam Brand Accents
  static const Color steamBlue = Color(0xFF66C0F4);
  static const Color steamBlueDark = Color(0xFF1999DF);
  static const Color steamCyan = Color(0xFF4CD5FF);
  
  // Steam Rating Accents
  static const Color positiveReview = Color(0xFF66C0F4);
  static const Color positiveGreen = Color(0xFF67C1F5); // or 0xFFA4D007
  static const Color negativeReview = Color(0xFFC24242);
  static const Color warning = Color(0xFFFFB800);

  // Text Colors
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF8F98A0);
  static const Color textMuted = Color(0xFF566575);

  // Button Gradients
  static const LinearGradient steamButtonGradient = LinearGradient(
    colors: [Color(0xFF47BFFF), Color(0xFF1A9FFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient greenActionGradient = LinearGradient(
    colors: [Color(0xFF75B022), Color(0xFF588A1B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1B2838), Color(0xFF16202D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class SteamTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SteamColors.darkBg,
      primaryColor: SteamColors.steamBlue,
      colorScheme: const ColorScheme.dark(
        primary: SteamColors.steamBlue,
        secondary: SteamColors.steamCyan,
        surface: SteamColors.cardBg,
        error: SteamColors.negativeReview,
        onPrimary: Colors.black,
        onSurface: SteamColors.textPrimary,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: SteamColors.navyBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: SteamColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        iconTheme: IconThemeData(color: SteamColors.steamBlue),
      ),
      cardTheme: CardThemeData(
        color: SteamColors.cardBg,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SteamColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SteamColors.cardSurface,
        hintStyle: const TextStyle(color: SteamColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: SteamColors.textSecondary),
        prefixIconColor: SteamColors.steamBlue,
        suffixIconColor: SteamColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: SteamColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: SteamColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: SteamColors.steamBlue, width: 1.5),
        ),
      ),
    );
  }
}
