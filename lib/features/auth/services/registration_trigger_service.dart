import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/registration_prompt_dialog.dart';

/// Servicio para manejar los triggers de registro de usuarios anónimos
/// Basado en mejores prácticas de UX para conversión freemium:
/// - Trigger en "Aha Moment" (primera factura, primer OCR exitoso)
/// - Trigger basado en engagement (uso activo)
/// - Trigger basado en límites (50% de uso)
class RegistrationTriggerService {
  final SharedPreferences _prefs;
  final SupabaseClient _supabase;

  // Keys para SharedPreferences
  static const String _keyInvoiceCount = 'trigger_invoice_count';
  static const String _keyOcrCount = 'trigger_ocr_count';
  static const String _keyClientCount = 'trigger_client_count';
  static const String _keyEstimateCount = 'trigger_estimate_count';
  static const String _keyFirstInvoiceShown = 'trigger_first_invoice_shown';
  static const String _keySecondOcrShown = 'trigger_second_ocr_shown';
  static const String _keyFirstClientShown = 'trigger_first_client_shown';
  static const String _keyFirstEstimateShown = 'trigger_first_estimate_shown';
  static const String _keyHalfwayLimitShown = 'trigger_halfway_limit_shown';
  static const String _keyTimeEngagementShown = 'trigger_time_engagement_shown';
  static const String _keyFirstAppOpen = 'trigger_first_app_open';
  static const String _keyDismissedUntil = 'trigger_dismissed_until';

  RegistrationTriggerService(this._prefs, this._supabase);

  /// Verifica si el usuario actual es anónimo
  bool get isAnonymousUser {
    final user = _supabase.auth.currentUser;
    return user?.isAnonymous ?? true;
  }

  /// Verifica si el usuario ya está registrado (no anónimo)
  bool get isRegisteredUser => !isAnonymousUser;

  /// Verifica si los prompts están temporalmente deshabilitados
  bool get _isPromptDismissed {
    final dismissedUntil = _prefs.getInt(_keyDismissedUntil) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < dismissedUntil;
  }

  /// Deshabilita los prompts por un período de tiempo
  Future<void> dismissPromptsFor(Duration duration) async {
    final until = DateTime.now().add(duration).millisecondsSinceEpoch;
    await _prefs.setInt(_keyDismissedUntil, until);
  }

  /// Registra que se creó una factura y verifica si debe mostrar prompt
  Future<RegistrationTrigger?> onInvoiceCreated() async {
    if (isRegisteredUser || _isPromptDismissed) return null;

    final count = (_prefs.getInt(_keyInvoiceCount) ?? 0) + 1;
    await _prefs.setInt(_keyInvoiceCount, count);

    // Primera factura - "Aha Moment"
    if (count == 1 && !(_prefs.getBool(_keyFirstInvoiceShown) ?? false)) {
      await _prefs.setBool(_keyFirstInvoiceShown, true);
      return RegistrationTrigger.firstInvoice;
    }

    // Verificar si alcanzó 50% del límite (2.5 de 5 = 3)
    if (count == 3 && !(_prefs.getBool(_keyHalfwayLimitShown) ?? false)) {
      await _prefs.setBool(_keyHalfwayLimitShown, true);
      return RegistrationTrigger.firstInvoice;
    }

    return null;
  }

  /// Registra que se usó OCR y verifica si debe mostrar prompt
  Future<RegistrationTrigger?> onOcrUsed() async {
    if (isRegisteredUser || _isPromptDismissed) return null;

    final count = (_prefs.getInt(_keyOcrCount) ?? 0) + 1;
    await _prefs.setInt(_keyOcrCount, count);

    // Segundo OCR - Usuario está aprovechando la app
    if (count == 2 && !(_prefs.getBool(_keySecondOcrShown) ?? false)) {
      await _prefs.setBool(_keySecondOcrShown, true);
      return RegistrationTrigger.firstInvoice;
    }

    return null;
  }

  /// Registra que se creó un cliente y verifica si debe mostrar prompt
  Future<RegistrationTrigger?> onClientCreated() async {
    if (isRegisteredUser || _isPromptDismissed) return null;

    final count = (_prefs.getInt(_keyClientCount) ?? 0) + 1;
    await _prefs.setInt(_keyClientCount, count);

    // Primer cliente - "Aha Moment"
    if (count == 1 && !(_prefs.getBool(_keyFirstClientShown) ?? false)) {
      await _prefs.setBool(_keyFirstClientShown, true);
      return RegistrationTrigger.firstInvoice;
    }

    return null;
  }

