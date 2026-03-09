import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:facturo/core/providers/supabase_providers.dart';
import 'package:facturo/core/providers/shared_preferences_provider.dart';
import 'package:facturo/features/subscriptions/services/subscription_service.dart';

/// Servicio para manejar la lógica freemium de la aplicación
class FreemiumService {
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;
  final SubscriptionService? _subscriptionService;

  FreemiumService(this._supabase, this._prefs, this._subscriptionService);

  // Variable para saber si hay una compra en proceso
  bool isPurchasing = false;

  // Keys para SharedPreferences
  static const String _kFirstLoginCompleted = 'first_login_completed';
  static const String _kPaywallShownFirstTime = 'paywall_shown_first_time';
  static const String _kOnboardingCompleted = 'onboarding_completed';
  static const String _kUserCreationDate = 'user_creation_date';
  static const String _kLastPaywallShown = 'last_paywall_shown';

  // Configuración de límites freemium - Plan optimizado
  static const int defaultFreeInvoiceLimit = 5; // 5 facturas totales
  static const int defaultFreeClientLimit = 5; // 5 clientes totales
  static const int defaultFreeEstimateLimit = 5; // 5 estimados totales
  static const int defaultFreeOCRLimit = 5; // 5 escaneos de facturas totales
  static const int defaultFreeReportsLimit = 5; // 5 reportes totales

  // Configuración de timing para paywall
  static const Duration paywallCooldown =
      Duration(hours: 24); // No mostrar paywall muy seguido
  static const Duration gracePeriodAfterSignup =
      Duration(days: 1); // Período de gracia después del registro

