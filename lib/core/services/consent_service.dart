import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para gestionar el registro de consentimiento de usuarios
/// Cumple con requisitos GDPR y CCPA para auditoría y cumplimiento legal
class ConsentService {
  static final ConsentService _instance = ConsentService._internal();
  factory ConsentService() => _instance;
  ConsentService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Registra el consentimiento del usuario para términos y condiciones
  /// 
  /// [userId] - ID del usuario que acepta
  /// [consentType] - Tipo de consentimiento ('terms', 'privacy', 'cookies', 'marketing')
  /// [action] - Acción realizada ('accepted', 'rejected', 'withdrawn')
  /// [version] - Versión de las políticas aceptadas
  /// [platform] - Plataforma desde donde acepta ('ios', 'android', 'web')
  /// [appVersion] - Versión de la app
  Future<Map<String, dynamic>> recordConsent({
    required String userId,
    required String consentType,
    required String action,
    String? version,
    String? platform,
    String? appVersion,
  }) async {
    try {
      final response = await _supabase.from('user_consent_logs').insert({
        'user_id': userId,
        'consent_type': consentType,
        'action': action,
        'consent_version': version ?? '1.0',
        'platform': platform ?? _getPlatform(),
        'app_version': appVersion ?? _getAppVersion(),
        'ip_address': await _getIpAddress(),
        'user_agent': _getUserAgent(),
      }).select();

      return {
        'success': true,
        'data': response,
        'message': 'Consentimiento registrado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al registrar consentimiento',
      };
    }
  }

  /// Registra aceptación de términos y condiciones
  Future<Map<String, dynamic>> acceptTerms({
    required String userId,
    String? platform,
    String? appVersion,
  }) async {
    return await recordConsent(
      userId: userId,
      consentType: 'terms',
      action: 'accepted',
      version: '1.0',
      platform: platform,
      appVersion: appVersion,
    );
  }

  /// Registra aceptación de política de privacidad
  Future<Map<String, dynamic>> acceptPrivacy({
    required String userId,
    String? platform,
    String? appVersion,
  }) async {
    return await recordConsent(
      userId: userId,
      consentType: 'privacy',
      action: 'accepted',
      version: '1.0',
      platform: platform,
      appVersion: appVersion,
    );
  }

  /// Registra ambos consentimientos (términos y privacidad) simultáneamente
  Future<Map<String, dynamic>> acceptAllPolicies({
    required String userId,
    String? platform,
    String? appVersion,
  }) async {
    try {
      final termsResult = await acceptTerms(
        userId: userId,
        platform: platform,
        appVersion: appVersion,
      );

      final privacyResult = await acceptPrivacy(
        userId: userId,
        platform: platform,
        appVersion: appVersion,
      );

      final success = (termsResult['success'] as bool? ?? false) &&
                     (privacyResult['success'] as bool? ?? false);

      return {
        'success': success,
        'terms': termsResult,
        'privacy': privacyResult,
        'message': success 
            ? 'Todos los consentimientos registrados exitosamente'
            : 'Error al registrar consentimientos',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al registrar consentimientos',
      };
    }
  }

  /// Obtiene el historial de consentimiento de un usuario
  Future<List<Map<String, dynamic>>> getUserConsentHistory(String userId) async {
    try {
      final response = await _supabase
          .from('user_consent_logs')
          .select()
          .eq('user_id', userId)
          .order('consent_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Verifica si el usuario ha aceptado los términos más recientes
  Future<bool> hasAcceptedLatestTerms(String userId, {String version = '1.0'}) async {
    try {
      final response = await _supabase
          .from('user_consent_logs')
          .select()
          .eq('user_id', userId)
          .eq('consent_type', 'terms')
          .eq('action', 'accepted')
          .eq('consent_version', version)
          .order('consent_date', ascending: false)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si el usuario ha aceptado la política de privacidad más reciente
  Future<bool> hasAcceptedLatestPrivacy(String userId, {String version = '1.0'}) async {
    try {
      final response = await _supabase
          .from('user_consent_logs')
          .select()
          .eq('user_id', userId)
          .eq('consent_type', 'privacy')
          .eq('action', 'accepted')
          .eq('consent_version', version)
          .order('consent_date', ascending: false)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la plataforma actual
  String _getPlatform() {
    // Implementar lógica para detectar plataforma
    // Por ahora retornamos un valor por defecto
    return 'unknown';
  }

  /// Obtiene la versión de la app
  String _getAppVersion() {
    // Implementar lógica para obtener versión de la app
    // Por ahora retornamos un valor por defecto
    return '1.0.0';
  }

  /// Obtiene la dirección IP del usuario
  Future<String?> _getIpAddress() async {
    try {
      // Implementar lógica para obtener IP real
      // Por ahora retornamos null
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el user agent del navegador/dispositivo
  String _getUserAgent() {
    try {
      // Implementar lógica para obtener user agent
      // Por ahora retornamos un valor por defecto
      return 'Facturo App';
    } catch (e) {
      return 'Unknown';
    }
  }
}
