import 'package:facturo/common/widgets/empty_state_widget.dart';
import 'package:facturo/common/widgets/error_state_widget.dart';
import 'package:facturo/common/widgets/loading_widget.dart';
import 'package:facturo/features/expenses/models/expense_category_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/features/expenses/views/expense_category_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';

class ExpenseCategoryListView extends ConsumerStatefulWidget {
  static const String routeName = 'expense-categories';
  static const String routePath = '/expenses/categories';

  const ExpenseCategoryListView({super.key});

  @override
  ConsumerState<ExpenseCategoryListView> createState() =>
      _ExpenseCategoryListViewState();
}

class _ExpenseCategoryListViewState
    extends ConsumerState<ExpenseCategoryListView>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    // Load categories when the view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseCategoryListProvider.notifier).loadCategories();
    });
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ExpenseCategory category,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteCategory),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete the category "${category.categoryName}"?',
                ),
                const SizedBox(height: 10),
                Text(
                  'This action cannot be undone and may affect existing expenses.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteCategory(category.id);
              },
            ),
          ],
        );
      },
    );
  }

  // Delete category
  void _deleteCategory(int categoryId) {
    ref.read(expenseCategoryListProvider.notifier).deleteCategory(categoryId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).categoryDeletedSuccessfully),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show options bottom sheet
  void _showOptionsBottomSheet(BuildContext context, ExpenseCategory category) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.edit_outline),
                title: Text(AppLocalizations.of(context).editCategory),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCategoryDetail(category: category);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.trash_outline),
                title: Text(AppLocalizations.of(context).deleteCategory),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, category);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Navigate to category detail view
  void _navigateToCategoryDetail({ExpenseCategory? category}) {
    context.push(ExpenseCategoryDetailView.routePath, extra: category);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final categoryListData = ref.watch(expenseCategoryListProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(child: _buildCategoryList(categoryListData, theme)),

        // Bottom add button
        _buildBottomAddButton(context, theme),
      ],
    );
  }

  Widget _buildCategoryList(ExpenseCategoryListData data, ThemeData theme) {
    switch (data.state) {
      case ExpenseState.loading:
        return const LoadingWidget(message: 'Loading categories...');

      case ExpenseState.error:
        return ErrorStateWidget(
          message: data.errorMessage ?? 'An error occurred',
          onRetry: () =>
              ref.read(expenseCategoryListProvider.notifier).loadCategories(),
        );

      case ExpenseState.loaded:
        if (data.categories.isEmpty) {
          final localizations = AppLocalizations.of(context);
          return EmptyStateWidget(
            icon: Iconsax.category_outline,
            title: localizations.noCategoriesTitle,
            message: localizations.addFirstCategoryMessage,
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(expenseCategoryListProvider.notifier).loadCategories(),
          child: ListView.builder(
            key: const PageStorageKey('expense_categories_list'),
            itemCount: data.categories.length,
            itemBuilder: (context, index) {
              final category = data.categories[index];
              return _buildCategoryCard(category, theme);
            },
          ),
        );

      case ExpenseState.initial:
        return const LoadingWidget(message: 'Loading categories...');
    }
  }

  Widget _buildCategoryCard(ExpenseCategory category, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToCategoryDetail(category: category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with icon, name and options
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.category_outline,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      category.categoryName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Actions menu (three dots)
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => _showOptionsBottomSheet(context, category),
                  ),
                ],
              ),

              // Description section
              if (category.categoryDescription != null &&
                  category.categoryDescription!.isNotEmpty) ...[
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    category.categoryDescription!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // Build bottom add button
  Widget _buildBottomAddButton(BuildContext context, ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: ElevatedButton(
          onPressed: () => _navigateToCategoryDetail(),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: Text(
            AppLocalizations.of(context).addCategory,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
