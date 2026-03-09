import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';

/// Estado para las notificaciones
class NotificationsState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Obtiene el número de notificaciones no leídas
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

/// Notifier para gestionar el estado de las notificaciones
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsService _service;

  NotificationsNotifier(this._service) : super(NotificationsState()) {
    loadNotifications();
  }

  /// Carga todas las notificaciones
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await _service.getNotifications();
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      final updatedNotifications = state.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _service.deleteNotification(notificationId);
      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Elimina todas las notificaciones
  Future<void> clearAll() async {
    try {
      await _service.clearAllNotifications();
      state = state.copyWith(notifications: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Agrega una nueva notificación
  Future<void> addNotification(AppNotification notification) async {
    try {
      await _service.addNotification(notification);
      final updatedNotifications = [notification, ...state.notifications];
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Provider del servicio de notificaciones
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(Supabase.instance.client);
});

/// Provider principal de notificaciones
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final service = ref.watch(notificationsServiceProvider);
  return NotificationsNotifier(service);
});

/// Provider para el conteo de notificaciones no leídas
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsProvider);
  return state.unreadCount;
});
