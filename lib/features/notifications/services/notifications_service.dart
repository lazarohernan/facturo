import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

/// Servicio para gestionar las notificaciones de la app usando Supabase
class NotificationsService {
  final SupabaseClient _supabase;

  NotificationsService(this._supabase);

  /// Mapea el tipo de notificación de la base de datos al enum
  NotificationType _mapNotificationType(String? type) {
    switch (type) {
      case 'invoice':
        return NotificationType.invoice;
      case 'estimate':
        return NotificationType.estimate;
      case 'expense':
        return NotificationType.expense;
      case 'payment':
        return NotificationType.payment;
      case 'subscription':
        return NotificationType.subscription;
      case 'reminder':
        return NotificationType.reminder;
      case 'test_notification':
      case 'backend_test':
      case 'general':
      default:
        return NotificationType.system;
    }
  }

  /// Obtiene todas las notificaciones almacenadas desde Supabase
  Future<List<AppNotification>> getNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }

      final response = await _supabase
          .from('notifications_history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(100);

      return (response as List).map((json) {
        return AppNotification(
          id: json['id'] as String,
          title: json['title'] as String,
          message: json['body'] as String,
          type: _mapNotificationType(json['notification_type'] as String?),
          createdAt: DateTime.parse(json['created_at'] as String),
          isRead: json['is_read'] as bool? ?? false,
          actionUrl: json['data']?['action_url'] as String?,
          metadata: json['data'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading notifications from Supabase: $e');
      return [];
    }
  }

  /// Agrega una nueva notificación (solo para uso local/testing)
  Future<void> addNotification(AppNotification notification) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await _supabase.from('notifications_history').insert({
        'user_id': user.id,
        'title': notification.title,
        'body': notification.message,
        'data': notification.metadata ?? {},
        'notification_type': notification.type.name,
        'is_read': notification.isRead,
      });
    } catch (e) {
      debugPrint('Error adding notification to Supabase: $e');
      rethrow;
    }
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await _supabase
          .from('notifications_history')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await _supabase
          .from('notifications_history')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Elimina una notificación específica
  Future<void> deleteNotification(String notificationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await _supabase
          .from('notifications_history')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Elimina todas las notificaciones
  Future<void> clearAllNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await _supabase
          .from('notifications_history')
          .delete()
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
      rethrow;
    }
  }

  /// Obtiene el conteo de notificaciones no leídas
  Future<int> getUnreadCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 0;
      }

      final response = await _supabase
          .from('notifications_history')
          .select('*')
          .eq('user_id', user.id)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Stream de notificaciones en tiempo real
  Stream<List<AppNotification>> watchNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('notifications_history')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) {
              return AppNotification(
                id: json['id'] as String,
                title: json['title'] as String,
                message: json['body'] as String,
                type: _mapNotificationType(json['notification_type'] as String?),
                createdAt: DateTime.parse(json['created_at'] as String),
                isRead: json['is_read'] as bool? ?? false,
                actionUrl: json['data']?['action_url'] as String?,
                metadata: json['data'] as Map<String, dynamic>?,
              );
            }).toList());
  }
}
