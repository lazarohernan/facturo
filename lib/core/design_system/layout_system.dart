import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Tipos de dispositivo según tamaño de pantalla
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Sistema de layout responsive centralizado
class LayoutSystem {
  // ==================== BREAKPOINTS ====================
  
  /// Breakpoint para móvil: < 600px
  static const double mobileBreakpoint = 600;
  
  /// Breakpoint para tablet: < 900px
  static const double tabletBreakpoint = 900;
  
  /// Breakpoint para desktop: < 1200px
  static const double desktopBreakpoint = 1200;

  // ==================== DEVICE TYPE DETECTION ====================
  
  /// Obtiene el tipo de dispositivo según el ancho de pantalla
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }
  
  /// Verifica si es móvil
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }
  
  /// Verifica si es tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }
  
  /// Verifica si es desktop
  static bool isDesktop(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.desktop || type == DeviceType.largeDesktop;
  }

  // ==================== RESPONSIVE SPACING ====================
  
  /// Obtiene el espaciado adaptativo según el dispositivo
  static double getSpacing(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => DesignTokens.spacingMd,
      DeviceType.tablet => DesignTokens.spacingLg,
      DeviceType.desktop => DesignTokens.spacingXl,
      DeviceType.largeDesktop => DesignTokens.spacing2xl,
    };
  }
  
  /// Obtiene el padding horizontal adaptativo
  static double getHorizontalPadding(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => DesignTokens.spacingLg,
      DeviceType.tablet => DesignTokens.spacing2xl,
      DeviceType.desktop => DesignTokens.spacing3xl,
      DeviceType.largeDesktop => DesignTokens.spacing4xl,
    };
  }
  
  /// Obtiene el padding vertical adaptativo
  static double getVerticalPadding(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => DesignTokens.spacingLg,
      DeviceType.tablet => DesignTokens.spacingXl,
      DeviceType.desktop => DesignTokens.spacing2xl,
      DeviceType.largeDesktop => DesignTokens.spacing2xl,
    };
  }
  
  /// Obtiene el padding de contenido adaptativo
  static EdgeInsets getContentPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  // ==================== RESPONSIVE TYPOGRAPHY ====================
  
  /// Obtiene el tamaño de fuente para títulos
  static double getTitleFontSize(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => DesignTokens.fontSizeXl,
      DeviceType.tablet => DesignTokens.fontSize2xl,
      DeviceType.desktop => DesignTokens.fontSize3xl,
      DeviceType.largeDesktop => DesignTokens.fontSize4xl,
    };
  }
  
  /// Obtiene el tamaño de fuente para subtítulos
  static double getSubtitleFontSize(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => DesignTokens.fontSizeMd,
      DeviceType.tablet => DesignTokens.fontSizeLg,
      DeviceType.desktop => DesignTokens.fontSizeXl,
      DeviceType.largeDesktop => DesignTokens.fontSize2xl,
    };
  }
  
  /// Obtiene el tamaño de fuente para cuerpo de texto
  static double getBodyFontSize(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => DesignTokens.fontSizeMd,
      DeviceType.tablet => DesignTokens.fontSizeMd,
      DeviceType.desktop => DesignTokens.fontSizeLg,
      DeviceType.largeDesktop => DesignTokens.fontSizeLg,
    };
  }

  // ==================== RESPONSIVE COMPONENTS ====================
  
  /// Obtiene el ancho máximo del contenido
  static double getMaxContentWidth(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => double.infinity,
      DeviceType.tablet => 768,
      DeviceType.desktop => 1024,
      DeviceType.largeDesktop => 1280,
    };
  }
  
  /// Obtiene el ancho mínimo de una card
  static double getMinCardWidth(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => 150,
      DeviceType.tablet => 200,
      DeviceType.desktop => 250,
      DeviceType.largeDesktop => 300,
    };
  }
  
  /// Obtiene el aspect ratio para grids
  static double getGridChildAspectRatio(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => 1.0,
      DeviceType.tablet => 1.2,
      DeviceType.desktop => 1.3,
      DeviceType.largeDesktop => 1.4,
    };
  }
  
  /// Obtiene la altura de botón adaptativa
  static double getButtonHeight(BuildContext context) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => DesignTokens.buttonHeight,
      DeviceType.tablet => DesignTokens.buttonHeightLarge,
      DeviceType.desktop => DesignTokens.buttonHeightLarge,
      DeviceType.largeDesktop => DesignTokens.buttonHeightXl,
    };
  }

  // ==================== LAYOUT BUILDERS ====================
  
  /// Layout de página con padding responsive
  static Widget pageLayout({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getMaxContentWidth(context),
        ),
        child: Padding(
          padding: getContentPadding(context),
          child: child,
        ),
      ),
    );
  }
  
  /// Grid responsive que calcula columnas automáticamente
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double? spacing,
    double? childAspectRatio,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(context);
        final actualSpacing = spacing ?? getSpacing(context);
        
        int crossAxisCount = switch (deviceType) {
          DeviceType.mobile => mobileColumns ?? 2,
          DeviceType.tablet => tabletColumns ?? 3,
          DeviceType.desktop => desktopColumns ?? 4,
          DeviceType.largeDesktop => desktopColumns ?? 4,
        };
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio ?? getGridChildAspectRatio(context),
          crossAxisSpacing: actualSpacing,
          mainAxisSpacing: actualSpacing,
          children: children,
        );
      },
    );
  }
  
  /// Layout adaptativo según tipo de dispositivo
  static Widget adaptive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return switch (getDeviceType(context)) {
      DeviceType.mobile => mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.desktop => desktop ?? tablet ?? mobile,
      DeviceType.largeDesktop => desktop ?? tablet ?? mobile,
    };
  }
  
  /// Sección con título y contenido
  static Widget sectionLayout({
    required BuildContext context,
    String? title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: getTitleFontSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: getSpacing(context)),
        ],
        child,
      ],
    );
  }

  // ==================== UTILITY METHODS ====================
  
  /// Formatea números grandes de manera inteligente
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    if (amount.abs() >= 1000000000) {
      return '$symbol${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }
  
  /// Obtiene el número de columnas óptimo para un ancho dado
  static int getOptimalColumns(BuildContext context, double availableWidth) {
    final minCardWidth = getMinCardWidth(context);
    final spacing = getSpacing(context);
    int columns = (availableWidth / (minCardWidth + spacing)).floor();
    return columns.clamp(1, 4);
  }
}
