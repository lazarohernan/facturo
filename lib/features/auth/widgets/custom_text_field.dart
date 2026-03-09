import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool enabled;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.enabled = true,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: label,
      textField: true,
      enabled: enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            validator: validator,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon,
              filled: true,
              fillColor: enabled
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
