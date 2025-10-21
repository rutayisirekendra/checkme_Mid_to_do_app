import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../models/user.dart'; // unused
import '../../services/database_service.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  Future<void> initializeTheme() async {
    final user = DatabaseService.getCurrentUser();
    if (user != null) {
      state = user.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final user = DatabaseService.getCurrentUser();
    if (user != null) {
      final newThemeMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      state = newThemeMode;
      
      // Update user's theme preference
      final updatedUser = user.copyWith(isDarkMode: newThemeMode == ThemeMode.dark);
      await DatabaseService.saveUser(updatedUser);
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    final user = DatabaseService.getCurrentUser();
    if (user != null) {
      state = themeMode;
      
      // Update user's theme preference
      final updatedUser = user.copyWith(isDarkMode: themeMode == ThemeMode.dark);
      await DatabaseService.saveUser(updatedUser);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
