/// Design System - Sistema de diseño centralizado para Facturo
/// 
/// Este archivo exporta todos los componentes del design system:
/// - DesignTokens: Valores de diseño (spacing, colores, tamaños)
/// - LayoutSystem: Sistema de layout responsive
/// - AppComponents: Componentes reutilizables
/// 
/// Uso:
/// ```dart
/// import 'package:facturo/core/design_system/design_system.dart';
/// 
/// // Usar tokens
/// padding: DesignTokens.paddingAll(DesignTokens.cardPadding)
/// 
/// // Usar componentes
/// AppComponents.primaryButton(text: 'Save', onPressed: onSave)
/// 
/// // Usar layout system
/// LayoutSystem.pageLayout(context: context, child: myWidget)
/// ```

library design_system;

export 'design_tokens.dart';
export 'layout_system.dart';
export 'app_components.dart';
