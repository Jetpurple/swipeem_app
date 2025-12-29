import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme createTextTheme(
    TextTheme base,
    Color textColor,
  ) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontFamily: 'SF Pro Display', // iOS system font
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        fontFamily: 'SF Pro Display',
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
        fontFamily: 'SF Pro Display',
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: textColor,
        letterSpacing: 0.5,
        fontFamily: 'SF Pro Text',
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
        fontFamily: 'SF Pro Text',
      ),
    );
  }
}
