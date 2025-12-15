import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark }

class ThemeState {
  final AppTheme currentTheme;
  final bool isDarkMode;

  const ThemeState({required this.currentTheme, required this.isDarkMode});

  ThemeState copyWith({AppTheme? currentTheme, bool? isDarkMode}) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
    : super(const ThemeState(currentTheme: AppTheme.dark, isDarkMode: true)) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 1; // Default to dark
      state = ThemeState(
        currentTheme: AppTheme.values[themeIndex],
        isDarkMode: themeIndex == 1,
      );
    } catch (e) {
      state = const ThemeState(currentTheme: AppTheme.dark, isDarkMode: true);
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state.currentTheme == AppTheme.dark
        ? AppTheme.light
        : AppTheme.dark;

    state = state.copyWith(
      currentTheme: newTheme,
      isDarkMode: newTheme == AppTheme.dark,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, newTheme.index);
  }

  Future<void> setTheme(AppTheme theme) async {
    state = state.copyWith(
      currentTheme: theme,
      isDarkMode: theme == AppTheme.dark,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
