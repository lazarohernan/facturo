import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Tipos de triggers para mostrar el prompt de registro
enum RegistrationTrigger {
  /// Después de crear la primera factura
  firstInvoice,
  /// Después de 5 días de uso
  timeBasedEngagement,
}

/// Dialog para promover el registro de usuarios anónimos
/// Basado en mejores prácticas de UX para conversión freemium
class RegistrationPromptDialog extends StatelessWidget {
  final RegistrationTrigger trigger;
  final VoidCallback? onDismiss;
  final VoidCallback? onRegister;

  const RegistrationPromptDialog({
    super.key,
    required this.trigger,
    this.onDismiss,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final data = _getTriggerData(trigger, theme, l10n);
    
    // Modern minimalist decoration
    final dialogDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      color: theme.colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withValues(alpha: 0.1),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ],
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: dialogDecoration,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Icono centralizado y limpio
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                color: data.color,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            // Título
            Text(
              data.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              data.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            if (data.benefits.isNotEmpty) ...[
              const SizedBox(height: 20),
              Column(
                children: data.benefits.map((benefit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            PhosphorIcons.check(PhosphorIconsStyle.regular),
                            color: data.color,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            benefit,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 13, 
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Botón principal
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  onRegister?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: data.color,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(data.ctaText),
              ),
            ),

            const SizedBox(height: 8),

            // Botón secundario
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: Text(
                data.dismissText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  _TriggerData _getTriggerData(RegistrationTrigger trigger, ThemeData theme, AppLocalizations l10n) {
    switch (trigger) {
      case RegistrationTrigger.firstInvoice:
        return _TriggerData(
          icon: PhosphorIcons.fileText(PhosphorIconsStyle.regular),
          color: Colors.green,
          emoji: '🎉',
          showCelebration: true,
          title: l10n.regPromptFirstInvoiceTitle,
          subtitle: l10n.regPromptFirstInvoiceSubtitle,
          benefits: [
            l10n.regPromptFirstInvoiceBenefit1,
            l10n.regPromptFirstInvoiceBenefit2,
            l10n.regPromptFirstInvoiceBenefit3,
          ],
          ctaText: l10n.regPromptFirstInvoiceCta,
          ctaIcon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.regular),
          dismissText: l10n.regPromptFirstInvoiceDismiss,
        );
      case RegistrationTrigger.timeBasedEngagement:
        return _TriggerData(
          icon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
          color: theme.colorScheme.primary,
          emoji: '🕒',
          showCelebration: false,
          title: l10n.regPromptTimeTitle,
          subtitle: l10n.regPromptTimeSubtitle,
          benefits: [],
          ctaText: l10n.regPromptTimeCta,
          ctaIcon: PhosphorIcons.userPlus(PhosphorIconsStyle.regular),
          dismissText: l10n.regPromptTimeDismiss,
        );
    }
  }

  /// Muestra el dialog de registro
  static Future<void> show(
    BuildContext context, {
    required RegistrationTrigger trigger,
    VoidCallback? onDismiss,
    VoidCallback? onRegister,
  }) async {
    if (!context.mounted) return;
    
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => RegistrationPromptDialog(
        trigger: trigger,
        onDismiss: onDismiss,
        onRegister: () async {
          Navigator.of(dialogContext).pop();
          // Esperar a que el pop termine antes de navegar
          await Future.delayed(const Duration(milliseconds: 100));
          if (onRegister != null) {
            onRegister();
          } else if (context.mounted) {
            context.push('/auth/convert');
          }
        },
      ),
    );
  }
}

class _TriggerData {
  final IconData icon;
  final Color color;
  final String emoji;
  final bool showCelebration;
  final String title;
  final String subtitle;
  final List<String> benefits;
  final String ctaText;
  final IconData ctaIcon;
  final String dismissText;

  _TriggerData({
    required this.icon,
    required this.color,
    required this.emoji,
    required this.showCelebration,
    required this.title,
    required this.subtitle,
    required this.benefits,
    required this.ctaText,
    required this.ctaIcon,
    required this.dismissText,
  });
}
