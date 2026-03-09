import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:facturo/core/constants/app_constants.dart';

/// Mixin para facilitar el uso de verificaciones freemium en widgets
mixin FreemiumMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Verifica si se puede realizar una acción freemium
  /// Si no se puede, muestra el diálogo apropiado automáticamente
  /// Retorna true si se puede realizar la acción
  Future<bool> checkFreemiumAction(
    FreemiumAction action, {
    bool showPaywallOnLimit = true,
  }) async {
    try {
      final freemiumService = await ref.read(freemiumServiceProvider.future);
      final result = await freemiumService.checkFreemiumAction(action);

      if (!result.isAllowed && showPaywallOnLimit && mounted) {
        await _handleLimitReached(action, result);
      }

      return result.isAllowed;
    } catch (e) {
      // Si hay error, permitir la acción por defecto
      return true;
    }
  }

  /// Maneja el flujo cuando se alcanza un límite
  /// Apple Guideline 5.1.1: Always show paywall directly, never require
  /// registration before allowing in-app purchases
  Future<void> _handleLimitReached(
    FreemiumAction action,
    FreemiumCheckResult result,
  ) async {
    try {
      // Mostrar paywall directamente para TODOS los usuarios (anónimos y autenticados)
      if (mounted) {
        await context.push(AppConstants.subscriptionsRoute);
      }

      if (mounted) {
        final freemiumService = await ref.read(freemiumServiceProvider.future);
        await freemiumService.updateLastPaywallShown();
      }
    } catch (e) {
      debugPrint('⚠️ Error manejando límite freemium: $e');
    }
  }

  /// Ejecuta una acción solo si está permitida por freemium
  /// Muestra paywall automáticamente si no está permitida
  Future<bool> executeIfAllowed(
    FreemiumAction action,
    VoidCallback onExecute, {
    bool showPaywallOnLimit = true,
  }) async {
    final canExecute = await checkFreemiumAction(
      action,
      showPaywallOnLimit: showPaywallOnLimit,
    );

    if (canExecute) {
      onExecute();
      // Incrementar contador si es necesario
      await _incrementActionCount(action);
    }

    return canExecute;
  }

  /// Ejecuta una acción asíncrona solo si está permitida por freemium
  Future<bool> executeAsyncIfAllowed(
    FreemiumAction action,
    Future<void> Function() onExecute, {
    bool showPaywallOnLimit = true,
  }) async {
    final canExecute = await checkFreemiumAction(
      action,
      showPaywallOnLimit: showPaywallOnLimit,
    );

    if (canExecute) {
      await onExecute();
      // Incrementar contador si es necesario
      await _incrementActionCount(action);
    }

    return canExecute;
  }

  /// Verifica múltiples acciones a la vez
  /// Útil para pantallas que requieren varios permisos
  Future<Map<FreemiumAction, bool>> checkMultipleActions(
    List<FreemiumAction> actions,
  ) async {
    try {
      final freemiumService = await ref.read(freemiumServiceProvider.future);
      final results = <FreemiumAction, bool>{};

      for (final action in actions) {
        final result = await freemiumService.checkFreemiumAction(action);
        results[action] = result.isAllowed;
      }

      return results;
    } catch (e) {
      // Si hay error, permitir todas las acciones por defecto
      return {for (var action in actions) action: true};
    }
  }

  /// Obtiene el resultado detallado de una verificación freemium
  Future<FreemiumCheckResult?> getFreemiumCheckResult(
    FreemiumAction action,
  ) async {
    try {
      final freemiumService = await ref.read(freemiumServiceProvider.future);
      return await freemiumService.checkFreemiumAction(action);
    } catch (e) {
      return null;
    }
  }

  /// Incrementa el contador de una acción (para tracking)
  Future<void> _incrementActionCount(FreemiumAction action) async {
    try {
      final freemiumService = await ref.read(freemiumServiceProvider.future);

      // Solo incrementar para acciones que requieren tracking manual
      if (action == FreemiumAction.useOCR ||
          action == FreemiumAction.generateReport) {
        await freemiumService.incrementActionCount(action);
      }
    } catch (e) {
      // Si hay error, no hacer nada
    }
  }

  /// Incrementa el contador de una acción freemium (método público)
  Future<void> incrementFreemiumAction(FreemiumAction action) async {
    try {
      final freemiumService = await ref.read(freemiumServiceProvider.future);
      await freemiumService.incrementActionCount(action);
    } catch (e) {
      // Si hay error, no hacer nada
      debugPrint('⚠️ Error incrementando contador freemium: $e');
    }
  }

  /// Muestra un snackbar con información del límite
  void showLimitSnackBar(FreemiumCheckResult result) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result.message ?? 'Límite alcanzado',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Upgrade',
          textColor: Colors.white,
          onPressed: () {
            // Navegar a suscripciones
            // context.push(AppConstants.subscriptionsRoute);
          },
        ),
      ),
    );
  }

  /// Verifica si el usuario tiene suscripción activa
  Future<bool> hasActiveSubscription() async {
    try {
      final freemiumService = await ref.read(freemiumServiceProvider.future);
      return await freemiumService.hasActiveSubscription();
    } catch (e) {
      return false;
    }
  }

  /// Obtiene las estadísticas de uso actuales
  Future<FreemiumUsageStats?> getUsageStats() async {
    try {
      final freemiumService = await ref.read(freemiumServiceProvider.future);
      return await freemiumService.getUsageStats();
    } catch (e) {
      return null;
    }
  }
}

/// Extension para facilitar el uso en widgets que no pueden usar mixins
extension FreemiumExtension on WidgetRef {
  /// Verifica una acción freemium desde cualquier widget
  Future<bool> checkFreemiumAction(FreemiumAction action) async {
    try {
      final freemiumService = await read(freemiumServiceProvider.future);
      final result = await freemiumService.checkFreemiumAction(action);
      return result.isAllowed;
    } catch (e) {
      return true;
    }
  }

  /// Obtiene las estadísticas de uso
  Future<FreemiumUsageStats?> getFreemiumStats() async {
    try {
      final freemiumService = await read(freemiumServiceProvider.future);
      return await freemiumService.getUsageStats();
    } catch (e) {
      return null;
    }
  }
}
