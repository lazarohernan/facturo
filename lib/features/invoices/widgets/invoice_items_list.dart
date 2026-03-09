import 'package:facturo/core/theme/app_colors.dart';
import 'package:facturo/features/invoices/models/invoice_item_model.dart';
import 'package:flutter/material.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class InvoiceItemsList extends StatefulWidget {
  final List<InvoiceItem> items;
  final Function(InvoiceItem)? onItemEdit;
  final Function(int)? onItemDelete;
  final VoidCallback? onAddItem;
  final bool isReadOnly;

  const InvoiceItemsList({
    super.key,
    required this.items,
    this.onItemEdit,
    this.onItemDelete,
    this.onAddItem,
    this.isReadOnly = false,
  });

  @override
  State<InvoiceItemsList> createState() => _InvoiceItemsListState();
}

class _InvoiceItemsListState extends State<InvoiceItemsList> {
  double _subtotal = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateSubtotal();
  }

  @override
  void didUpdateWidget(InvoiceItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _calculateSubtotal();
    }
  }

  void _calculateSubtotal() {
    _subtotal = widget.items.fold(
      0.0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  void _confirmDelete(InvoiceItem item, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(AppLocalizations.of(context).deleteItem),
        content: Text(AppLocalizations.of(context).deleteItemConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onItemDelete?.call(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).itemsLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${AppLocalizations.of(context).subtotalLabel}: \$${_subtotal.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (widget.items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context).noItemsAdded),
                  const SizedBox(height: 16),
                  if (!widget.isReadOnly && widget.onAddItem != null)
                    ElevatedButton.icon(
                      onPressed: widget.onAddItem,
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context).addItem),
                    ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _buildItemCard(context, item, index, theme);
            },
          ),
        const SizedBox(height: 16),
        if (!widget.isReadOnly && widget.items.isNotEmpty && widget.onAddItem != null)
          Center(
            child: ElevatedButton.icon(
              onPressed: widget.onAddItem,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).addItem),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    InvoiceItem item,
    int index,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.of(context).quantityLabel}: ${item.quantity} × \$${item.unitCost?.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (item.discountAmount != null && item.discountAmount! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context).discountLabel}: ${item.discountAmount}${item.discountType == 'percentage' ? '%' : ' USD'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.paid,
                          ),
                        ),
                      ],
                      if (item.taxable == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context).taxLabel}: ${AppLocalizations.of(context).applicable}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.lineTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!widget.isReadOnly)
                      Row(
                        children: [
                          IconButton(
                            onPressed: widget.onItemEdit != null ? () => widget.onItemEdit!(item) : null,
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            visualDensity: VisualDensity.compact,
                            tooltip: AppLocalizations.of(context).edit,
                            style: IconButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _confirmDelete(item, index),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            visualDensity: VisualDensity.compact,
                            tooltip: AppLocalizations.of(context).delete,
                            style: IconButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
