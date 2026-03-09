import 'package:flutter/material.dart';

/// Design Tokens - Sistema centralizado de valores de diseño
/// Basado en AppSizes existente pero con capacidad responsive
class DesignTokens {
  // ==================== SPACING ====================
  
  /// Espaciado extra pequeño: 4px
  static const double spacingXs = 4.0;
  
  /// Espaciado pequeño: 8px
  static const double spacingSm = 8.0;
  
  /// Espaciado mediano: 12px
  static const double spacingMd = 12.0;
  
  /// Espaciado grande: 16px
  static const double spacingLg = 16.0;
  
  /// Espaciado extra grande: 20px
  static const double spacingXl = 20.0;
  
  /// Espaciado 2xl: 24px
  static const double spacing2xl = 24.0;
  
  /// Espaciado 3xl: 32px
  static const double spacing3xl = 32.0;
  
  /// Espaciado 4xl: 48px
  static const double spacing4xl = 48.0;
  
  /// Espaciado 5xl: 64px
  static const double spacing5xl = 64.0;

  // ==================== PADDING ====================
  
  /// Padding de card estándar: 16px
  static const double cardPadding = 16.0;
  
  /// Padding de página estándar: 24px
  static const double pagePadding = 24.0;
  
  /// Padding pequeño: 8px
  static const double paddingSmall = 8.0;
  
  /// Padding grande: 32px
  static const double paddingLarge = 32.0;

  // ==================== BORDER RADIUS ====================
  
  /// Border radius extra pequeño: 4px
  static const double borderRadiusXs = 4.0;
  
  /// Border radius pequeño: 8px
  static const double borderRadiusSm = 8.0;
  
  /// Border radius mediano: 12px
  static const double borderRadiusMd = 12.0;
  
  /// Border radius grande: 16px
  static const double borderRadiusLg = 16.0;
  
  /// Border radius extra grande: 24px
  static const double borderRadiusXl = 24.0;
  
  /// Border radius circular: 100px
  static const double borderRadiusCircular = 100.0;

  // ==================== ICON SIZES ====================
  
  /// Tamaño de icono extra pequeño: 12px
  static const double iconSizeXs = 12.0;
  
  /// Tamaño de icono pequeño: 16px
  static const double iconSizeSm = 16.0;
  
  /// Tamaño de icono mediano: 20px
  static const double iconSizeMd = 20.0;
  
  /// Tamaño de icono grande: 24px
  static const double iconSizeLg = 24.0;
  
  /// Tamaño de icono extra grande: 28px
  static const double iconSizeXl = 28.0;
  
  /// Tamaño de icono 2xl: 32px
  static const double iconSize2xl = 32.0;
  
  /// Tamaño de icono 3xl: 36px
  static const double iconSize3xl = 36.0;
  
  /// Tamaño de icono 4xl: 48px
  static const double iconSize4xl = 48.0;
  
  /// Tamaño de icono 5xl: 64px
  static const double iconSize5xl = 64.0;

  // ==================== BUTTON SIZES ====================
  
  /// Altura de botón estándar: 48px
  static const double buttonHeight = 48.0;
  
  /// Altura de botón pequeño: 36px
  static const double buttonHeightSmall = 36.0;
  
  /// Altura de botón grande: 52px
  static const double buttonHeightLarge = 52.0;
  
  /// Altura de botón extra grande: 56px
  static const double buttonHeightXl = 56.0;

  // ==================== FONT SIZES ====================
  
  /// Tamaño de fuente extra pequeño: 10px
  static const double fontSizeXs = 10.0;
  
  /// Tamaño de fuente pequeño: 12px
  static const double fontSizeSm = 12.0;
  
  /// Tamaño de fuente mediano: 14px
  static const double fontSizeMd = 14.0;
  
  /// Tamaño de fuente grande: 16px
  static const double fontSizeLg = 16.0;
  
  /// Tamaño de fuente extra grande: 18px
  static const double fontSizeXl = 18.0;
  
  /// Tamaño de fuente 2xl: 20px
  static const double fontSize2xl = 20.0;
  
  /// Tamaño de fuente 3xl: 24px
  static const double fontSize3xl = 24.0;
  
  /// Tamaño de fuente 4xl: 28px
  static const double fontSize4xl = 28.0;

  // ==================== GAPS (SizedBox predefinidos) ====================
  
  /// Gap extra pequeño: 4px
  static const SizedBox gapXs = SizedBox(height: spacingXs, width: spacingXs);
  
  /// Gap pequeño: 8px
  static const SizedBox gapSm = SizedBox(height: spacingSm, width: spacingSm);
  
  /// Gap mediano: 12px
  static const SizedBox gapMd = SizedBox(height: spacingMd, width: spacingMd);
  
  /// Gap grande: 16px
  static const SizedBox gapLg = SizedBox(height: spacingLg, width: spacingLg);
  
  /// Gap extra grande: 20px
  static const SizedBox gapXl = SizedBox(height: spacingXl, width: spacingXl);
  
  /// Gap 2xl: 24px
  static const SizedBox gap2xl = SizedBox(height: spacing2xl, width: spacing2xl);
  
  /// Gap 3xl: 32px
  static const SizedBox gap3xl = SizedBox(height: spacing3xl, width: spacing3xl);
  
  /// Gap 4xl: 48px
  static const SizedBox gap4xl = SizedBox(height: spacing4xl, width: spacing4xl);
  
  /// Gap 5xl: 64px
  static const SizedBox gap5xl = SizedBox(height: spacing5xl, width: spacing5xl);

  // ==================== ELEVATION ====================
  
  /// Sin elevación
  static const double elevationNone = 0.0;
  
  /// Elevación pequeña: 2px
  static const double elevationSm = 2.0;
  
  /// Elevación mediana: 4px
  static const double elevationMd = 4.0;
  
  /// Elevación grande: 8px
  static const double elevationLg = 8.0;
  
  /// Elevación extra grande: 16px
  static const double elevationXl = 16.0;

  // ==================== HELPER METHODS ====================
  
  /// Retorna EdgeInsets con padding uniforme
  static EdgeInsets paddingAll(double value) => EdgeInsets.all(value);
  
  /// Retorna EdgeInsets con padding horizontal
  static EdgeInsets paddingHorizontal(double value) => 
      EdgeInsets.symmetric(horizontal: value);
  
  /// Retorna EdgeInsets con padding vertical
  static EdgeInsets paddingVertical(double value) => 
      EdgeInsets.symmetric(vertical: value);
  
  /// Retorna EdgeInsets con padding simétrico
  static EdgeInsets paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) => EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  
  /// Retorna EdgeInsets con padding específico
  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  
  /// Retorna BorderRadius circular
  static BorderRadius radius(double value) => BorderRadius.circular(value);
  
  /// Retorna BorderRadius con valores específicos
  static BorderRadius radiusOnly({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      );
  
  /// Gap horizontal
  static SizedBox gapHorizontal(double width) => SizedBox(width: width);
  
  /// Gap vertical
  static SizedBox gapVertical(double height) => SizedBox(height: height);
}
