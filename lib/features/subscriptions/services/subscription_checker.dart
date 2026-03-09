import 'package:facturo/core/constants/app_constants.dart';
import 'package:facturo/features/subscriptions/services/subscription_service.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

/// A class that provides functionality to check if a user
/// has access to premium features based on their subscription.
class SubscriptionChecker {
  final SubscriptionService? subscriptionService;
  final FreemiumService freemiumService;

  SubscriptionChecker(this.subscriptionService, this.freemiumService);

  /// Checks if the user has an active subscription.
  /// Returns true if they have a subscription, false if not.
  Future<bool> hasActiveSubscription() async {
    if (subscriptionService == null) return false;
    final subscription = await subscriptionService!.getCurrentSubscription();
    return subscription.isActive;
  }

  /// Checks if the user has an active subscription and redirects to paywall if not.
  /// Returns true if they have a subscription, false if they don't and were redirected.
  Future<bool> checkSubscriptionOrRedirect(
    BuildContext context, {
    String title = 'Premium Feature',
    String message = 'This feature requires an active subscription',
    IconData icon = Icons.lock,
  }) async {
    final hasSubscription = await hasActiveSubscription();

    if (!hasSubscription && context.mounted) {
      final result = await context.push<bool?>(
        AppConstants.subscriptionsRoute,
        extra: {
          'title': title,
          'message': message,
          'iconCode': icon.codePoint.toString(),
        },
      );

      // If the user purchased a subscription in the paywall
      if (result == true) {
        return true;
      }

      return false;
    }

    return hasSubscription;
  }

  /// Checks if the user can perform more than X operations (limited in free version)
  /// For example, limit to 5 invoices in the free version
  Future<bool> canPerformLimitedOperation(
    BuildContext context,
    int currentCount,
    int freeLimit, {
    String title = 'Limit reached',
    String? customMessage,
    IconData icon = Icons.warning,
  }) async {
    // If they have a subscription, there's no limit
    final hasSubscription = await hasActiveSubscription();
    if (hasSubscription) return true;

    // If they don't have a subscription and reached the limit
    if (currentCount >= freeLimit && context.mounted) {
      final message =
          customMessage ??
          'You have reached the limit of $freeLimit in the free version. Upgrade to continue.';

      // Usar el paywall inteligente
      final result = await context.push<bool?>(
        AppConstants.subscriptionsRoute,
        extra: {
          'title': title,
          'message': message,
          'iconCode': icon.codePoint.toString(),
          'isFirstTimePaywall': false,
        },
      );

      // Actualizar que se mostró el paywall
      await freemiumService.updateLastPaywallShown();

      // If the user purchased a subscription in the paywall
      if (result == true) {
        return true;
      }

      return false;
    }

    // Has free version but hasn't reached the limit yet
    return true;
  }

  /// Muestra el paywall de primera vez si es necesario
  Future<bool> showFirstTimePaywallIfNeeded(BuildContext context) async {
    if (!await freemiumService.shouldShowFirstTimePaywall()) {
      return false;
    }

    if (context.mounted) {
      final result = await context.push<bool?>(
        AppConstants.subscriptionsRoute,
        extra: {
          'title': '¡Bienvenido a Facturo Pro!',
          'message': 'Descubre todas las funcionalidades premium',
          'iconCode': Icons.star.codePoint.toString(),
          'isFirstTimePaywall': true,
        },
      );

      // Marcar que se mostró el paywall por primera vez
      await freemiumService.markFirstTimePaywallShown();

      return result == true;
    }

    return false;
  }

  /// Muestra el paywall inteligente siempre (para botones de upgrade)
  Future<bool> showSmartPaywall(
    BuildContext context, {
    String? title,
    String? message,
    IconData icon = Icons.star,
  }) async {
    // Si ya tiene suscripción, no mostrar
    if (await hasActiveSubscription()) return true;

    if (context.mounted) {
      final localizations = AppLocalizations.of(context);

      final result = await context.push<bool?>(
        AppConstants.subscriptionsRoute,
        extra: {
          'title': title ?? localizations.upgradeToFacturoPro,
          'message': message ?? localizations.unlockPremiumFeatures,
          'iconCode': icon.codePoint.toString(),
          'isFirstTimePaywall': false,
        },
      );

      // Actualizar que se mostró el paywall
      await freemiumService.updateLastPaywallShown();

      return result == true;
    }

    return false;
  }
}

/// Provider for the subscription checker
final subscriptionCheckerProvider = FutureProvider<SubscriptionChecker?>((
  ref,
) async {
  try {
    final subscriptionService = ref.watch(subscriptionServiceProvider);

    // Wait for the freemium service to be available
    final freemiumService = await ref.watch(freemiumServiceProvider.future);

    return SubscriptionChecker(subscriptionService, freemiumService);
  } catch (e) {
    if (e is StateError && e.message == 'Supabase not initialized yet') {
      // Re-throw Supabase initialization errors to trigger widget rebuilds
      rethrow;
    }
    // Return null for other errors
    return null;
  }
});

/// Synchronous provider that returns null while loading
final subscriptionCheckerSyncProvider = Provider<SubscriptionChecker?>((ref) {
  try {
    final asyncChecker = ref.watch(subscriptionCheckerProvider);
    return asyncChecker.when(
      data: (checker) => checker,
      loading: () => null,
      error: (error, stack) {
        // Log error for debugging but don't crash
        debugPrint('SubscriptionChecker error: $error');
        return null;
      },
    );
  } catch (e) {
    // Catch any synchronous errors
    debugPrint('SubscriptionCheckerSync error: $e');
    return null;
  }
});

/// Extension to easily check subscriptions using the context
extension SubscriptionCheckerExtension on BuildContext {
  /// Checks if there's an active subscription or redirects to paywall
  Future<bool> checkSubscriptionOrRedirect({
    String title = 'Premium Feature',
    String message = 'This feature requires an active subscription',
    IconData icon = Icons.lock,
  }) async {
    final container = ProviderScope.containerOf(this);
    final checker = container.read(subscriptionCheckerSyncProvider);
    return checker?.checkSubscriptionOrRedirect(
          this,
          title: title,
          message: message,
          icon: icon,
        ) ??
        false;
  }

  /// Checks if they can perform more limited operations
  Future<bool> canPerformLimitedOperation(
    int currentCount,
    int freeLimit, {
    String title = 'Limit reached',
    String? customMessage,
    IconData icon = Icons.warning,
  }) async {
    final container = ProviderScope.containerOf(this);
    final checker = container.read(subscriptionCheckerSyncProvider);
    return checker?.canPerformLimitedOperation(
          this,
          currentCount,
          freeLimit,
          title: title,
          customMessage: customMessage,
          icon: icon,
        ) ??
        false;
  }
}