  /// Verifica si es el primer login del usuario
  Future<bool> isFirstLogin() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    return !(_prefs.getBool('${_kFirstLoginCompleted}_$userId') ?? false);
  }

  /// Marca que el primer login fue completado
  Future<void> markFirstLoginCompleted() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _prefs.setBool('${_kFirstLoginCompleted}_$userId', true);

    // También guardamos la fecha de creación del usuario si no existe
    if (!_prefs.containsKey('${_kUserCreationDate}_$userId')) {
      await _prefs.setString(
          '${_kUserCreationDate}_$userId', DateTime.now().toIso8601String());
    }
  }

  /// Verifica si ya se mostró el paywall en el primer login
  Future<bool> hasShownFirstTimePaywall() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return true;

    return _prefs.getBool('${_kPaywallShownFirstTime}_$userId') ?? false;
  }

  /// Marca que se mostró el paywall por primera vez
  Future<void> markFirstTimePaywallShown() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _prefs.setBool('${_kPaywallShownFirstTime}_$userId', true);
    await _prefs.setString(
        '${_kLastPaywallShown}_$userId', DateTime.now().toIso8601String());
  }

  /// Verifica si el onboarding fue completado
  Future<bool> isOnboardingCompleted() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return true;

    return _prefs.getBool('${_kOnboardingCompleted}_$userId') ?? false;
  }

  /// Marca el onboarding como completado
  Future<void> markOnboardingCompleted() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _prefs.setBool('${_kOnboardingCompleted}_$userId', true);
  }

  /// Verifica si el usuario tiene una suscripción activa
  Future<bool> hasActiveSubscription() async {
    debugPrint('🔍 FreemiumService.hasActiveSubscription: Iniciando verificación...');
    
    if (_subscriptionService == null) {
      debugPrint('❌ FreemiumService: _subscriptionService es null');
      return false;
    }

    try {
      final subscription = await _subscriptionService.getCurrentSubscription();
      debugPrint('📊 FreemiumService: Suscripción obtenida - isActive=${subscription.isActive}');
      return subscription.isActive;
    } catch (e) {
      debugPrint('❌ FreemiumService: Error checking subscription: $e');
      return false;
    }
  }

  /// Obtiene el conteo actual de facturas del usuario
  Future<int> getCurrentInvoiceCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', userId)
          .count();
      //.eq('status', true);

      return response.count;
    } catch (e) {
      debugPrint('Error getting invoice count: $e');
      return 0;
    }
  }

  /// Obtiene el conteo actual de clientes del usuario
  Future<int> getCurrentClientCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('clients')
          .select()
          .eq('user_id', userId)
          .count();
      //.eq('status', true);

      return response.count;
    } catch (e) {
      debugPrint('Error getting client count: $e');
      return 0;
    }
  }

  /// Verifica si el usuario puede crear una nueva factura
  Future<bool> canCreateInvoice() async {
    debugPrint('🔍 FreemiumService.canCreateInvoice: Verificando si puede crear factura...');
    
    // Si tiene suscripción activa, siempre puede crear
    final hasSubscription = await hasActiveSubscription();
    debugPrint('📊 FreemiumService.canCreateInvoice: hasActiveSubscription = $hasSubscription');
    
    if (hasSubscription) {
      debugPrint('✅ FreemiumService.canCreateInvoice: Usuario tiene suscripción activa, permitiendo crear factura');
      return true;
    }

    // Si no, verificar límites
    final currentCount = await getCurrentInvoiceCount();
    debugPrint('📊 FreemiumService.canCreateInvoice: currentCount = $currentCount, limit = $defaultFreeInvoiceLimit');
    
    final canCreate = currentCount < defaultFreeInvoiceLimit;
    debugPrint('📊 FreemiumService.canCreateInvoice: Resultado final = $canCreate');
    
    return canCreate;
  }

  /// Verifica si el usuario puede crear un nuevo cliente
  Future<bool> canCreateClient() async {
    // Si tiene suscripción activa, siempre puede crear
    if (await hasActiveSubscription()) return true;

    // Si no, verificar límites
    final currentCount = await getCurrentClientCount();
    return currentCount < defaultFreeClientLimit;
  }

  /// Obtiene el conteo actual de estimados del usuario
  Future<int> getCurrentEstimateCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response =
          await _supabase.from('estimates').select('id').eq('user_id', userId);

      return response.length;
    } catch (e) {
      debugPrint('Error getting estimate count: $e');
      return 0;
    }
  }

  /// Verifica si el usuario puede crear un nuevo estimado
  Future<bool> canCreateEstimate() async {
    // Si tiene suscripción activa, siempre puede crear
    if (await hasActiveSubscription()) return true;

    // Si no, verificar límites
    final currentCount = await getCurrentEstimateCount();
    return currentCount < defaultFreeEstimateLimit;
  }

  /// Obtiene el conteo actual de escaneos OCR del usuario
  Future<int> getCurrentOCRCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      // Contar directamente desde la tabla ocr_scans
      final response = await _supabase
          .from('ocr_scans')
          .select('id')
          .eq('user_id', userId)
          .count();

      return response.count;
    } catch (e) {
      debugPrint('Error getting OCR count: $e');
      return 0;
    }
    // try {
    //   final userId = _supabase.auth.currentUser?.id;
    //   if (userId == null) return 0;

    //   // Usar el nuevo servicio OCR para obtener el conteo
    //   final ocrService = OCRReceiptService();
    //   return await ocrService.getOCRUsageCount();
    // } catch (e) {
    //   debugPrint('Error getting OCR count: $e');
    //   return 0;
    // }
  }

  /// Verifica si el usuario puede usar OCR
  Future<bool> canUseOCR() async {
    debugPrint('🔍 FreemiumService.canUseOCR: Verificando si puede usar OCR...');
    
    // Si tiene suscripción activa, siempre puede usar
    final hasSubscription = await hasActiveSubscription();
    debugPrint('📊 FreemiumService.canUseOCR: hasActiveSubscription = $hasSubscription');
    
    if (hasSubscription) {
      debugPrint('✅ FreemiumService.canUseOCR: Usuario tiene suscripción activa, permitiendo OCR');
      return true;
    }

    // Si no, verificar límites
    final currentCount = await getCurrentOCRCount();
    debugPrint('📊 FreemiumService.canUseOCR: currentCount = $currentCount, limit = $defaultFreeOCRLimit');
    
    final canUse = currentCount < defaultFreeOCRLimit;
    debugPrint('📊 FreemiumService.canUseOCR: Resultado final = $canUse');
    
    return canUse;
  }

  /// Obtiene el conteo actual de reportes generados del usuario
  Future<int> getCurrentReportCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('reports_generated')
          .select('id')
          .eq('user_id', userId);

      return response.length;
    } catch (e) {
      debugPrint('Error getting report count: $e');
      return 0;
    }
  }

  /// Verifica si el usuario puede generar reportes
  Future<bool> canGenerateReport() async {
    // Si tiene suscripción activa, siempre puede generar
    if (await hasActiveSubscription()) return true;

    // Si no, verificar límites
    final currentCount = await getCurrentReportCount();
    return currentCount < defaultFreeReportsLimit;
  }

  /// Método general para verificar si se puede realizar una acción
  Future<FreemiumCheckResult> checkFreemiumAction(FreemiumAction action) async {
    if (await hasActiveSubscription()) {
      return FreemiumCheckResult.allowed();
    }

    switch (action) {
      case FreemiumAction.createInvoice:
        final canCreate = await canCreateInvoice();
        final currentCount = await getCurrentInvoiceCount();
        return canCreate
            ? FreemiumCheckResult.allowed()
            : FreemiumCheckResult.limitReached(
                'Has alcanzado el límite de $defaultFreeInvoiceLimit facturas gratuitas',
                'facturas',
                currentCount,
                defaultFreeInvoiceLimit,
              );

      case FreemiumAction.createClient:
        final canCreate = await canCreateClient();
        final currentCount = await getCurrentClientCount();
        return canCreate
            ? FreemiumCheckResult.allowed()
            : FreemiumCheckResult.limitReached(
                'Has alcanzado el límite de $defaultFreeClientLimit clientes gratuitos',
                'clientes',
                currentCount,
                defaultFreeClientLimit,
              );

      case FreemiumAction.createEstimate:
        final canCreate = await canCreateEstimate();
        final currentCount = await getCurrentEstimateCount();
        return canCreate
            ? FreemiumCheckResult.allowed()
            : FreemiumCheckResult.limitReached(
                'Has alcanzado el límite de $defaultFreeEstimateLimit estimados gratuitos',
                'estimados',
                currentCount,
                defaultFreeEstimateLimit,
              );

      case FreemiumAction.useOCR:
        final canUse = await canUseOCR();
        final currentCount = await getCurrentOCRCount();
        return canUse
            ? FreemiumCheckResult.allowed()
            : FreemiumCheckResult.limitReached(
                'Has alcanzado el límite de $defaultFreeOCRLimit escaneos de facturas gratuitos',
                'Escaneos de facturas',
                currentCount,
                defaultFreeOCRLimit,
              );

      case FreemiumAction.generateReport:
        final canGenerate = await canGenerateReport();
        final currentCount = await getCurrentReportCount();
        return canGenerate
            ? FreemiumCheckResult.allowed()
            : FreemiumCheckResult.limitReached(
                'Has alcanzado el límite de $defaultFreeReportsLimit reportes gratuitos',
                'reportes',
                currentCount,
                defaultFreeReportsLimit,
              );
    }
  }

  /// Incrementa el contador de una acción (para tracking)
  Future<void> incrementActionCount(FreemiumAction action) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      switch (action) {
        case FreemiumAction.useOCR:
          // NO insertar aquí - OCRReceiptService.saveOCRReceipt ya lo hace
          // El trigger en ocr_scans actualiza automáticamente anonymous_user_tracking
          debugPrint('📊 OCR tracking: el registro se guarda via OCRReceiptService');
          break;
          
        case FreemiumAction.generateReport:
          // Insertar en reports_generated - el trigger actualiza automaticamente
          await _supabase.from('reports_generated').insert({
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
          });
          break;
          
        // Las facturas, clientes y estimados se incrementan automáticamente
        // cuando se crean en sus respectivas tablas (con triggers)
        default:
          break;
      }
      
      debugPrint('✅ Contador incrementado: ${action.name} para usuario $userId');
    } catch (e) {
      debugPrint('❌ Error incrementando contador: $e');
    }
  }

  /// Verifica si debe mostrar el paywall después del límite
  Future<bool> shouldShowLimitPaywall(int currentCount, int limit) async {
    // Si tiene suscripción, no mostrar paywall
    if (await hasActiveSubscription()) return false;

    // Si no ha alcanzado el límite, no mostrar
    if (currentCount < limit) return false;

    // Verificar cooldown para no mostrar muy seguido
    return await _canShowPaywall();
  }

  /// Verifica si debe mostrar el paywall en el primer login
  Future<bool> shouldShowFirstTimePaywall() async {
    // Si ya tiene suscripción, no mostrar
    if (await hasActiveSubscription()) return false;

    // Si ya se mostró antes, no mostrar
    if (await hasShownFirstTimePaywall()) return false;

    // Si el onboarding no está completo, no mostrar aún
    if (!await isOnboardingCompleted()) return false;

    // Verificar período de gracia después del registro
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final creationDateStr = _prefs.getString('${_kUserCreationDate}_$userId');
      if (creationDateStr != null) {
        final creationDate = DateTime.parse(creationDateStr);
        final now = DateTime.now();

        // Si está dentro del período de gracia, no mostrar
        if (now.difference(creationDate) < gracePeriodAfterSignup) {
          return false;
        }
      }
    }

    return true;
  }

  /// Verifica si puede mostrar paywall (cooldown)
  Future<bool> _canShowPaywall() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final lastShownStr = _prefs.getString('${_kLastPaywallShown}_$userId');
    if (lastShownStr == null) return true;

    final lastShown = DateTime.parse(lastShownStr);
    final now = DateTime.now();

    return now.difference(lastShown) >= paywallCooldown;
  }

  /// Actualiza la última vez que se mostró el paywall
  Future<void> updateLastPaywallShown() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _prefs.setString(
        '${_kLastPaywallShown}_$userId', DateTime.now().toIso8601String());
  }

  /// Obtiene estadísticas de uso para mostrar en el paywall
  Future<FreemiumUsageStats> getUsageStats() async {
    final hasSub = await hasActiveSubscription();
    final invoiceCount = await getCurrentInvoiceCount();
    final clientCount = await getCurrentClientCount();
    final estimateCount = await getCurrentEstimateCount();
    final ocrCount = await getCurrentOCRCount();
    final reportCount = await getCurrentReportCount();

    return FreemiumUsageStats(
      invoiceCount: invoiceCount,
      clientCount: clientCount,
      estimateCount: estimateCount,
      ocrCount: ocrCount,
      reportCount: reportCount,
      invoiceLimit: defaultFreeInvoiceLimit,
      clientLimit: defaultFreeClientLimit,
      estimateLimit: defaultFreeEstimateLimit,
      ocrLimit: defaultFreeOCRLimit,
      reportLimit: defaultFreeReportsLimit,
      hasActiveSubscription: hasSub,
    );
  }

  /// Resetea todos los datos freemium (útil para testing)
  Future<void> resetFreemiumData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _prefs.remove('${_kFirstLoginCompleted}_$userId');
    await _prefs.remove('${_kPaywallShownFirstTime}_$userId');
    await _prefs.remove('${_kOnboardingCompleted}_$userId');
    await _prefs.remove('${_kUserCreationDate}_$userId');
    await _prefs.remove('${_kLastPaywallShown}_$userId');

    debugPrint('Freemium data reset for user $userId');
  }
}

