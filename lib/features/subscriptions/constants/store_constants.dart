class StoreConstants {
  // IDs de producto para iOS
  static const String monthlyProductIdIOS = 'facturo_monthly_subscription';
  static const String annualProductIdIOS = 'facturo_annual_subscription';

  // IDs de producto para Android
  static const String monthlyProductIdAndroid = 'facturo.monthly.subscription';
  static const String annualProductIdAndroid = 'facturo.annual.subscription';

  // Keys para almacenamiento local
  static const String activeSubscriptionKey = 'active_subscription';

  // Timeouts
  static const Duration productQueryTimeout = Duration(seconds: 10);
} 