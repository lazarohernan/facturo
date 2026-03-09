import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/snackbar_service.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:io';
import 'package:facturo/core/design_system/design_system.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  final Expense? expense;
  final Function(bool) onComplete;

  const ExpenseForm({super.key, this.expense, required this.onComplete});

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _totalController = TextEditingController();
  final _taxController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<DropdownMenuItem<int>> _categoryDropdownItems = [];

  DateTime _expenseDate = DateTime.now();
  int? _selectedCategoryId;
  bool _isLoading = false;
  File? _receiptFile;
  String? _receiptUrl;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _initializeForm();
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _totalController.dispose();
    _taxController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Load expense categories
  void _loadCategories() {
    ref.read(expenseCategoryListProvider.notifier).loadCategories();
  }

  // Initialize form with expense data if editing
  void _initializeForm() {
    if (widget.expense != null) {
      final expense = widget.expense!;
      _merchantController.text = expense.merchant;
      _totalController.text = expense.total?.toString() ?? '0.0';
      _taxController.text = expense.tax?.toString() ?? '';
      _descriptionController.text = expense.description ?? '';
      _expenseDate = expense.expenseDate ?? DateTime.now();
      _receiptUrl = expense.receiptUrl;

      if (expense.category != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _selectedCategoryId = expense.category;
            });
          }
        });
      }
    }
  }

  // Pick image from gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _receiptFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).errorPickingImage}: $e')));
      }
    }
  }

  // Show image picker options
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.gallery_outline),
                title: Text(AppLocalizations.of(context).chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.camera_outline),
                title: Text(AppLocalizations.of(context).takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expenseDate = picked;
      });
    }
  }

  // Submit form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final total = double.parse(_totalController.text);
        final tax = _taxController.text.isNotEmpty
            ? double.parse(_taxController.text)
            : null;

        final expense = widget.expense != null
            ? widget.expense!.copyWith(
                merchant: _merchantController.text,
                category: _selectedCategoryId,
                expenseDate: _expenseDate,
                total: total,
                tax: tax,
                description: _descriptionController.text,
              )
            : Expense(
                id: const Uuid().v4(),
                userId: '', // Will be set by the provider
                merchant: _merchantController.text,
                category: _selectedCategoryId,
                expenseDate: _expenseDate,
                total: total,
                tax: tax,
                description: _descriptionController.text,
                createdAt: DateTime.now(),
                status: true,
              );

        Expense? result;
        if (widget.expense != null) {
          // Update existing expense
          result = await ref
              .read(expenseDetailProvider.notifier)
              .updateExpense(expense, receiptFile: _receiptFile);
        } else {
          // Create new expense
          result = await ref
              .read(expenseDetailProvider.notifier)
              .createExpense(expense, receiptFile: _receiptFile);
        }

        widget.onComplete(result != null);
      } catch (e) {
        if (mounted) {
          SnackbarService.showGenericError(context, error: e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesData = ref.watch(expenseCategoryListProvider);
    _buildCategoryDropdownItems(categoriesData);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(
        LayoutSystem.isMobile(context) ? DesignTokens.spacingMd : DesignTokens.spacingLg
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DesignTokens.gapSm,
            // Basic Information Section
            _buildSectionCard(
              theme,
              title: AppLocalizations.of(context).basicInformation,
              children: [
                _buildFormField(
                  controller: _merchantController,
                  label: AppLocalizations.of(context).merchantRequired,
                  hint: AppLocalizations.of(context).enterMerchantName,
                  icon: Iconsax.shop_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterMerchantName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  value: _selectedCategoryId,
                  label: AppLocalizations.of(context).categoryRequired,
                  hint: AppLocalizations.of(context).selectCategory,
                  icon: Iconsax.category_outline,
                  items: _categoryDropdownItems,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return AppLocalizations.of(context).pleaseSelectCategory;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDateField(theme),
              ],
            ),
            const SizedBox(height: 16),

            // Receipt Image Section
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl
                ),
                child: _buildReceiptImageSection(theme),
              ),
            ),
            DesignTokens.gapLg,

            // Financial Information Section
            _buildSectionCard(
              theme,
              title: AppLocalizations.of(context).financialInformation,
              children: [
                _buildFormField(
                  controller: _totalController,
                  label: AppLocalizations.of(context).totalAmountRequired,
                  hint: AppLocalizations.of(context).enterTotalAmount,
                  icon: Iconsax.dollar_circle_outline,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterTotalAmount;
                    }
                    try {
                      final amount = double.parse(value);
                      if (amount <= 0) {
                        return AppLocalizations.of(context).amountMustBeGreaterThanZero;
                      }
                    } catch (e) {
                      return AppLocalizations.of(context).pleaseEnterValidAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _taxController,
                  label: AppLocalizations.of(context).taxAmountOptional,
                  hint: AppLocalizations.of(context).enterTaxAmount,
                  icon: Iconsax.calculator_outline,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      try {
                        final tax = double.parse(value);
                        if (_totalController.text.isEmpty) {
                          return AppLocalizations.of(context).pleaseEnterTotalAmountFirst;
                        }
                        final total = double.parse(_totalController.text);
                        if (tax < 0) {
                          return AppLocalizations.of(context).taxCannotBeNegative;
                        }
                        if (tax > total) {
                          return AppLocalizations.of(context).taxCannotBeGreaterThanTotal;
                        }
                      } catch (e) {
                        return AppLocalizations.of(context).pleaseEnterValidAmount;
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description Section
            _buildSectionCard(
              theme,
              title: AppLocalizations.of(context).description,
              children: [
                _buildFormField(
                  controller: _descriptionController,
                  label: AppLocalizations.of(context).descriptionOptional,
                  hint: AppLocalizations.of(context).enterDescription,
                  icon: Iconsax.document_text_outline,
                  maxLines: 3,
                ),
              ],
            ),
            DesignTokens.gap2xl,

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: LayoutSystem.isMobile(context) ? DesignTokens.spacingMd : DesignTokens.spacingLg
                ),
                minimumSize: Size(
                  double.infinity,
                  LayoutSystem.isMobile(context) ? 48 : 56
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.expense != null ? AppLocalizations.of(context).updateExpense : AppLocalizations.of(context).addExpense,
                      style: TextStyle(
                        fontSize: LayoutSystem.isMobile(context) ? DesignTokens.fontSizeMd : DesignTokens.fontSizeLg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Build category dropdown items
  void _buildCategoryDropdownItems(ExpenseCategoryListData data) {
    _categoryDropdownItems.clear();

    if (data.state == ExpenseState.loaded && data.categories.isNotEmpty) {
      // Create items from loaded categories
      final items = data.categories
          .map(
            (category) => DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.categoryName),
            ),
          )
          .toList();

      // Add a placeholder if the selected category is not in the list
      if (_selectedCategoryId != null &&
          !data.categories.any(
            (category) => category.id == _selectedCategoryId,
          )) {
        items.insert(
          0,
          DropdownMenuItem<int>(
            value: _selectedCategoryId,
            child: Text(AppLocalizations.of(context).unknownCategory),
          ),
        );
      }

      _categoryDropdownItems.addAll(items);
    } else if (data.state == ExpenseState.loading) {
      _categoryDropdownItems.add(
        DropdownMenuItem<int>(
          value: 0,
          enabled: false,
          child: Text(AppLocalizations.of(context).loadingCategories),
        ),
      );
    } else if (data.state == ExpenseState.error) {
      _categoryDropdownItems.add(
        DropdownMenuItem<int>(
          value: 0,
          enabled: false,
          child: Text(AppLocalizations.of(context).errorLoadingCategories),
        ),
      );
    } else if (data.categories.isEmpty) {
      _categoryDropdownItems.add(
        DropdownMenuItem<int>(
          value: 0,
          enabled: false,
          child: Text(AppLocalizations.of(context).noCategoriesAvailable),
        ),
      );
    }

    // Ensure we always have at least one item
    if (_categoryDropdownItems.isEmpty) {
      _categoryDropdownItems.add(
        DropdownMenuItem<int>(
          value: 0,
          enabled: false,
          child: Text(AppLocalizations.of(context).noCategoriesAvailable),
        ),
      );
    }
  }

  // Build section card with profile style
  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.fromLTRB(
              LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl,
              LayoutSystem.isMobile(context) ? DesignTokens.spacingMd : DesignTokens.spacingLg,
              LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl,
              DesignTokens.spacingSm,
            ),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: LayoutSystem.isMobile(context) ? DesignTokens.fontSizeMd : DesignTokens.fontSizeLg,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Section content
          Padding(
            padding: EdgeInsets.fromLTRB(
              LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl,
              0,
              LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl,
              LayoutSystem.isMobile(context) ? DesignTokens.spacingMd : DesignTokens.spacingLg,
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // Build form field with profile style
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines ?? 1,
    );
  }

  // Build dropdown field with profile style
  Widget _buildDropdownField({
    required int? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
    String? Function(int?)? validator,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  // Build date field with profile style
  Widget _buildDateField(ThemeData theme) {
    return Semantics(
      label: '${AppLocalizations.of(context).dateRequired}: ${DateFormat('MMM dd, yyyy', Localizations.localeOf(context).languageCode).format(_expenseDate)}',
      button: true,
      hint: AppLocalizations.of(context).selectDate,
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).dateRequired,
          prefixIcon: const Icon(Iconsax.calendar_outline),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        child: Text(DateFormat('MMM dd, yyyy', Localizations.localeOf(context).languageCode).format(_expenseDate)),
      ),
      ),
    );
  }

  // Build receipt image section with profile style
  Widget _buildReceiptImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).receiptImage,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: _showImagePickerOptions,
              icon: const Icon(Iconsax.add_circle_outline),
              tooltip: AppLocalizations.of(context).addReceiptImage,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_receiptFile != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _receiptFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _receiptFile = null;
                    });
                  },
                  icon: const Icon(Iconsax.close_circle_outline),
                  tooltip: AppLocalizations.of(context).deleteImage,
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ],
          )
        else if (_receiptUrl != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _receiptUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child:
                          Center(child: Icon(Iconsax.warning_2_outline, color: theme.colorScheme.onSurfaceVariant)),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _receiptUrl = null;
                    });
                  },
                  icon: const Icon(Iconsax.close_circle_outline),
                  tooltip: AppLocalizations.of(context).deleteImage,
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.receipt_outline,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).noReceiptImage,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
