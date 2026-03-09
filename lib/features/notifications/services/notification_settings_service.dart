import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Modelo para configuración de notificaciones de usuario
class NotificationSettings {
  final String id;
  final String userId;
  final bool pushEnabled;
  final bool weeklyDigestEnabled;
  final int weeklyDigestDay; // 1-7 (Lunes-Domingo)
  final int weeklyDigestHour; // 0-23
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationSettings({
    required this.id,
    required this.userId,
    required this.pushEnabled,
    required this.weeklyDigestEnabled,
    required this.weeklyDigestDay,
    required this.weeklyDigestHour,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pushEnabled: json['push_enabled'] as bool? ?? false,
      weeklyDigestEnabled: json['weekly_digest_enabled'] as bool? ?? false,
      weeklyDigestDay: json['weekly_digest_day'] as int? ?? 1,
      weeklyDigestHour: json['weekly_digest_hour'] as int? ?? 9,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'push_enabled': pushEnabled,
      'weekly_digest_enabled': weeklyDigestEnabled,
      'weekly_digest_day': weeklyDigestDay,
      'weekly_digest_hour': weeklyDigestHour,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationSettings copyWith({
    String? id,
    String? userId,
    bool? pushEnabled,
    bool? weeklyDigestEnabled,
    int? weeklyDigestDay,
    int? weeklyDigestHour,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      weeklyDigestDay: weeklyDigestDay ?? this.weeklyDigestDay,
      weeklyDigestHour: weeklyDigestHour ?? this.weeklyDigestHour,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Obtiene el nombre del día de la semana
  String get weeklyDigestDayName {
    const days = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weeklyDigestDay];
  }

  /// Obtiene la hora formateada
  String get weeklyDigestTime {
    return '${weeklyDigestHour.toString().padLeft(2, '0')}:00';
  }
}

/// Servicio para manejar configuraciones de notificaciones en Supabase
class NotificationSettingsService {
  static final NotificationSettingsService _instance = NotificationSettingsService._internal();
  factory NotificationSettingsService() => _instance;
  NotificationSettingsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene la configuración de notificaciones del usuario actual
  Future<NotificationSettings?> getNotificationSettings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase
          .from('user_notification_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        // Crear configuración por defecto si no existe
        return await createDefaultSettings();
      }

      return NotificationSettings.fromJson(response);
    } catch (e) {
      throw Exception('Error obteniendo configuración de notificaciones: $e');
    }
  }

  /// Crea configuración por defecto para el usuario
  Future<NotificationSettings> createDefaultSettings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // 🎯 Verificar si el usuario ya concedió permisos de notificación
      // Si ya concedió permisos, activar notificaciones por defecto
      bool pushEnabledByDefault = false;
      try {
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.getNotificationSettings();
        pushEnabledByDefault = settings.authorizationStatus == AuthorizationStatus.authorized;
        debugPrint('📱 Estado de permisos para configuración por defecto: ${settings.authorizationStatus}');
        debugPrint('🔔 Push enabled por defecto: $pushEnabledByDefault');
      } catch (e) {
        debugPrint('⚠️ No se pudo verificar permisos de notificación: $e');
      }

      final defaultSettings = {
        'user_id': user.id,
        'push_enabled': pushEnabledByDefault, // 🎯 Activado si ya hay permisos
        'weekly_digest_enabled': false,
        'weekly_digest_day': 1, // Lunes
        'weekly_digest_hour': 9, // 9 AM
      };

      final response = await _supabase
          .from('user_notification_settings')
          .insert(defaultSettings)
          .select()
          .single();

      return NotificationSettings.fromJson(response);
    } catch (e) {
      throw Exception('Error creando configuración por defecto: $e');
    }
  }

  /// Actualiza la configuración de notificaciones
  Future<NotificationSettings> updateNotificationSettings({
    bool? pushEnabled,
    bool? weeklyDigestEnabled,
    int? weeklyDigestDay,
    int? weeklyDigestHour,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final updateData = <String, dynamic>{};
      if (pushEnabled != null) updateData['push_enabled'] = pushEnabled;
      if (weeklyDigestEnabled != null) updateData['weekly_digest_enabled'] = weeklyDigestEnabled;
      if (weeklyDigestDay != null) updateData['weekly_digest_day'] = weeklyDigestDay;
      if (weeklyDigestHour != null) updateData['weekly_digest_hour'] = weeklyDigestHour;

      final response = await _supabase
          .from('user_notification_settings')
          .update(updateData)
          .eq('user_id', user.id)
          .select()
          .single();

      return NotificationSettings.fromJson(response);
    } catch (e) {
      throw Exception('Error actualizando configuración de notificaciones: $e');
    }
  }

  /// Habilita o deshabilita notificaciones push
  Future<NotificationSettings> setPushEnabled(bool enabled) async {
    return await updateNotificationSettings(pushEnabled: enabled);
  }

  /// Habilita o deshabilita resumen semanal
  Future<NotificationSettings> setWeeklyDigestEnabled(bool enabled) async {
    return await updateNotificationSettings(weeklyDigestEnabled: enabled);
  }

  /// Configura el día y hora del resumen semanal
  Future<NotificationSettings> setWeeklyDigestSchedule(int day, int hour) async {
    return await updateNotificationSettings(
      weeklyDigestDay: day,
      weeklyDigestHour: hour,
    );
  }

  /// Envía una notificación de prueba usando la Edge Function
  Future<void> sendTestNotification() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase.functions.invoke(
        'send-notification',
        body: {
          'type': 'specific_users',
          'userIds': [user.id],
          'notification': {
            'title': '🔔 Notificación de Prueba',
            'body': '¡Las notificaciones push están funcionando correctamente!',
            'data': {
              'type': 'test_notification',
              'timestamp': DateTime.now().toIso8601String(),
            }
          }
        },
      );

      if (response.status != 200) {
        throw Exception('Error enviando notificación de prueba: ${response.data}');
      }

      debugPrint('✅ Notificación de prueba enviada exitosamente');
    } catch (e) {
      throw Exception('Error enviando notificación de prueba: $e');
    }
  }

  /// Envía resumen semanal a todos los usuarios configurados
  Future<void> sendWeeklySummary() async {
    try {
      final response = await _supabase.functions.invoke(
        'send-notification',
        body: {
          'type': 'weekly_summary',
          'notification': {
            'title': '📊 Resumen Semanal',
            'body': 'Tu resumen de actividad semanal está listo para revisar.',
            'data': {
              'type': 'weekly_summary',
              'week_start': DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T')[0],
              'week_end': DateTime.now().toIso8601String().split('T')[0],
            }
          }
        },
      );

      if (response.status != 200) {
        throw Exception('Error enviando resumen semanal: ${response.data}');
      }

      debugPrint('✅ Resumen semanal enviado exitosamente');
    } catch (e) {
      throw Exception('Error enviando resumen semanal: $e');
    }
  }
}
