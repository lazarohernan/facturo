import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:flutter/material.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class EstimateItemForm extends StatefulWidget {
  final String estimateId;
  final EstimateDetail? item;
  final Function(EstimateDetail) onSave;

  const EstimateItemForm({
    super.key,
    required this.estimateId,
    this.item,
    required this.onSave,
  });

  @override
  State<EstimateItemForm> createState() => _EstimateItemFormState();
}

class _EstimateItemFormState extends State<EstimateItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _additionalDetailsController = TextEditingController();

  bool _isTaxable = false;
  String _discountType = 'percentage';

  @override
  void initState() {
    super.initState();
    // Initialize form if editing an existing item
    if (widget.item != null) {
      _descriptionController.text = widget.item!.description ?? '';
      _unitCostController.text = widget.item!.unitCost?.toString() ?? '';
      _quantityController.text = widget.item!.quantity?.toString() ?? '';
      _discountAmountController.text =
          widget.item!.discountAmount?.toString() ?? '';
      _additionalDetailsController.text = widget.item!.additionalDetails ?? '';
      _isTaxable = widget.item!.taxable ?? false;
      _discountType = widget.item!.discountType ?? 'percentage';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _unitCostController.dispose();
    _quantityController.dispose();
    _discountAmountController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final item = EstimateDetail(
        estimateId: widget.estimateId,
        description: _descriptionController.text,
        unitCost:
            _unitCostController.text.isNotEmpty
                ? double.tryParse(_unitCostController.text)
                : 0.0,
        quantity:
            _quantityController.text.isNotEmpty
                ? double.tryParse(_quantityController.text)
                : 1.0,
        discountType: _discountType,
        discountAmount:
            _discountAmountController.text.isNotEmpty
                ? double.tryParse(_discountAmountController.text)
                : 0.0,
        taxable: _isTaxable,
        additionalDetails:
            _additionalDetailsController.text.isNotEmpty
                ? _additionalDetailsController.text
                : null,
      );

      widget.onSave(item);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isEditing = widget.item != null;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    isEditing ? localizations.editItem : localizations.addItem,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: localizations.descriptionLabel,
                      hintText: localizations.descriptionHint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.descriptionRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Unit Cost & Quantity
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _unitCostController,
                          decoration: InputDecoration(
                            labelText: localizations.unitPriceLabel,
                            hintText: '0.00',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            labelText: localizations.quantityLabel,
                            hintText: '1',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Discount
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _discountAmountController,
                          decoration: InputDecoration(
                            labelText: localizations.discountLabel,
                            hintText: '0.00',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: localizations.typeLabel,
                            border: const OutlineInputBorder(),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _discountType,
                              isExpanded: true,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _discountType = newValue;
                                  });
                                }
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: 'percentage',
                                  child: Text('%'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'fixed',
                                  child: Text(localizations.fixed),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Taxable Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _isTaxable,
                        onChanged: (bool? value) {
                          setState(() {
                            _isTaxable = value ?? false;
                          });
                        },
                      ),
                      Text(localizations.taxable),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Additional Details
                  TextFormField(
                    controller: _additionalDetailsController,
                    decoration: InputDecoration(
                      labelText: localizations.additionalDetailsLabel,
                      hintText: localizations.additionalDetailsHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(localizations.cancel),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(isEditing ? localizations.saveChanges : localizations.addItem),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
