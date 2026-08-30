import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class DarkTheme {
  DarkTheme._();

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.accent,
          error: AppColors.error,
          surface: AppColors.surfaceDark,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimaryDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        cardColor: AppColors.surfaceDark,
        dividerColor: AppColors.dividerDark,
        textTheme: ThemeData.dark().textTheme.copyWith(
              displayLarge: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
              displayMedium: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              headlineLarge: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              headlineMedium: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              headlineSmall: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              titleLarge: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: const TextStyle(
                  color: AppColors.textPrimaryDark, fontSize: 16),
              bodyMedium: const TextStyle(
                  color: AppColors.textSecondaryDark, fontSize: 14),
              bodySmall:
                  const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
              labelLarge: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              labelMedium: const TextStyle(
                  color: AppColors.textSecondaryDark, fontSize: 12),
              labelSmall:
                  const TextStyle(color: AppColors.textMutedDark, fontSize: 11),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMutedDark,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 52),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardDark, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          hintStyle: const TextStyle(color: AppColors.textMutedDark),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardDark, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.cardDark,
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          labelStyle: const TextStyle(fontSize: 12),
          side: const BorderSide(color: AppColors.cardDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.primary,
          thumbColor: AppColors.primary,
          inactiveTrackColor: AppColors.cardDark,
          overlayColor: Color(0x292DD4BF),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textMutedDark,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.cardDark,
          ),
        ),
      );
}
