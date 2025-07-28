import 'package:flutter/material.dart';

class AppTheme {
  // iOS-like color scheme
  static const Color primaryColor = Color(0xFF007AFF);
  static const Color secondaryColor = Color(0xFF5856D6);
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color separatorColor = Color(0xFFC6C6C8);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF000000);
  static const Color darkCardColor = Color(0xFF1C1C1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkSeparatorColor = Color(0xFF38383A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 15,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 34,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: darkTextSecondary,
        fontSize: 15,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: darkTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
  );
}