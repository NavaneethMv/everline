import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeString = prefs.getString('themeMode') ?? 'system';
    final startupPage = prefs.getString('startupPage') ?? '/home';

    final themeMode = switch (themeModeString) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    emit(SettingsLoaded(themeMode: themeMode, startupPage: startupPage));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state is SettingsLoaded) {
      final prefs = await SharedPreferences.getInstance();
      final modeString = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

      await prefs.setString('themeMode', modeString);

      emit((state as SettingsLoaded).copyWith(themeMode: mode));
    }
  }

  Future<void> setStartupPage(String page) async {
    if (state is SettingsLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('startupPage', page);

      emit((state as SettingsLoaded).copyWith(startupPage: page));
    }
  }
}
