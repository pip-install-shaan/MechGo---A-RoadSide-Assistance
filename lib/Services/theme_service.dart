// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeService {
//   ThemeService._();

//   static final ThemeService instance =
//       ThemeService._();

//   final ValueNotifier<bool> isDark =
//       ValueNotifier<bool>(false);

//   static const String _darkModeKey =
//       'dark_mode';

//   Future<void> loadTheme() async {
//     final prefs =
//         await SharedPreferences.getInstance();

//     isDark.value =
//         prefs.getBool(_darkModeKey) ?? false;
//   }

//   Future<void> setDarkMode(
//     bool value,
//   ) async {
//     isDark.value = value;

//     final prefs =
//         await SharedPreferences.getInstance();

//     await prefs.setBool(
//       _darkModeKey,
//       value,
//     );
//   }

//   Future<void> toggle() async {
//     await setDarkMode(
//       !isDark.value,
//     );
//   }
// }