import 'package:facturo/features/invoices/models/invoice_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class InvoiceItemForm extends StatefulWidget {
  final InvoiceItem? item;
  final String? invoiceId;
  final Function(InvoiceItem) onSave;

  const InvoiceItemForm({
    super.key,
    this.item,
    this.invoiceId,
    required this.onSave,
  });

  @override
  State<InvoiceItemForm> createState() => _InvoiceItemFormState();
}

class _InvoiceItemFormState extends State<InvoiceItemForm> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _taxRateController = TextEditingController();

  String _discountType = 'percentage';
  bool _taxable = false;

  double get _unitCost => double.tryParse(_unitCostController.text) ?? 0;
  double get _quantity => double.tryParse(_quantityController.text) ?? 0;
  double get _discountAmount =>
      double.tryParse(_discountAmountController.text) ?? 0;
  double get _taxRate => double.tryParse(_taxRateController.text) ?? 0;

  double get _lineTotal {
    final subtotal = _unitCost * _quantity;

    double discountValue = 0;
    if (_discountAmount > 0) {
      discountValue = _discountType == 'percentage'
          ? subtotal * (_discountAmount / 100)
          : _discountAmount;
    }

    final afterDiscount = subtotal - discountValue;

    double taxValue = 0;
    if (_taxable && _taxRate > 0) {
      taxValue = afterDiscount * (_taxRate / 100);
    }

    return afterDiscount + taxValue;
  }

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _descriptionController.text = widget.item!.description ?? '';
      _unitCostController.text = widget.item!.unitCost?.toString() ?? '0';
      _quantityController.text = widget.item!.quantity?.toString() ?? '1';
      _discountAmountController.text =
          widget.item!.discountAmount?.toString() ?? '0';
      _taxRateController.text = widget.item!.taxRate?.toString() ?? '0';
      _discountType = widget.item!.discountType ?? 'percentage';
      _taxable = widget.item!.taxable ?? false;
    } else {
      _unitCostController.text = '0';
      _quantityController.text = '1';
      _discountAmountController.text = '0';
      _taxRateController.text = '0';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _unitCostController.dispose();
    _quantityController.dispose();
    _discountAmountController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = InvoiceItem(
        invoiceId: widget.invoiceId,
        description: _descriptionController.text,
        unitCost: double.tryParse(_unitCostController.text),
        quantity: double.tryParse(_quantityController.text),
        discountType: _discountType,
        discountAmount: double.tryParse(_discountAmountController.text),
        taxable: _taxable,
        taxRate: _taxable ? double.tryParse(_taxRateController.text) : 0,
      );

      widget.onSave(item);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isNew = widget.item == null;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + viewInsets),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Indicador de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Cabecera
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isNew ? localizations.addItem : localizations.editItem,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: localizations.descriptionLabel,
                  hintText: localizations.descriptionHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.descriptionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Unit Cost and Quantity
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitCostController,
                      decoration: InputDecoration(
                        labelText: '${localizations.unitPriceLabel} *',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.required;
                        }
                        if (double.tryParse(value) == null) {
                          return localizations.invalidNumber;
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: '${localizations.quantityLabel} *',
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.required;
                        }
                        if (double.tryParse(value) == null) {
                          return localizations.invalidNumber;
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Discount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountAmountController,
                      decoration: InputDecoration(
                        labelText: localizations.discountLabel,
                        prefixIcon: const Icon(Icons.discount_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _discountType,
                      decoration: InputDecoration(
                        labelText: localizations.typeLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'percentage',
                          child: Text('%'),
                        ),
                        DropdownMenuItem(
                          value: 'fixed',
                          child: Text(localizations.fixed),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _discountType = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tax
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _taxable,
                    onChanged: (value) {
                      setState(() {
                        _taxable = value ?? false;
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                  Text(localizations.taxable),
                  if (_taxable) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _taxRateController,
                        decoration: InputDecoration(
                          labelText: localizations.taxRateLabel,
                          prefixIcon: const Icon(Icons.percent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                        validator: (value) {
                          if (_taxable && (value == null || value.isEmpty)) {
                            return localizations.required;
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Total
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.totalLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '\$${_lineTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveItem,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(isNew ? localizations.addItem : localizations.saveChanges),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