class FreemiumUsageStats {
  final int invoiceCount;
  final int clientCount;
  final int estimateCount;
  final int ocrCount;
  final int reportCount;
  final int invoiceLimit;
  final int clientLimit;
  final int estimateLimit;
  final int ocrLimit;
  final int reportLimit;
  final bool hasActiveSubscription;

  FreemiumUsageStats({
    required this.invoiceCount,
    required this.clientCount,
    required this.estimateCount,
    required this.ocrCount,
    required this.reportCount,
    required this.invoiceLimit,
    required this.clientLimit,
    required this.estimateLimit,
    required this.ocrLimit,
    required this.reportLimit,
    required this.hasActiveSubscription,
  });

  /// Porcentaje de uso de facturas
  double get invoiceUsagePercentage => hasActiveSubscription
      ? 0.0
      : (invoiceCount / invoiceLimit).clamp(0.0, 1.0);

  /// Porcentaje de uso de clientes
  double get clientUsagePercentage =>
      hasActiveSubscription ? 0.0 : (clientCount / clientLimit).clamp(0.0, 1.0);

  /// Porcentaje de uso de estimados
  double get estimateUsagePercentage => hasActiveSubscription
      ? 0.0
      : (estimateCount / estimateLimit).clamp(0.0, 1.0);

