import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ThemeMode.system);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(ThemeMode initialTheme) : super(initialTheme);

  void setLight() {
    state = ThemeMode.light;
  }

  void setDark() {
    state = ThemeMode.dark;
  }

  void setSystem() {
    state = ThemeMode.system;
  }

  bool isDark(BuildContext context) {
    return state == ThemeMode.dark ||
        (state == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
  }
}
