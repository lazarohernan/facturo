import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.padding,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  const PrimaryButton.icon({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.padding,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  const PrimaryButton.compact({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      minimumSize: isExpanded ? const Size(double.infinity, 0) : null,
      disabledBackgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
      disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
    );

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: fontSize! + 2),
                  const SizedBox(width: 8),
                  Text(text, style: textStyle),
                ],
              )
            : Text(text, style: textStyle);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: content,
    );
  }
}

// Specific button for common actions
class AddButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  const AddButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton.icon(
      text: text,
      icon: PhosphorIcons.plus(PhosphorIconsStyle.regular),
      onPressed: onPressed,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }
}

// Secondary button variant
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? color;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.secondary;
    
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor.withValues(alpha: 0.1),
      foregroundColor: buttonColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: buttonColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      elevation: 0,
      minimumSize: isExpanded ? const Size(double.infinity, 0) : null,
    );

    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(buttonColor),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: content,
    );
  }
}
