import 'package:flutter/material.dart';

/// Definición de colores para la aplicación Facturo
class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFF1E3A8A); // Indigo brand primary
  static const Color primaryContainer = Color(0xFFD6E4FF);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF001C3D);

  // Colores secundarios
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF1E192B);

  // Colores de superficie
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF3F3F3);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454E);

  // Colores de error
  static const Color error = Color(0xFFBA1B1B);
  static const Color errorContainer = Color(0xFFFFDAD4);
  static const Color onError = Colors.white;
  static const Color onErrorContainer = Color(0xFF410001);

  // Colores de fondo
  static const Color background = Colors.white;
  static const Color onBackground = Color(0xFF1C1B1F);

  // Colores de contorno
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Colores para estados de factura
  static const Color paid = Color(0xFF4CAF50);
  static const Color paidContainer = Color(0xFFDFF3DF);
  static const Color unpaid = Color(0xFFF44336);
  static const Color unpaidContainer = Color(0xFFFFE5E3);
  static const Color pending = Color(0xFFFFC107);
  static const Color pendingContainer = Color(0xFFFFF8E1);
  static const Color draft = Color(0xFF9E9E9E);
  static const Color draftContainer = Color(0xFFF5F5F5);

  // Colores para gráficos
  static const List<Color> chartColors = [
    Color(0xFF0066FF), // Azul (primario)
    Color(0xFF4CAF50), // Verde
    Color(0xFFFFC107), // Ámbar
    Color(0xFFF44336), // Rojo
    Color(0xFF9C27B0), // Púrpura
    Color(0xFF00BCD4), // Cian
    Color(0xFF795548), // Marrón
    Color(0xFF607D8B), // Azul grisáceo
  ];

  // Colores para modo oscuro
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);

  // Dark-mode variants for invoice status colors (better contrast on dark backgrounds)
  static const Color darkPending = Color(0xFFFFD54F); // Brighter yellow for dark mode
  static const Color darkPendingContainer = Color(0xFF3E2E00);
  static const Color darkDraft = Color(0xFFBDBDBD); // Lighter gray for dark mode
  static const Color darkDraftContainer = Color(0xFF2D2D2D);

  // ---------------------------------------------------------------------------
  // Adaptive color helpers — return the right color based on current brightness
  // ---------------------------------------------------------------------------

  static Color adaptiveSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurface : const Color(0xFFFFFFFF);
  }

  static Color adaptiveBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBackground : const Color(0xFFFFFFFF);
  }

  static Color adaptiveSurfaceVariant(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurfaceVariant : surfaceVariant;
  }

  static Color adaptivePrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkPrimary : primary;
  }
}

/// Extensión para obtener colores según el estado de la factura
/// Now theme-aware: returns brighter variants in dark mode for better contrast.
extension InvoiceStatusColors on ThemeData {
  bool get _isDark => brightness == Brightness.dark;

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'pagado':
        return AppColors.paid;
      case 'unpaid':
      case 'no pagado':
        return AppColors.unpaid;
      case 'pending':
      case 'pendiente':
        return _isDark ? AppColors.darkPending : AppColors.pending;
      case 'draft':
      case 'borrador':
        return _isDark ? AppColors.darkDraft : AppColors.draft;
      default:
        return _isDark ? AppColors.darkDraft : AppColors.draft;
    }
  }

  Color getStatusContainerColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'pagado':
        return AppColors.paidContainer;
      case 'unpaid':
      case 'no pagado':
        return AppColors.unpaidContainer;
      case 'pending':
      case 'pendiente':
        return _isDark ? AppColors.darkPendingContainer : AppColors.pendingContainer;
      case 'draft':
      case 'borrador':
        return _isDark ? AppColors.darkDraftContainer : AppColors.draftContainer;
      default:
        return _isDark ? AppColors.darkDraftContainer : AppColors.draftContainer;
    }
  }
} 