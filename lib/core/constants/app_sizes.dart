import 'package:flutter/material.dart';
import 'package:facturo/core/utils/responsive_utils.dart';

/// Constantes de tamaño para mantener consistencia en toda la aplicación
class AppSizes {
  // Espaciado
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Bordes redondeados
  static const double borderRadiusXs = 4.0;
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXl = 24.0;
  static const double borderRadiusCircular = 100.0;

  // Tamaños de botones
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonIconSize = 24.0;
  static const double buttonIconSizeSmall = 18.0;

  // Tamaños de iconos
  static const double iconSizeXs = 12.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXl = 48.0;
  static const double iconSizeXxl = 64.0;

  // Tamaños de avatar
  static const double avatarSizeS = 32.0;
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXl = 96.0;

  // Tamaños de tarjetas
  static const double cardElevation = 0.0;
  static const double cardBorderWidth = 1.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(m);
  static const EdgeInsets cardPaddingDense = EdgeInsets.all(s);

  // Tamaños de inputs
  static const double inputHeight = 48.0;
  static const double inputBorderWidth = 1.0;
  static const double inputBorderRadius = 12.0;
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: m,
    vertical: s,
  );

  // Tamaños de texto
  static const double fontSizeXs = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeXxxl = 24.0;

  // Tamaños de pantalla responsivos
  static const double screenWidthXs = 360.0;
  static const double screenWidthS = 480.0;
  static const double screenWidthM = 768.0;
  static const double screenWidthL = 1024.0;
  static const double screenWidthXl = 1440.0;

  // Márgenes de página
  static const EdgeInsets pageMargin = EdgeInsets.all(m);
  static const EdgeInsets pageMarginHorizontal =
      EdgeInsets.symmetric(horizontal: m);
  static const EdgeInsets pageMarginVertical =
      EdgeInsets.symmetric(vertical: m);

  // Otros
  static const double dividerHeight = 1.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 80.0;
  static const double fabSize = 56.0;

  // Métodos responsivos
  static double responsiveW(double width) => ResponsiveUtils.w(width);
  static double responsiveH(double height) => ResponsiveUtils.h(height);
  static double responsiveSp(double fontSize) => ResponsiveUtils.sp(fontSize);
  static double responsiveR(double radius) => ResponsiveUtils.r(radius);

  static EdgeInsets responsivePadding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      ResponsiveUtils.padding(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );

  static EdgeInsets responsivePaddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      ResponsiveUtils.paddingSymmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  static EdgeInsets responsivePaddingAll(double all) =>
      ResponsiveUtils.paddingAll(all);
  static BorderRadius responsiveRadius(double radius) =>
      ResponsiveUtils.radius(radius);
}

/// Extensión para obtener tamaños responsivos basados en el tamaño de pantalla
extension ResponsiveSizes on BuildContext {
  bool get isExtraSmallScreen => ResponsiveUtils.isSmallScreen;
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen;
  bool get isMediumScreen => ResponsiveUtils.isMediumScreen;
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen;
  bool get isExtraLargeScreen => ResponsiveUtils.isLargeScreen;

  double get screenWidth => ResponsiveUtils.screenWidth;
  double get screenHeight => ResponsiveUtils.screenHeight;

  EdgeInsets get responsivePageMargin {
    if (isSmallScreen) {
      return AppSizes.responsivePaddingAll(AppSizes.s);
    } else if (isMediumScreen) {
      return AppSizes.responsivePaddingAll(AppSizes.m);
    } else {
      return AppSizes.responsivePaddingAll(AppSizes.l);
    }
  }
}
