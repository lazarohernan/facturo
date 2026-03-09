import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el último método de login utilizado
class LastLoginMethodService {
  static const String _lastLoginMethodKey = 'last_login_method';
  
  /// Métodos de login disponibles
  static const String email = 'email';
  static const String google = 'google';
  static const String apple = 'apple';

  /// Guardar el último método de login utilizado
  static Future<void> saveLastLoginMethod(String method) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLoginMethodKey, method);
    } catch (e) {
      // Silenciar errores para no interrumpir el flujo de login
      debugPrint('Error saving last login method: $e');
    }
  }

  /// Obtener el último método de login utilizado
  static Future<String?> getLastLoginMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastLoginMethodKey);
    } catch (e) {
      // Silenciar errores para no interrumpir el flujo de login
      debugPrint('Error getting last login method: $e');
      return null;
    }
  }

  /// Verificar si un método específico fue el último utilizado
  static Future<bool> isLastUsedMethod(String method) async {
    final lastMethod = await getLastLoginMethod();
    return lastMethod == method;
  }

  /// Limpiar el último método de login
  static Future<void> clearLastLoginMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastLoginMethodKey);
    } catch (e) {
      // Silenciar errores para no interrumpir el flujo de login
      debugPrint('Error clearing last login method: $e');
    }
  }

  /// Obtener el nombre legible del método para mostrar en UI
  static String getMethodDisplayName(String method) {
    switch (method) {
      case email:
        return 'Email';
      case google:
        return 'Google';
      case apple:
        return 'Apple';
      default:
        return method;
    }
  }
}
