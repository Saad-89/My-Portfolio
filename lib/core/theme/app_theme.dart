import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: AppFonts.primary,
      scaffoldBackgroundColor: AppColors.pureWhite,
      primaryColor: AppColors.primaryBlack,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: AppFonts.bold,
          color: AppColors.primaryBlack,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: AppFonts.semiBold,
          color: AppColors.primaryBlack,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: AppFonts.semiBold,
          color: AppColors.primaryBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: AppFonts.regular,
          color: AppColors.darkGray,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: AppFonts.regular,
          color: AppColors.darkGray,
          height: 1.5,
        ),
      ),
    );
  }
}
