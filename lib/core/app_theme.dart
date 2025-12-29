import 'package:flutter/material.dart';
import 'package:hire_me/core/theme/app_dimens.dart';
import 'package:hire_me/core/theme/app_typography.dart';
import 'package:hire_me/core/theme/color_schemes.dart';

ThemeData buildLightTheme() {
  final colorScheme = buildLightScheme();
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: AppTypography.createTextTheme(
      ThemeData.light().textTheme,
      colorScheme.onSurface,
    ),
    useMaterial3: true,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    extensions: const <ThemeExtension<dynamic>>[AppDimens.defaults],
  );
}

ThemeData buildDarkTheme() {
  final colorScheme = buildDarkScheme();
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: AppTypography.createTextTheme(
      ThemeData.dark().textTheme,
      Colors.white, // Forcer le texte en blanc
    ),
    useMaterial3: true,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: Colors.white, // Texte de l'AppBar en blanc
      elevation: 0,
      centerTitle: true,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 2,
    ),
    extensions: const <ThemeExtension<dynamic>>[AppDimens.defaults],
  );
}