  /// Registra que se creó un estimado y verifica si debe mostrar prompt
  Future<RegistrationTrigger?> onEstimateCreated() async {
    if (isRegisteredUser || _isPromptDismissed) return null;

    final count = (_prefs.getInt(_keyEstimateCount) ?? 0) + 1;
    await _prefs.setInt(_keyEstimateCount, count);

    // Primer estimado - "Aha Moment"
    if (count == 1 && !(_prefs.getBool(_keyFirstEstimateShown) ?? false)) {
      await _prefs.setBool(_keyFirstEstimateShown, true);
      return RegistrationTrigger.firstInvoice;
    }

    return null;
  }

  /// Verifica si debe mostrar prompt basado en tiempo de uso
  Future<RegistrationTrigger?> checkTimeBasedEngagement() async {
    if (isRegisteredUser || _isPromptDismissed) return null;

    final firstOpen = _prefs.getInt(_keyFirstAppOpen);
    
    if (firstOpen == null) {
      // Primera vez que abre la app
      await _prefs.setInt(_keyFirstAppOpen, DateTime.now().millisecondsSinceEpoch);
      return null;
    }

    final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(firstOpen);
    final hoursSinceFirstOpen = DateTime.now().difference(firstOpenDate).inHours;

    // Después de 24 horas de uso
    if (hoursSinceFirstOpen >= 24 && !(_prefs.getBool(_keyTimeEngagementShown) ?? false)) {
      await _prefs.setBool(_keyTimeEngagementShown, true);
      return RegistrationTrigger.timeBasedEngagement;
    }

    return null;
  }

  /// Muestra el dialog de registro si hay un trigger activo
  Future<void> showPromptIfNeeded(
    BuildContext context,
    RegistrationTrigger? trigger, {
    VoidCallback? onRegister,
    VoidCallback? onDismiss,
  }) async {
    if (trigger == null || !context.mounted) return;

    await RegistrationPromptDialog.show(
      context,
      trigger: trigger,
      onRegister: onRegister,
      onDismiss: () {
        // Deshabilitar prompts por 2 horas después de dismiss
        dismissPromptsFor(const Duration(hours: 2));
        onDismiss?.call();
      },
    );
  }

  /// Método conveniente para verificar y mostrar prompt después de crear factura
  Future<void> checkAndShowAfterInvoice(
    BuildContext context, {
    VoidCallback? onRegister,
  }) async {
    final trigger = await onInvoiceCreated();
    if (!context.mounted) return;
    await showPromptIfNeeded(context, trigger, onRegister: onRegister);
  }

  /// Método conveniente para verificar y mostrar prompt después de OCR
  Future<void> checkAndShowAfterOcr(
    BuildContext context, {
    VoidCallback? onRegister,
  }) async {
    final trigger = await onOcrUsed();
    if (!context.mounted) return;
    await showPromptIfNeeded(context, trigger, onRegister: onRegister);
  }

  /// Método conveniente para verificar y mostrar prompt después de crear cliente
  Future<void> checkAndShowAfterClient(
    BuildContext context, {
    VoidCallback? onRegister,
  }) async {
    final trigger = await onClientCreated();
    if (!context.mounted) return;
    await showPromptIfNeeded(context, trigger, onRegister: onRegister);
  }

  /// Método conveniente para verificar y mostrar prompt después de crear estimado
  Future<void> checkAndShowAfterEstimate(
    BuildContext context, {
    VoidCallback? onRegister,
  }) async {
    final trigger = await onEstimateCreated();
    if (!context.mounted) return;
    await showPromptIfNeeded(context, trigger, onRegister: onRegister);
  }

}

/// Provider para el servicio de triggers de registro
final registrationTriggerServiceProvider = Provider<RegistrationTriggerService>((ref) {
  throw UnimplementedError('Debe ser overrideado con SharedPreferences');
});

/// Provider que se inicializa con SharedPreferences
final registrationTriggerServiceProviderFamily = Provider.family<RegistrationTriggerService, SharedPreferences>((ref, prefs) {
  return RegistrationTriggerService(prefs, Supabase.instance.client);
});
