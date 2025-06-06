import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color mainBackgroundColor = Color(0xFFF8FDEF);
  static const Color mainButtonColor = Color(0xFF09002F);
  static const Color largeTitleTextColor = Color(0xFFA1B1FF);
  static const Color accentColor1 = Color(0xFF44EBD3);
  static const Color accentColor2 = Color(0xFF422AD5);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: accentColor1,
          secondary: accentColor2,
          background: mainBackgroundColor,
          surface: mainBackgroundColor,
        ),
        scaffoldBackgroundColor: mainBackgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: mainButtonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accentColor1),
          ),
        ),
      );
} 