import 'package:flutter/material.dart';

/// Paleta de colores corporativa para los iconos del perfil
/// Basada en el color primario azul de la plataforma (0xFF1F3A93)
/// Diseñada para mantener un aspecto profesional y corporativo
class ProfileColors {
  // Color primario base (azul profundo de la app)
  static const Color primaryBlue = Color(0xFF1F3A93);

  // Paleta corporativa basada en azules y grises
  static const Color blueLight = Color(0xFF4A90E2); // Azul claro profesional
  static const Color blueMedium = Color(0xFF2E5BBA); // Azul medio corporativo
  static const Color blueDark = Color(0xFF1E3A8A); // Azul oscuro elegante

  // Colores neutros corporativos
  static const Color slate = Color(0xFF64748B); // Gris azulado neutro
  static const Color gray = Color(0xFF6B7280); // Gris corporativo
  static const Color zinc = Color(0xFF71717A); // Gris zinc elegante

  // Colores de acento sutiles y profesionales
  static const Color business = Color(0xFF3D5AFE); // Azul brillante visible en modo oscuro
  static const Color edit = Color(0xFF059669); // Verde azulado corporativo
  static const Color notifications = Color(0xFFD97706); // Ámbar corporativo
  static const Color language = Color(0xFF0891B2); // Azul verdoso profesional
  static const Color support = Color(0xFF0891B2); // Azul verdoso para soporte
  static const Color rating = Color(0xFFD97706); // Ámbar corporativo
  static const Color processing = Color(0xFFF59E0B); // Amarillo dorado profesional para procesamiento
  static const Color logout = Color(0xFFDC2626); // Rojo corporativo
  static const Color theme = Color(0xFF7C3AED); // Violeta corporativo
  static const Color subscription =
      Color(0xFF059669); // Verde azulado corporativo

  // Colores para estados corporativos
  static const Color success = Color(0xFF059669); // Verde azulado éxito
  static const Color warning =
      Color(0xFFD97706); // Ámbar corporativo advertencia
  static const Color error = Color(0xFFDC2626); // Rojo corporativo error
  static const Color info = Color(0xFF1F3A93); // Azul primario información

  /// Obtiene un color de la paleta basado en el índice
  /// Útil para asignar colores automáticamente
  static Color getColorByIndex(int index) {
    final colors = [
      primaryBlue,
      blueLight,
      blueMedium,
      slate,
      gray,
      zinc,
      business,
      edit,
      notifications,
      processing,
      language,
    ];
    return colors[index % colors.length];
  }

  /// Obtiene un color específico para cada funcionalidad del perfil
  static Color getColorForFeature(String feature) {
    switch (feature.toLowerCase()) {
      case 'business':
      case 'businessinfo':
        return business;
      case 'edit':
      case 'digitalsignature':
        return edit;
      case 'notifications':
        return notifications;
      case 'processing':
      case 'receipt':
      case 'ocr':
        return processing;
      case 'language':
      case 'languageregion':
        return language;
      case 'support':
      case 'contactsupport':
        return support;
      case 'rating':
      case 'rateus':
        return rating;
      case 'logout':
        return logout;
      case 'theme':
        return theme;
      case 'subscription':
      case 'upgradetopro':
        return subscription;
      default:
        return primaryBlue;
    }
  }
}
