import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Componentes reutilizables del sistema de diseño
class AppComponents {
  // ==================== BUTTONS ====================
  
  /// Botón primario estándar
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isExpanded = true,
    IconData? icon,
    double? height,
    double? fontSize,
    FontWeight? fontWeight,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final buttonHeight = height ?? DesignTokens.buttonHeightLarge;
        
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? theme.colorScheme.primary,
              foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
              elevation: DesignTokens.elevationNone,
              shape: RoundedRectangleBorder(
                borderRadius: DesignTokens.radius(DesignTokens.borderRadiusMd),
              ),
              disabledBackgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
              disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor ?? theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: DesignTokens.iconSizeLg),
                          DesignTokens.gapSm,
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: fontSize ?? DesignTokens.fontSizeLg,
                              fontWeight: fontWeight ?? FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSize ?? DesignTokens.fontSizeLg,
                          fontWeight: fontWeight ?? FontWeight.w600,
                        ),
                      ),
          ),
        );
      },
    );
  }
  
  /// Botón secundario (outlined)
  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isExpanded = true,
    IconData? icon,
    double? height,
    Color? borderColor,
    Color? textColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final buttonHeight = height ?? DesignTokens.buttonHeightLarge;
        final actualBorderColor = borderColor ?? theme.colorScheme.outline;
        final actualTextColor = textColor ?? theme.colorScheme.onSurface;
        
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: actualBorderColor),
              shape: RoundedRectangleBorder(
                borderRadius: DesignTokens.radius(DesignTokens.borderRadiusMd),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(actualTextColor),
                    ),
                  )
                : icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: DesignTokens.iconSizeLg),
                          DesignTokens.gapSm,
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeLg,
                              fontWeight: FontWeight.w600,
                              color: actualTextColor,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeLg,
                          fontWeight: FontWeight.w600,
                          color: actualTextColor,
                        ),
                      ),
          ),
        );
      },
    );
  }

  // ==================== CARDS ====================
  
  /// Card estándar de la aplicación
  static Widget appCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding ?? DesignTokens.paddingAll(DesignTokens.cardPadding),
            decoration: BoxDecoration(
              color: color ?? theme.colorScheme.surface,
              borderRadius: DesignTokens.radius(
                borderRadius ?? DesignTokens.borderRadiusMd,
              ),
              boxShadow: boxShadow,
            ),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Card financiera con icono y monto
  static Widget financialCard({
    required BuildContext context,
    required String title,
    required String amount,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return appCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: DesignTokens.paddingAll(DesignTokens.spacingSm),
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
                  borderRadius: DesignTokens.radius(DesignTokens.borderRadiusSm),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? theme.colorScheme.primary,
                  size: DesignTokens.iconSizeLg,
                ),
              ),
            ],
          ),
          DesignTokens.gapMd,
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          DesignTokens.gapXs,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TEXT FIELDS ====================
  
  /// Campo de texto estándar
  static Widget textField({
    required String label,
    String? hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int? maxLines,
    Color? fillColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: DesignTokens.radius(DesignTokens.borderRadiusMd),
            ),
            filled: true,
            fillColor: fillColor ?? theme.colorScheme.surface.withValues(alpha: 0.5),
          ),
          validator: validator,
        );
      },
    );
  }

  // ==================== LOADING STATES ====================
  
  /// Indicador de carga estándar
  static Widget loadingIndicator({
    Color? color,
    double? size,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Center(
          child: SizedBox(
            width: size ?? DesignTokens.iconSize4xl,
            height: size ?? DesignTokens.iconSize4xl,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Shimmer loading para skeleton screens
  static Widget shimmerLoading({
    required double width,
    required double height,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: DesignTokens.radius(
          borderRadius ?? DesignTokens.borderRadiusSm,
        ),
      ),
    );
  }

  // ==================== EMPTY STATES ====================
  
  /// Estado vacío con icono y mensaje
  static Widget emptyState({
    required String message,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Center(
          child: Padding(
            padding: DesignTokens.paddingAll(DesignTokens.spacing3xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: DesignTokens.iconSize5xl,
                    color: theme.colorScheme.outline,
                  ),
                  DesignTokens.gap2xl,
                ],
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (actionText != null && onAction != null) ...[
                  DesignTokens.gap2xl,
                  primaryButton(
                    text: actionText,
                    onPressed: onAction,
                    isExpanded: false,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== DIALOGS ====================
  
  /// Diálogo estándar
  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: icon != null
            ? Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: DesignTokens.iconSize2xl,
                  ),
                  DesignTokens.gapMd,
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: DesignTokens.fontSizeXl),
                    ),
                  ),
                ],
              )
            : Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
          if (confirmText != null)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              child: Text(confirmText),
            ),
        ],
      ),
    );
  }

  // ==================== DIVIDERS ====================
  
  /// Divider con texto
  static Widget dividerWithText({
    required String text,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final dividerColor = color ?? theme.colorScheme.outline;
        
        return Row(
          children: [
            Expanded(child: Divider(color: dividerColor)),
            Padding(
              padding: DesignTokens.paddingHorizontal(DesignTokens.spacingLg),
              child: Text(
                text,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: DesignTokens.fontSizeSm,
                ),
              ),
            ),
            Expanded(child: Divider(color: dividerColor)),
          ],
        );
      },
    );
  }

  // ==================== BADGES ====================
  
  /// Badge de estado
  static Widget statusBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: DesignTokens.paddingSymmetric(
        horizontal: DesignTokens.spacingMd,
        vertical: DesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: DesignTokens.radius(DesignTokens.borderRadiusCircular),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: DesignTokens.fontSizeSm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
