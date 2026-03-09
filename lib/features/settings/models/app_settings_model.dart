class AppSettings {
  final String language;
  final String dateFormat;
  final String currency;
  final String timeZone;

  const AppSettings({
    this.language = 'en',
    this.dateFormat = 'MM/DD/YYYY',
    this.currency = 'USD',
    this.timeZone = 'UTC-06:00',
  });

  AppSettings copyWith({
    String? language,
    String? dateFormat,
    String? currency,
    String? timeZone,
  }) {
    return AppSettings(
      language: language ?? this.language,
      dateFormat: dateFormat ?? this.dateFormat,
      currency: currency ?? this.currency,
      timeZone: timeZone ?? this.timeZone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'dateFormat': dateFormat,
      'currency': currency,
      'timeZone': timeZone,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] ?? 'en',
      dateFormat: json['dateFormat'] ?? 'MM/DD/YYYY',
      currency: json['currency'] ?? 'USD',
      timeZone: json['timeZone'] ?? 'UTC-06:00',
    );
  }
}
