import 'package:facturo/common/widgets/app_bar_widget.dart';
import 'package:facturo/common/widgets/loading_widget.dart';
import 'package:facturo/features/expenses/models/expense_category_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/features/expenses/widgets/expense_category_form.dart';
import 'package:flutter/material.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseCategoryDetailView extends ConsumerStatefulWidget {
  static const String routeName = 'expense-category-detail';
  static const String routePath = '/expenses/categories/detail';

  final ExpenseCategory? category;

  const ExpenseCategoryDetailView({super.key, this.category});

  @override
  ConsumerState<ExpenseCategoryDetailView> createState() =>
      _ExpenseCategoryDetailViewState();
}

class _ExpenseCategoryDetailViewState
    extends ConsumerState<ExpenseCategoryDetailView> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.category != null;

    if (_isEditing) {
      // Load category details if editing an existing category
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(expenseCategoryDetailProvider.notifier)
            .loadCategory(widget.category!.id);
      });
    }
  }

  // Handle form completion
  void _handleFormComplete(bool success) {
    if (success) {
      // For updates, we need to be more careful about navigation timing
      if (_isEditing) {
        // For updates, we'll use a slightly different approach to ensure the callback completes
        // before any navigation happens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Show success message in the form
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(AppLocalizations.of(context).categoryUpdatedSuccessfully),
                duration: const Duration(seconds: 2),
              ),
            );

            Navigator.of(context).pop();
          }
        });
      } else {
        // For new categories, we can use the simpler approach with a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } else {
      // Show an error message if the form completion was not successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToSaveCategory),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryDetailData = ref.watch(expenseCategoryDetailProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarWidget(
        title: _isEditing ? AppLocalizations.of(context).editCategory : AppLocalizations.of(context).addCategory,
      ),
      body: _buildBody(categoryDetailData, theme),
    );
  }

  Widget _buildBody(ExpenseCategoryDetailData data, ThemeData theme) {
    // If we're editing and still loading the category
    if (_isEditing && data.state == ExpenseState.loading) {
      return LoadingWidget(message: AppLocalizations.of(context).loadingCategoryDetails);
    }

    // If we're editing and there was an error loading the category
    if (_isEditing && data.state == ExpenseState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context).errorLoadingCategory, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              data.errorMessage ?? AppLocalizations.of(context).unknownErrorOccurred,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(expenseCategoryDetailProvider.notifier)
                    .loadCategory(widget.category!.id);
              },
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      );
    }

    // For editing, use the loaded category or fall back to the passed category
    final category = _isEditing ? (data.category ?? widget.category) : null;

    // Show the category form
    return ExpenseCategoryForm(
      category: category,
      onComplete: _handleFormComplete,
    );
  }
}
