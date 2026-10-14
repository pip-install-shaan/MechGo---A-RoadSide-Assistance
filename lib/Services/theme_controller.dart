import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static final ThemeController instance =
      ThemeController._();

  static const String _darkModeKey = 'dark_mode';

  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  // ----------------------------------------------------------
  // LOAD SAVED THEME
  // ----------------------------------------------------------

  Future<void> loadTheme() async {
    final preferences =
        await SharedPreferences.getInstance();

    final isDark =
        preferences.getBool(_darkModeKey) ?? false;

    themeMode.value = isDark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // ----------------------------------------------------------
  // TOGGLE THEME
  // ----------------------------------------------------------

  Future<void> toggleTheme() async {
    final isDark =
        themeMode.value == ThemeMode.dark;

    final newMode = isDark
        ? ThemeMode.light
        : ThemeMode.dark;

    themeMode.value = newMode;

    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setBool(
      _darkModeKey,
      newMode == ThemeMode.dark,
    );
  }

  // ----------------------------------------------------------
  // CHECK DARK MODE
  // ----------------------------------------------------------

  bool get isDark =>
      themeMode.value == ThemeMode.dark;
}