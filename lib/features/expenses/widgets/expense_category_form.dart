import 'package:facturo/features/expenses/models/expense_category_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class ExpenseCategoryForm extends ConsumerStatefulWidget {
  final ExpenseCategory? category;
  final Function(bool) onComplete;

  const ExpenseCategoryForm({
    super.key,
    this.category,
    required this.onComplete,
  });

  @override
  ConsumerState<ExpenseCategoryForm> createState() =>
      _ExpenseCategoryFormState();
}

class _ExpenseCategoryFormState extends ConsumerState<ExpenseCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Initialize form with category data if editing
  void _initializeForm() {
    if (widget.category != null) {
      final category = widget.category!;
      _nameController.text = category.categoryName;
      _descriptionController.text = category.categoryDescription ?? '';
    }
  }

  // Submit form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final category =
            widget.category != null
                ? widget.category!.copyWith(
                  categoryName: _nameController.text,
                  categoryDescription:
                      _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : null,
                )
                : ExpenseCategory(
                  userId: '', // Will be set by the provider
                  categoryName: _nameController.text,
                  categoryDescription:
                      _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : null,
                );

        ExpenseCategory? result;
        if (widget.category != null) {
          // Update existing category
          result = await ref
              .read(expenseCategoryDetailProvider.notifier)
              .updateCategory(category);
        } else {
          // Create new category
          result = await ref
              .read(expenseCategoryDetailProvider.notifier)
              .createCategory(category);
        }

        // Check if widget is still mounted before updating state
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show success message in the form
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                widget.category != null
                    ? AppLocalizations.of(context).categoryUpdatedSuccessfully
                    : AppLocalizations.of(context).categoryAddedSuccessfully,
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // Call the callback directly
          widget.onComplete(result != null);
        } else {
          // Even if widget is not mounted, we should still call the callback
          // This ensures the parent widget knows the operation completed successfully
          widget.onComplete(result != null);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context).error}: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Basic Information Section
            _buildSectionCard(
              theme,
              title: AppLocalizations.of(context).basicInformation,
              children: [
                _buildFormField(
                  controller: _nameController,
                  label: AppLocalizations.of(context).categoryNameRequired,
                  hint: AppLocalizations.of(context).enterCategoryName,
                  icon: Iconsax.category_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterCategoryName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  controller: _descriptionController,
                  label: AppLocalizations.of(context).descriptionOptional,
                  hint: AppLocalizations.of(context).enterDescription,
                  icon: Iconsax.document_text_outline,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.category != null
                          ? AppLocalizations.of(context).updateCategory
                          : AppLocalizations.of(context).addCategory,
                    ),
            ),
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Section content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
      validator: validator,
      maxLines: maxLines ?? 1,
    );
  }
}
