import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _darkModeKey = 'dark_mode';

  Locale _locale = const Locale('en');
  bool _isDarkMode = false;
  late SharedPreferences _prefs;

  Locale get locale => _locale;
  bool get isDarkMode => _isDarkMode;

  LocaleProvider() {
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Load saved locale
    final savedLocale = _prefs.getString(_localeKey) ?? 'en';
    _locale = Locale(savedLocale);

    // Load saved dark mode preference
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;

    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);
    await _prefs.setString(_localeKey, languageCode);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool(_darkModeKey, isDark);
    notifyListeners();
  }
}
