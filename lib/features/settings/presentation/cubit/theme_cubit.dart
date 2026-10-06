import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode';
  int _revision = 0;

  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final revision = _revision;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (isClosed || revision != _revision) return;
      final saved = prefs.get(_key);
      switch (saved) {
        case 'dark':
          emit(ThemeMode.dark);
        case 'light':
          emit(ThemeMode.light);
        default:
          emit(ThemeMode.system);
      }
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _revision++;
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  Future<void> setDark() async {
    await setMode(ThemeMode.dark);
  }

  Future<void> setLight() async {
    await setMode(ThemeMode.light);
  }

  Future<void> setSystem() => setMode(ThemeMode.system);

  Future<void> toggle() async {
    if (state == ThemeMode.dark) {
      await setLight();
    } else {
      await setDark();
    }
  }
}
