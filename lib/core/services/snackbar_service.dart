import 'package:flutter/material.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

/// Servicio centralizado para mostrar SnackBars consistentes en toda la aplicación
class SnackbarService {
  static const Duration _defaultDuration = Duration(seconds: 4);
  static const double _borderRadius = 12.0;
  static const EdgeInsets _margin = EdgeInsets.only(
    left: 16.0,
    right: 16.0,
    top: 8.0,
    bottom: 16.0, // Margen inferior para que emerja desde abajo
  );
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// Muestra un SnackBar de éxito
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      duration: duration ?? _defaultDuration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Muestra un SnackBar de error
  static void showError(
    BuildContext context, {
    required String message,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      duration: duration ?? _defaultDuration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Muestra un SnackBar de advertencia
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
      duration: duration ?? _defaultDuration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Muestra un SnackBar informativo
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
      duration: duration ?? _defaultDuration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Muestra un SnackBar neutro (gris)
  static void showNeutral(
    BuildContext context, {
    required String message,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[500]!
          : Colors.grey[700]!,
      icon: Icons.info_outline,
      duration: duration ?? _defaultDuration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Método privado para mostrar el SnackBar con diseño consistente
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? _defaultDuration,
        margin: _margin,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1.0),
          curve: Curves.easeOutBack,
        ),
        content: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: _padding,
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (action != null && actionLabel != null) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    action();
                  },
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Oculta el SnackBar actual
  static void hideCurrentSnackBar(BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  /// Oculta todos los SnackBars
  static void hideAllSnackBars(BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  /// Métodos de conveniencia para mensajes comunes
  static void showLoginSuccess(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showSuccess(context, message: localizations.loginWelcome);
  }

  static void showRegistrationSuccess(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showSuccess(context, message: localizations.onboardingAccountCreatedSuccess);
  }

  static void showNetworkError(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showError(context, message: localizations.networkError);
  }

  static void showGenericError(BuildContext context, {String? error}) {
    final localizations = AppLocalizations.of(context);
    showError(
      context,
      message: error ?? '${localizations.error}. ${localizations.tryAgainLater}',
    );
  }

  static void showLoadingError(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showError(context, message: localizations.errorLoadingData);
  }

  static void showSaveSuccess(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showSuccess(context, message: localizations.receiptSavedSuccessfully);
  }

  static void showDeleteSuccess(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showSuccess(context, message: localizations.receiptDeletedSuccessfully);
  }

  static void showUpdateSuccess(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showSuccess(context, message: localizations.settingsSavedSuccessfully);
  }
}