  /// Porcentaje de uso de OCR
  double get ocrUsagePercentage =>
      hasActiveSubscription ? 0.0 : (ocrCount / ocrLimit).clamp(0.0, 1.0);

  /// Porcentaje de uso de reportes
  double get reportUsagePercentage =>
      hasActiveSubscription ? 0.0 : (reportCount / reportLimit).clamp(0.0, 1.0);

  /// Facturas restantes
  int get remainingInvoices => hasActiveSubscription
      ? -1
      : (invoiceLimit - invoiceCount).clamp(0, invoiceLimit);

  /// Clientes restantes
  int get remainingClients => hasActiveSubscription
      ? -1
      : (clientLimit - clientCount).clamp(0, clientLimit);

  /// Estimados restantes
  int get remainingEstimates => hasActiveSubscription
      ? -1
      : (estimateLimit - estimateCount).clamp(0, estimateLimit);

  /// OCR restantes
  int get remainingOCR =>
      hasActiveSubscription ? -1 : (ocrLimit - ocrCount).clamp(0, ocrLimit);

  /// Reportes restantes
  int get remainingReports => hasActiveSubscription
      ? -1
      : (reportLimit - reportCount).clamp(0, reportLimit);

  /// Si está cerca del límite de facturas (>80%)
  bool get isNearInvoiceLimit => invoiceUsagePercentage >= 0.8;

