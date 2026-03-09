import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_settings_service.dart';

/// Provider para el servicio de configuración de notificaciones
final notificationSettingsServiceProvider = Provider<NotificationSettingsService>((ref) {
  return NotificationSettingsService();
});

/// Estado de las configuraciones de notificaciones
class NotificationSettingsState {
  final bool isLoading;
  final NotificationSettings? settings;
  final String? error;

  const NotificationSettingsState({
    this.isLoading = false,
    this.settings,
    this.error,
  });

  NotificationSettingsState copyWith({
    bool? isLoading,
    NotificationSettings? settings,
    String? error,
  }) {
    return NotificationSettingsState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      error: error ?? this.error,
    );
  }
}

/// Provider para el estado de las configuraciones de notificaciones
class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  final NotificationSettingsService _service;
  
  NotificationSettingsNotifier(this._service) : super(const NotificationSettingsState()) {
    _loadSettings();
  }

  /// Carga las configuraciones de notificaciones
  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final settings = await _service.getNotificationSettings();
      state = state.copyWith(
        isLoading: false,
        settings: settings,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Recarga las configuraciones
  Future<void> refresh() async {
    await _loadSettings();
  }

  /// Habilita o deshabilita notificaciones push
  Future<void> setPushEnabled(bool enabled) async {
    try {
      final updatedSettings = await _service.setPushEnabled(enabled);
      state = state.copyWith(settings: updatedSettings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Habilita o deshabilita resumen semanal
  Future<void> setWeeklyDigestEnabled(bool enabled) async {
    try {
      final updatedSettings = await _service.setWeeklyDigestEnabled(enabled);
      state = state.copyWith(settings: updatedSettings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Actualiza el día del resumen semanal
  Future<void> setWeeklyDigestDay(int day) async {
    try {
      final currentSettings = state.settings;
      if (currentSettings != null) {
        final updatedSettings = await _service.setWeeklyDigestSchedule(day, currentSettings.weeklyDigestHour);
        state = state.copyWith(settings: updatedSettings);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Actualiza la hora del resumen semanal
  Future<void> setWeeklyDigestHour(int hour) async {
    try {
      final currentSettings = state.settings;
      if (currentSettings != null) {
        final updatedSettings = await _service.setWeeklyDigestSchedule(currentSettings.weeklyDigestDay, hour);
        state = state.copyWith(settings: updatedSettings);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Configura el día y hora del resumen semanal
  Future<void> setWeeklyDigestSchedule(int day, int hour) async {
    try {
      final updatedSettings = await _service.setWeeklyDigestSchedule(day, hour);
      state = state.copyWith(settings: updatedSettings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Envía una notificación de prueba
  Future<void> sendTestNotification() async {
    try {
      await _service.sendTestNotification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider para el notifier de configuraciones de notificaciones
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  final service = ref.watch(notificationSettingsServiceProvider);
  return NotificationSettingsNotifier(service);
});

/// Provider para obtener las configuraciones actuales
final currentNotificationSettingsProvider = Provider<NotificationSettings?>((ref) {
  return ref.watch(notificationSettingsProvider).settings;
});
