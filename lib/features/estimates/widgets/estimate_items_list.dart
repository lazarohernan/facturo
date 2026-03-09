import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:facturo/features/estimates/widgets/estimate_item_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class EstimateItemsList extends ConsumerStatefulWidget {
  final String estimateId;
  final List<EstimateDetail> items;
  final Function(List<EstimateDetail>) onItemsChanged;
  final double? generalDiscount;
  final String? generalDiscountType;
  final double? generalTax;
  final String? generalTaxType;

  const EstimateItemsList({
    super.key,
    required this.estimateId,
    required this.items,
    required this.onItemsChanged,
    this.generalDiscount,
    this.generalDiscountType,
    this.generalTax,
    this.generalTaxType,
  });

  @override
  ConsumerState<EstimateItemsList> createState() => _EstimateItemsListState();
}

class _EstimateItemsListState extends ConsumerState<EstimateItemsList> {
  late List<EstimateDetail> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(EstimateItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List.from(widget.items);
    }
  }

  // Método para calcular el total de línea para cada ítem
  double _calculateLineTotal(EstimateDetail item) {
    double quantity = item.quantity ?? 0;
    double unitCost = item.unitCost ?? 0;
    double total = quantity * unitCost;

    // Aplicar descuento si está disponible
    if (item.discountAmount != null && item.discountAmount! > 0) {
      if (item.discountType == 'percentage') {
        total = total - (total * (item.discountAmount! / 100));
      } else {
        total = total - item.discountAmount!;
      }
    }

    return total;
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => EstimateItemForm(
            estimateId: widget.estimateId,
            onSave: (item) {
              setState(() {
                final updatedItems = List<EstimateDetail>.from(_items);
                updatedItems.add(item);
                _items = updatedItems;
                widget.onItemsChanged(_items);
              });
            },
          ),
    );
  }

  void _showEditItemDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => EstimateItemForm(
            estimateId: widget.estimateId,
            item: _items[index],
            onSave: (item) {
              setState(() {
                final updatedItems = List<EstimateDetail>.from(_items);
                updatedItems[index] = item;
                _items = updatedItems;
                widget.onItemsChanged(_items);
              });
            },
          ),
    );
  }

  void _removeItem(int index) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.deleteItem),
            content: Text(localizations.deleteItemConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    final updatedItems = List<EstimateDetail>.from(_items);
                    updatedItems.removeAt(index);
                    _items = updatedItems;
                    widget.onItemsChanged(_items);
                  });
                },
                child: Text(
                  localizations.delete,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + _calculateLineTotal(item));
  }

  double get _discountAmount {
    if (widget.generalDiscount == null || widget.generalDiscount == 0) {
      return 0;
    }

    if (widget.generalDiscountType == 'percentage') {
      return _subtotal * (widget.generalDiscount! / 100);
    } else {
      return widget.generalDiscount!;
    }
  }

  double get _taxAmount {
    if (widget.generalTax == null || widget.generalTax == 0) {
      return 0;
    }

    final afterDiscount = _subtotal - _discountAmount;

    if (widget.generalTaxType == 'percentage') {
      return afterDiscount * (widget.generalTax! / 100);
    } else {
      return widget.generalTax!;
    }
  }

  double get _totalAmount {
    return _subtotal - _discountAmount + _taxAmount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row - Simplified for mobile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(localizations.description)),
              Expanded(child: Text(localizations.detail, textAlign: TextAlign.right)),
              const SizedBox(width: 48), // Space for action buttons
            ],
          ),
        ),
        const Divider(),

        // Items List
        _items.isEmpty
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  localizations.noItemsAdded,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item description row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side: Description
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.description ?? localizations.noDescription,
                                    style: theme.textTheme.titleMedium,
                                  ),

                                  // Additional details if any
                                  if (item.additionalDetails != null &&
                                      item.additionalDetails!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        item.additionalDetails!,
                                        style: theme.textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  // Badges row for discount
                                  if (item.discountAmount != null &&
                                      item.discountAmount! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.discountType == 'percentage'
                                              ? '${item.discountAmount}% ${localizations.discountOff}'
                                              : '\$${item.discountAmount?.toStringAsFixed(2)} ${localizations.discountOff}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Right side: Pricing details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Quantity x Price
                                Text(
                                  '${item.quantity?.toStringAsFixed(item.quantity?.truncateToDouble() == item.quantity ? 0 : 1) ?? '0'} x \$${item.unitCost?.toStringAsFixed(2) ?? '0.00'}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                // Total
                                Text(
                                  '\$${_calculateLineTotal(item).toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Actions row
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit, size: 16),
                                label: Text(localizations.edit),
                                onPressed: () => _showEditItemDialog(index),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: theme.colorScheme.error,
                                ),
                                label: Text(
                                  localizations.delete,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                onPressed: () => _removeItem(index),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

        // Subtotal, Tax, Discount, and Total Card
        if (_items.isNotEmpty)
          Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(localizations.subtotal),
                      Text('\$${_subtotal.toStringAsFixed(2)}'),
                    ],
                  ),

                  // Discount (if any)
                  if (widget.generalDiscount != null &&
                      widget.generalDiscount! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${localizations.discountLabel} (${widget.generalDiscountType == 'percentage' ? '${widget.generalDiscount}%' : localizations.fixed}):',
                          ),
                          Text(
                            '-\$${_discountAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                  // Tax (if any)
                  if (widget.generalTax != null && widget.generalTax! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${localizations.taxLabel} (${widget.generalTaxType == 'percentage' ? '${widget.generalTax}%' : localizations.fixed}):',
                          ),
                          Text('+\$${_taxAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),

                  // Divider before total
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.totalLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Add Item Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add),
            label: Text(localizations.addItem),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
