import 'package:flutter/material.dart';

class AppColors {
  static const brown = Color(0xFF5D4037);
  static const brownDark = Color(0xFF3E2723);
  static const cream = Color(0xFFF6EFE7);
  static const accent = Color(0xFFC4784A);
  static const card = Color(0xFFFFFBFF);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brown,
      primary: AppColors.brown,
      surface: AppColors.cream,
    ),
    scaffoldBackgroundColor: AppColors.cream,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.brownDark,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brown,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
