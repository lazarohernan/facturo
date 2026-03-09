import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Utilidades para hacer la aplicación responsive usando flutter_screenutil
class ResponsiveUtils {
  /// Obtiene el ancho de pantalla responsive
  static double get screenWidth => ScreenUtil().screenWidth;

  /// Obtiene el alto de pantalla responsive
  static double get screenHeight => ScreenUtil().screenHeight;

  /// Obtiene el tamaño de pantalla responsive
  static Size get screenSize =>
      Size(ScreenUtil().screenWidth, ScreenUtil().screenHeight);

  /// Obtiene la densidad de píxeles
  static double get pixelRatio => ScreenUtil().pixelRatio ?? 1.0;

  /// Obtiene el tamaño de estado (status bar)
  static double get statusBarHeight => ScreenUtil().statusBarHeight;

  /// Obtiene el tamaño de navegación (bottom bar)
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  /// Convierte un tamaño a responsive (ancho)
  static double w(double width) => ScreenUtil().setWidth(width);

  /// Convierte un tamaño a responsive (alto)
  static double h(double height) => ScreenUtil().setHeight(height);

  /// Convierte un tamaño de fuente a responsive
  static double sp(double fontSize) => ScreenUtil().setSp(fontSize);

  /// Convierte un radio a responsive
  static double r(double radius) => ScreenUtil().radius(radius);

  /// Convierte un padding a responsive
  static EdgeInsets padding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: w(left),
      top: h(top),
      right: w(right),
      bottom: h(bottom),
    );
  }

  /// Convierte un padding simétrico a responsive
  static EdgeInsets paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: w(horizontal),
      vertical: h(vertical),
    );
  }

  /// Convierte un padding uniforme a responsive
  static EdgeInsets paddingAll(double all) {
    return EdgeInsets.all(w(all));
  }

  /// Convierte un tamaño a responsive
  static Size size(double width, double height) {
    return Size(w(width), h(height));
  }

  /// Convierte un radio de borde a responsive
  static BorderRadius radius(double radius) {
    return BorderRadius.circular(r(radius));
  }

  /// Convierte un radio de borde específico a responsive
  static BorderRadius radiusOnly({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(r(topLeft)),
      topRight: Radius.circular(r(topRight)),
      bottomLeft: Radius.circular(r(bottomLeft)),
      bottomRight: Radius.circular(r(bottomRight)),
    );
  }

  /// Verifica si es una pantalla pequeña (menos de 600px de ancho)
  static bool get isSmallScreen => screenWidth < 600;

  /// Verifica si es una pantalla mediana (entre 600px y 900px de ancho)
  static bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;

  /// Verifica si es una pantalla grande (más de 900px de ancho)
  static bool get isLargeScreen => screenWidth >= 900;

  /// Verifica si es un dispositivo móvil (menos de 600px de ancho)
  static bool get isMobile => screenWidth < 600;

  /// Verifica si es una tablet (entre 600px y 900px de ancho)
  static bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Verifica si es un desktop (más de 900px de ancho)
  static bool get isDesktop => screenWidth >= 900;
}
