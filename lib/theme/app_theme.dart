import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF6F2BC2);
  static const primaryDark = Color(0xFF36165E);
  static const primaryLight = Color(0xFFEDE9FF);
  static const primaryMid = Color(0xFF9B6FD4);
  static const accent = Color(0xFF1D9E75);
  static const accentLight = Color(0xFFE1F5EE);
  static const error = Color(0xFFE24B4A);
  static const errorLight = Color(0xFFFFF0F0);
  static const background = Color(0xFFF4F3FF);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF36165E);
  static const textMuted = Color(0xFF9B89C4);
  static const border = Color(0xFFE0DDF7);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.background,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
      );
}
