import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

/// Modal de abajo para elegir cómo guardar el recibo escaneado
class OCRConversionBottomSheet extends StatelessWidget {
  final VoidCallback? onSaveOnly;
  final VoidCallback onConvertToExpense;
  final VoidCallback onConvertToInvoice;

  const OCRConversionBottomSheet({
    super.key,
    this.onSaveOnly,
    required this.onConvertToExpense,
    required this.onConvertToInvoice,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConvertToExpense,
    required VoidCallback onConvertToInvoice,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OCRConversionBottomSheet(
        onConvertToExpense: onConvertToExpense,
        onConvertToInvoice: onConvertToInvoice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Text(
            localizations.saveScannedReceipt,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            localizations.chooseHowToSave,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Save only option
          if (onSaveOnly != null) ...[
            _buildConversionOption(
              context,
              icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.regular),
              title: localizations.saveScannedReceiptOnly,
              subtitle: localizations.saveReceiptOnlyDescription,
              onTap: onSaveOnly!,
            ),
            const SizedBox(height: 16),
          ],
          
          // Expense option
          _buildConversionOption(
            context,
            icon: PhosphorIcons.receipt(PhosphorIconsStyle.regular),
            title: localizations.saveAsExpense,
            subtitle: localizations.convertToExpenseDescription,
            onTap: onConvertToExpense,
          ),
          
          const SizedBox(height: 16),
          
          // Invoice option
          _buildConversionOption(
            context,
            icon: PhosphorIcons.fileText(PhosphorIconsStyle.regular),
            title: localizations.saveAsInvoice,
            subtitle: localizations.convertToInvoiceDescription,
            onTap: onConvertToInvoice,
          ),
        ],
      ),
    );
  }

  Widget _buildConversionOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: theme.colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
