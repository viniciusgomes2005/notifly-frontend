import 'package:flutter/material.dart';
import 'package:notifly_frontend/colors.dart';

final ThemeData nflyLightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: lightBg,
  appBarTheme: const AppBarTheme(
    backgroundColor: lightPurple,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: lightPurple,
    brightness: Brightness.light,
    primary: lightPurple,
    secondary: mutedPurple,
    error: strongRed,
    surface: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);

final ThemeData nflyDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBg,
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBg,
    foregroundColor: pastelPurple,
    elevation: 0,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: pastelPurple,
    brightness: Brightness.dark,
    primary: pastelPurple,
    secondary: pastelPink,
    error: strongRed,
    surface: darkBg,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: pastelPurple,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);