  /// Si está cerca del límite de clientes (>80%)
  bool get isNearClientLimit => clientUsagePercentage >= 0.8;

  /// Si está cerca del límite de estimados (>80%)
  bool get isNearEstimateLimit => estimateUsagePercentage >= 0.8;

  /// Si está cerca del límite de OCR (>80%)
  bool get isNearOCRLimit => ocrUsagePercentage >= 0.8;

  /// Si está cerca del límite de reportes (>80%)
  bool get isNearReportLimit => reportUsagePercentage >= 0.8;

  /// Obtiene el límite más crítico (más cerca del 100%)
  double get highestUsagePercentage => [
        invoiceUsagePercentage,
        clientUsagePercentage,
        estimateUsagePercentage,
        ocrUsagePercentage,
        reportUsagePercentage,
      ].reduce((a, b) => a > b ? a : b);

  /// Obtiene el nombre del límite más crítico
  String get mostCriticalLimit {
    final percentages = {
      'facturas': invoiceUsagePercentage,
      'clientes': clientUsagePercentage,
      'estimados': estimateUsagePercentage,
      'OCR': ocrUsagePercentage,
      'reportes': reportUsagePercentage,
    };

    return percentages.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

/// Provider para el servicio freemium
final freemiumServiceProvider = FutureProvider<FreemiumService>((ref) async {
  // Las dependencias se resuelven de forma síncrona una vez que la app está inicializada.
  final prefs = ref.watch(sharedPreferencesProvider);
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);

  if (supabase.auth.currentUser == null) {
    throw Exception('User not authenticated');
  }

  return FreemiumService(supabase, prefs, subscriptionService);
});

/// Provider para las estadísticas de uso
/// Provider para estadísticas de uso con mejor manejo de errores
final usageStatsProvider = FutureProvider<FreemiumUsageStats>((ref) async {
  try {
    // Espera a que el freemiumService esté disponible
    final freemiumService = await ref.watch(freemiumServiceProvider.future);

    // Agregar timeout para evitar esperas infinitas
    return await freemiumService.getUsageStats().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint('Timeout al obtener estadísticas de uso');
        // Devolver valores por defecto en caso de timeout
        return FreemiumUsageStats(
          invoiceCount: 0,
          clientCount: 0,
          estimateCount: 0,
          ocrCount: 0,
          reportCount: 0,
          invoiceLimit: FreemiumService.defaultFreeInvoiceLimit,
          clientLimit: FreemiumService.defaultFreeClientLimit,
          estimateLimit: FreemiumService.defaultFreeEstimateLimit,
          ocrLimit: FreemiumService.defaultFreeOCRLimit,
          reportLimit: FreemiumService.defaultFreeReportsLimit,
          hasActiveSubscription: false,
        );
      },
    );
  } catch (e) {
    debugPrint('Error en usageStatsProvider: $e');

    // Devolver valores por defecto en caso de error
    return FreemiumUsageStats(
      invoiceCount: 0,
      clientCount: 0,
      estimateCount: 0,
      ocrCount: 0,
      reportCount: 0,
      invoiceLimit: FreemiumService.defaultFreeInvoiceLimit,
      clientLimit: FreemiumService.defaultFreeClientLimit,
      estimateLimit: FreemiumService.defaultFreeEstimateLimit,
      ocrLimit: FreemiumService.defaultFreeOCRLimit,
      reportLimit: FreemiumService.defaultFreeReportsLimit,
      hasActiveSubscription: false,
    );
  }
});

