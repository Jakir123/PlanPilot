import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kLightPrimary,
  colorScheme: const ColorScheme.light(
    primary: kLightPrimary,
    primaryContainer: kLightPrimaryVariant,
    secondary: kLightSecondary,
    background: kLightBackground,
    surface: kLightSurface,
    onBackground: kLightTextOnBg,
    onSurface: kLightTextOnBg,
  ),
  scaffoldBackgroundColor: kLightBackground,
  cardColor: kLightSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: kLightPrimaryVariant,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kLightTextOnBg),
    bodyMedium: TextStyle(color: kLightTextOnBg),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kDarkPrimary,
  colorScheme: const ColorScheme.dark(
    primary: kDarkPrimary,
    primaryContainer: kDarkPrimaryVariant,
    secondary: kDarkSecondary,
    background: kDarkBackground,
    surface: kDarkSurface,
    onBackground: kDarkTextOnBg,
    onSurface: kDarkTextOnBg,
  ),
  scaffoldBackgroundColor: kDarkBackground,
  cardColor: kDarkSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkPrimaryVariant,
    foregroundColor: kDarkTextOnBg,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kDarkTextOnBg),
    bodyMedium: TextStyle(color: kDarkTextOnBg),
  ),
);
