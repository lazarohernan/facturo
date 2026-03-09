import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facturo/features/settings/models/app_settings_model.dart';

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  static const String _settingsKey = 'app_settings';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        state = AppSettings.fromJson(settingsMap);
      }
    } catch (e) {
      // If there's an error loading settings, keep default values
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(state.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  Future<void> updateDateFormat(String dateFormat) async {
    state = state.copyWith(dateFormat: dateFormat);
    await _saveSettings();
  }

  Future<void> updateCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    await _saveSettings();
  }

  Future<void> updateTimeZone(String timeZone) async {
    state = state.copyWith(timeZone: timeZone);
    await _saveSettings();
  }

  Future<void> updateAllSettings({
    String? language,
    String? dateFormat,
    String? currency,
    String? timeZone,
  }) async {
    state = state.copyWith(
      language: language ?? state.language,
      dateFormat: dateFormat ?? state.dateFormat,
      currency: currency ?? state.currency,
      timeZone: timeZone ?? state.timeZone,
    );
    await _saveSettings();
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
