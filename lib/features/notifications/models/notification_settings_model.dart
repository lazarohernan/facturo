import 'dart:convert';

/// Modelo para configuración de notificaciones push
class NotificationSettings {
  // Notificaciones Push (requieren permiso)
  final bool pushEnabled;
  
  // Resumen semanal
  final bool weeklyDigestEnabled;

  // Configuración de resumen semanal
  final int weeklyDigestDay; // 1 = Lunes, 7 = Domingo
  final int weeklyDigestHour; // 0-23

  const NotificationSettings({
    this.pushEnabled = false,
    this.weeklyDigestEnabled = true,
    this.weeklyDigestDay = 1, // Lunes por defecto
    this.weeklyDigestHour = 9, // 9 AM por defecto
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? weeklyDigestEnabled,
    int? weeklyDigestDay,
    int? weeklyDigestHour,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      weeklyDigestDay: weeklyDigestDay ?? this.weeklyDigestDay,
      weeklyDigestHour: weeklyDigestHour ?? this.weeklyDigestHour,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'weeklyDigestEnabled': weeklyDigestEnabled,
      'weeklyDigestDay': weeklyDigestDay,
      'weeklyDigestHour': weeklyDigestHour,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? false,
      weeklyDigestEnabled: json['weeklyDigestEnabled'] ?? true,
      weeklyDigestDay: json['weeklyDigestDay'] ?? 1,
      weeklyDigestHour: json['weeklyDigestHour'] ?? 9,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory NotificationSettings.fromJsonString(String jsonString) {
    return NotificationSettings.fromJson(jsonDecode(jsonString));
  }
}
