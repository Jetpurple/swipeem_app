import 'package:flutter/material.dart';

// Dark blue theme matching the mockups
const primaryBlue = Color(0xFF1A1A3D);
const accentBlue = Color(0xFF5271FF);
const lightBlue = Color(0xFF4A90E2);

ColorScheme buildLightScheme() => ColorScheme.fromSeed(
  seedColor: accentBlue,
  primary: accentBlue,
  secondary: lightBlue,
  surface: Colors.white,
  background: Colors.white,
);

ColorScheme buildDarkScheme() => ColorScheme.fromSeed(
  seedColor: accentBlue,
  brightness: Brightness.dark,
  primary: accentBlue,
  secondary: lightBlue,
  surface: primaryBlue,
  background: primaryBlue,
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: Colors.white,
  onBackground: Colors.white,
  onError: Colors.white,
  error: Colors.red,
);
