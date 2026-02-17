import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/local_storage_service.dart';

/// Theme mode preference key in local storage
const String _themePreferenceKey = 'theme_mode';

/// Theme state
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.system});

  /// Whether the theme is currently in system mode
  bool get isSystemMode => themeMode == ThemeMode.system;

  /// Whether the theme is currently in dark mode (explicit)
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// Whether the theme is currently in light mode (explicit)
  bool get isLightMode => themeMode == ThemeMode.light;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => [themeMode];
}

/// Theme cubit for managing light/dark/system theme mode
class ThemeCubit extends Cubit<ThemeState> {
  final LocalStorageService _storage;

  ThemeCubit({required LocalStorageService storage})
      : _storage = storage,
        super(const ThemeState()) {
    _loadThemePreference();
  }

  /// Load saved theme preference from local storage
  void _loadThemePreference() {
    final saved = _storage.getSetting<String>(_themePreferenceKey);
    if (saved != null) {
      final mode = _themeModeFromString(saved);
      emit(ThemeState(themeMode: mode));
    }
  }

  /// Set theme mode and persist to local storage
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(ThemeState(themeMode: mode));
    await _storage.saveSetting(_themePreferenceKey, _themeModeToString(mode));
  }

  /// Toggle between light and dark mode (skips system)
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Cycle through: system → light → dark → system
  Future<void> cycleThemeMode() async {
    final ThemeMode newMode;
    switch (state.themeMode) {
      case ThemeMode.system:
        newMode = ThemeMode.light;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
    }
    await setThemeMode(newMode);
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}