/// Provider para manejar estado de conexión y retry automático
final usageStatsRetryProvider = StateNotifierProvider<UsageStatsRetryNotifier,
    AsyncValue<FreemiumUsageStats>>((ref) {
  return UsageStatsRetryNotifier(ref);
});

class UsageStatsRetryNotifier
    extends StateNotifier<AsyncValue<FreemiumUsageStats>> {
  final Ref _ref;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  UsageStatsRetryNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (_retryCount >= _maxRetries) {
      state = AsyncValue.error(
        'No se pudo cargar la información después de $_maxRetries intentos',
        StackTrace.current,
      );
      return;
    }

    _retryCount++;

    try {
      state = const AsyncValue.loading();

      final freemiumService = await _ref.watch(freemiumServiceProvider.future);
      final stats = await freemiumService.getUsageStats().timeout(
            const Duration(seconds: 10),
          );

      state = AsyncValue.data(stats);
      _retryCount = 0; // Reset retry count on success
    } catch (e) {
      debugPrint(
          'Error loading usage stats (attempt $_retryCount/$_maxRetries): $e');

      if (_retryCount < _maxRetries) {
        // Esperar un poco antes del próximo retry
        await Future.delayed(Duration(seconds: _retryCount * 2));
        _loadStats(); // Retry automáticamente
      } else {
        // Después de todos los retries, devolver valores por defecto
        state = AsyncValue.data(FreemiumUsageStats(
          invoiceCount: 0,
          clientCount: 0,
          estimateCount: 0,
          ocrCount: 0,
          reportCount: 0,
          invoiceLimit: FreemiumService.defaultFreeInvoiceLimit,
          clientLimit: FreemiumService.defaultFreeClientLimit,
          estimateLimit: FreemiumService.defaultFreeEstimateLimit,
          ocrLimit: FreemiumService.defaultFreeOCRLimit,
          reportLimit: FreemiumService.defaultFreeReportsLimit,
          hasActiveSubscription: false,
        ));
      }
    }
  }

  void retry() {
    _retryCount = 0;
    _loadStats();
  }
}

/// Provider para obtener información contextual de límites freemium
final freemiumLimitsProvider =
    FutureProvider<Map<String, FreemiumCheckResult>>((ref) async {
  try {
    final freemiumService = await ref.watch(freemiumServiceProvider.future);

    // Obtener checks para todas las acciones principales
    final results = await Future.wait([
      freemiumService.checkFreemiumAction(FreemiumAction.createInvoice),
      freemiumService.checkFreemiumAction(FreemiumAction.createClient),
      freemiumService.checkFreemiumAction(FreemiumAction.createEstimate),
      freemiumService.checkFreemiumAction(FreemiumAction.useOCR),
      freemiumService.checkFreemiumAction(FreemiumAction.generateReport),
    ]);

    return {
      'invoice': results[0],
      'client': results[1],
      'estimate': results[2],
      'ocr': results[3],
      'report': results[4],
    };
  } catch (e) {
    debugPrint('Error obteniendo límites freemium: $e');
    // Devolver valores por defecto
    return {};
  }
});

/// Enum para las acciones freemium
enum FreemiumAction {
  createInvoice,
  createClient,
  createEstimate,
  useOCR,
  generateReport,
}

/// Resultado de verificación freemium
class FreemiumCheckResult {
  final bool isAllowed;
  final String? message;
  final String? limitType;
  final int? currentCount;
  final int? maxCount;

  const FreemiumCheckResult._(
    this.isAllowed,
    this.message,
    this.limitType,
    this.currentCount,
    this.maxCount,
  );

  /// Acción permitida
  factory FreemiumCheckResult.allowed() {
    return const FreemiumCheckResult._(true, null, null, null, null);
  }

  /// Límite alcanzado
  factory FreemiumCheckResult.limitReached(
    String message,
    String limitType,
    int currentCount,
    int maxCount,
  ) {
    return FreemiumCheckResult._(
      false,
      message,
      limitType,
      currentCount,
      maxCount,
    );
  }

  /// Porcentaje de uso del límite
  double get usagePercentage {
    if (currentCount == null || maxCount == null || maxCount == 0) return 0.0;
    return (currentCount! / maxCount!).clamp(0.0, 1.0);
  }

  /// Elementos restantes
  int get remaining {
    if (currentCount == null || maxCount == null) return 0;
    return (maxCount! - currentCount!).clamp(0, maxCount!);
  }
}
