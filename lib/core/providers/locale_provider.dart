import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facturo/core/providers/shared_preferences_provider.dart';
import 'dart:ui' as ui;

// Provider for locale management
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(sharedPreferences);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;
  static const String _localeKey = 'app_locale';

  LocaleNotifier(this._prefs) : super(_getSystemLocale()) {
    _loadLocale();
  }

  /// Public getter for the current locale
  Locale get currentLocale => state;

  // Get system locale or default to Spanish if not supported
  static Locale _getSystemLocale() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    
    // Check if system locale is supported
    final isSupported = supportedLocales.any(
      (locale) => locale.languageCode == systemLocale.languageCode,
    );
    
    if (isSupported) {
      return Locale(systemLocale.languageCode, '');
    }
    
    // Default to Spanish if system locale is not supported
    return const Locale('es', '');
  }

  void _loadLocale() {
    final savedLocaleCode = _prefs.getString(_localeKey);
    
    if (savedLocaleCode != null) {
      // User has previously selected a language
      state = Locale(savedLocaleCode, '');
    } else {
      // No saved preference, use system locale
      state = _getSystemLocale();
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  // Available locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('es', ''), // Spanish
  ];

  // Get locale display name
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Español';
    }
  }

  // Get current system locale info
  static Locale getSystemLocale() {
    return ui.PlatformDispatcher.instance.locale;
  }
  
  // Check if system locale is supported
  static bool isSystemLocaleSupported() {
    final systemLocale = getSystemLocale();
    return supportedLocales.any(
      (locale) => locale.languageCode == systemLocale.languageCode,
    );
  }
  
  // Reset to system locale
  Future<void> resetToSystemLocale() async {
    final systemLocale = _getSystemLocale();
    await setLocale(systemLocale);
  }
} 