import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData light() {
    const primary = Color(0xFF14B88F);
    const background = Color(0xFFF4FBF7);
    const textPrimary = Color(0xFF0F172A);
    const textSecondary = Color(0xFF64748B);
    const border = Color(0xFFD7EDE4);
    const buttonRadius = 14.0;
    const buttonMinHeight = 48.0;
    const buttonVerticalPadding = 14.0;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(0, buttonMinHeight.h),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: buttonVerticalPadding.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius.r),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, buttonMinHeight.h),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: buttonVerticalPadding.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius.r),
          ),
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: textPrimary, displayColor: textPrimary)
          .copyWith(
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              color: textSecondary,
            ),
          ),
    );
  }
}
