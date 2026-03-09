import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_notification_service.dart';
import '../models/notification_settings_model.dart';

/// Provider para el servicio de notificaciones Firebase
final firebaseNotificationServiceProvider = Provider<FirebaseNotificationService>((ref) {
  return FirebaseNotificationService();
});

/// Provider para el estado de las notificaciones Firebase
class FirebaseNotificationNotifier extends StateNotifier<FirebaseNotificationState> {
  final FirebaseNotificationService _service;
  final SharedPreferences _prefs;
  
  FirebaseNotificationNotifier(this._service, this._prefs) : super(const FirebaseNotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = const FirebaseNotificationState(isLoading: true);
    
    try {
      await _service.initialize();
      
      final token = _service.fcmToken;
      final hasPermissions = await _checkPermissions();
      
      state = FirebaseNotificationState(
        isLoading: false,
        isInitialized: _service.isInitialized,
        fcmToken: token,
        hasPermissions: hasPermissions,
      );
    } catch (e) {
      state = FirebaseNotificationState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> _checkPermissions() async {
    // Para verificar permisos actuales, intentamos solicitarlos
    // y verificamos el resultado
    return true; // Simplificado por ahora
  }

  /// Solicita permisos de notificación
  Future<bool> requestPermissions() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final hasPermissions = await _service.requestPermissions();
      
      state = state.copyWith(
        isLoading: false,
        hasPermissions: hasPermissions,
      );
      
      return hasPermissions;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Programa el resumen semanal
  Future<void> scheduleWeeklySummary(NotificationSettings settings, String userId) async {
    if (!settings.pushEnabled || !settings.weeklyDigestEnabled) return;
    
    try {
      await _service.scheduleWeeklySummary(
        dayOfWeek: settings.weeklyDigestDay,
        hour: settings.weeklyDigestHour,
        userId: userId,
      );
      
      // Guardar que está programado
      await _prefs.setBool('weekly_summary_scheduled', true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Cancela el resumen semanal
  Future<void> cancelWeeklySummary(String userId) async {
    try {
      await _service.cancelWeeklySummary(userId);
      
      // Guardar que está cancelado
      await _prefs.setBool('weekly_summary_scheduled', false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Envía notificación de prueba
  Future<void> sendTestNotification() async {
    try {
      await _service.sendTestNotification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Limpia errores
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Estado de las notificaciones Firebase
class FirebaseNotificationState {
  final bool isLoading;
  final bool isInitialized;
  final String? fcmToken;
  final bool hasPermissions;
  final String? error;

  const FirebaseNotificationState({
    this.isLoading = false,
    this.isInitialized = false,
    this.fcmToken,
    this.hasPermissions = false,
    this.error,
  });

  FirebaseNotificationState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? fcmToken,
    bool? hasPermissions,
    String? error,
  }) {
    return FirebaseNotificationState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      fcmToken: fcmToken ?? this.fcmToken,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirebaseNotificationState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isInitialized == other.isInitialized &&
          fcmToken == other.fcmToken &&
          hasPermissions == other.hasPermissions &&
          error == other.error;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      isInitialized.hashCode ^
      fcmToken.hashCode ^
      hasPermissions.hashCode ^
      error.hashCode;
}

/// Provider principal de notificaciones Firebase
final firebaseNotificationProvider = StateNotifierProvider<FirebaseNotificationNotifier, FirebaseNotificationState>((ref) {
  // Note: firebaseNotificationServiceProvider is available but SharedPreferences needs to be provided
  // SharedPreferences should be obtained safely before using this provider
  throw UnimplementedError('SharedPreferences needs to be provided');
});
