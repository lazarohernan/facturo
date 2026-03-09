import 'package:facturo/common/utils/date_formatter.dart';
import 'package:facturo/common/widgets/empty_state_widget.dart';
import 'package:facturo/common/widgets/error_state_widget.dart';
import 'package:facturo/common/widgets/loading_widget.dart';
import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/features/expenses/views/expense_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/features/expenses/models/expense_category_model.dart';
import 'package:facturo/common/ui/primary_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/core/services/snackbar_service.dart';

class ExpenseListView extends ConsumerStatefulWidget {
  static const String routeName = 'expenses';
  static const String routePath = '/expenses';

  const ExpenseListView({super.key});

  @override
  ConsumerState<ExpenseListView> createState() => _ExpenseListViewState();
}

class _ExpenseListViewState extends ConsumerState<ExpenseListView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedYear = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    // Load expenses when the view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories(); // Load categories first
      _loadExpenses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Handle search
  void _handleSearch(String query) {
    ref.read(expenseListProvider.notifier).searchExpenses(query);
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    _loadExpenses();
    // keep search bar visible consistently as Estimates style
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Expense expense,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteExpense),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).areYouSureDeleteExpense(expense.merchant),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context).thisActionCannotBeUndone,
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
                _deleteExpense(expense.id);
              },
            ),
          ],
        );
      },
    );
  }

  // Show options bottom sheet
  void _showOptionsBottomSheet(BuildContext context, Expense expense) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    Icon(PhosphorIcons.pencil(PhosphorIconsStyle.regular), color: theme.colorScheme.primary),
                title: Text(AppLocalizations.of(context).editExpense),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToExpenseDetail(expense: expense);
                },
              ),
              ListTile(
                leading:
                    Icon(PhosphorIcons.trash(PhosphorIconsStyle.regular), color: theme.colorScheme.error),
                title: Text(AppLocalizations.of(context).deleteExpense),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, expense);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete expense
  void _deleteExpense(String expenseId) {
    ref.read(expenseListProvider.notifier).deleteExpense(expenseId);
    SnackbarService.showDeleteSuccess(context);
  }

  // Navigate to expense detail view
  void _navigateToExpenseDetail({Expense? expense}) async {
    await context.push(ExpenseDetailView.routePath, extra: expense);
  }

  void _loadExpenses() {
    ref.read(expenseListProvider.notifier).loadExpenses();
  }

  // Get available years from expenses
  List<String> _getAvailableYears(List<Expense> expenses) {
    final years = <String>{};
    for (final expense in expenses) {
      if (expense.expenseDate != null) {
        years.add(expense.expenseDate!.year.toString());
      }
    }
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    return sortedYears;
  }

  // Filter expenses by selected year
  List<Expense> _filterExpensesByYear(List<Expense> expenses) {
    if (_selectedYear.isEmpty) return expenses;

    return expenses.where((expense) {
      if (expense.expenseDate == null) return false;
      return expense.expenseDate!.year.toString() == _selectedYear;
    }).toList()
      ..sort((a, b) {
        if (a.expenseDate == null) return 1;
        if (b.expenseDate == null) return -1;
        return b.expenseDate!.compareTo(a.expenseDate!);
      });
  }

  // Show year picker as bottom sheet
  void _showYearPicker(List<String> availableYears, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).selectYear,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...availableYears.map((year) {
              final yearCount = _filterExpensesByYear(
                ref.read(expenseListProvider).expenses.where((e) => e.expenseDate?.year.toString() == year).toList(),
              );
              return ListTile(
                title: Text(year),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${yearCount.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                selected: year == _selectedYear,
                onTap: () {
                  setState(() {
                    _selectedYear = year;
                  });
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build year selector widget (Estimates style)
  Widget _buildYearSelector(List<Expense> expenses, ThemeData theme) {
    final availableYears = _getAvailableYears(expenses);

    if (availableYears.isEmpty) return const SizedBox.shrink();

    if (!availableYears.contains(_selectedYear)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedYear = availableYears.first;
          });
        }
      });
      return const SizedBox.shrink();
    }

    final filteredExpenses = _filterExpensesByYear(expenses);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showYearPicker(availableYears, theme),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedYear,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredExpenses.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final expenseListData = ref.watch(expenseListProvider);
    final theme = Theme.of(context);
    final categories = ref.watch(expenseCategoryListProvider).categories;

    return Column(
      children: [
        // Search bar (always visible, Estimates style)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).searchExpenses,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.regular)),
                      tooltip: AppLocalizations.of(context).clear,
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
            onChanged: _handleSearch,
          ),
        ),

        // Year selector - only when not searching and has data
        if (expenseListData.state == ExpenseState.loaded &&
            expenseListData.expenses.isNotEmpty &&
            (expenseListData.searchQuery == null ||
                expenseListData.searchQuery!.isEmpty))
          _buildYearSelector(expenseListData.expenses, theme),

        // Expense list
        Expanded(child: _buildExpenseList(expenseListData, theme, categories)),

        // Bottom add button
        _buildBottomAddButton(context, theme),
      ],
    );
  }

  Widget _buildExpenseList(
      ExpenseListData data, ThemeData theme, List<ExpenseCategory> categories) {
    switch (data.state) {
      case ExpenseState.loading:
        return const LoadingWidget(message: 'Loading expenses...');

      case ExpenseState.error:
        return ErrorStateWidget(
          message: data.errorMessage ?? 'An error occurred',
          onRetry: () => _loadExpenses(),
        );

      case ExpenseState.loaded:
        if (data.expenses.isEmpty) {
          return EmptyStateWidget(
            icon: PhosphorIcons.receipt(PhosphorIconsStyle.regular),
            title: AppLocalizations.of(context).noExpensesFound,
            message: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? AppLocalizations.of(context).noExpensesMatchSearchCriteria
                : AppLocalizations.of(context).addFirstExpenseToGetStarted,
          );
        }

        // When searching, ignore year filter and just sort
        List<Expense> displayExpenses;
        if (data.searchQuery != null && data.searchQuery!.isNotEmpty) {
          displayExpenses = [...data.expenses]
            ..sort((a, b) {
              if (a.expenseDate == null) return 1;
              if (b.expenseDate == null) return -1;
              return b.expenseDate!.compareTo(a.expenseDate!);
            });
        } else {
          displayExpenses = _filterExpensesByYear(data.expenses);
        }

        if (displayExpenses.isEmpty) {
          return EmptyStateWidget(
            icon: PhosphorIcons.receipt(PhosphorIconsStyle.regular),
            title: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? AppLocalizations.of(context).noSearchResults
                : AppLocalizations.of(context).noExpensesForYear(_selectedYear),
            message: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? AppLocalizations.of(context).tryDifferentSearchTerm
                : AppLocalizations.of(context).tryDifferentYearOrAddExpense,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(expenseListProvider.notifier).loadExpenses();
            return;
          },
          child: ListView.builder(
            key: const PageStorageKey('expenses_list'),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: displayExpenses.length,
            itemBuilder: (context, index) {
              final expense = displayExpenses[index];
              return _buildExpenseCard(expense, theme, categories);
            },
          ),
        );

      case ExpenseState.initial:
        return LoadingWidget(message: AppLocalizations.of(context).loadingExpenses);
    }
  }

  Widget _buildExpenseCard(
      Expense expense, ThemeData theme, List<ExpenseCategory> categories) {

    // Get the category name from the category id
    final category = categories.firstWhere(
      (category) => category.id == expense.category,
      orElse: () {
        return ExpenseCategory(
          id: -1,
          userId: 'unknown',
          categoryName: AppLocalizations.of(context).unknown,
          categoryDescription: '',
          createdAt: DateTime.now(),
          status: false,
        );
      },
    );

    final amount = '\$${expense.total?.toStringAsFixed(2) ?? '0.00'}';
    final dateText = expense.expenseDate != null
        ? DateFormatter.formatDate(expense.expenseDate!, Localizations.localeOf(context).languageCode)
        : 'No date';

    return Semantics(
      label: '${expense.merchant}, $amount, ${category.categoryName}, $dateText',
      hint: 'Double tap to view details',
      child: Container(
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
        onTap: () => _navigateToExpenseDetail(expense: expense),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with merchant, amount and options
              Row(
                children: [
                  // Leading icon without background (consistent with Estimates style)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Icon(
                        PhosphorIcons.wallet(PhosphorIconsStyle.regular),
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      expense.merchant,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${expense.total?.toStringAsFixed(2) ?? '0.00'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Actions menu (three dots)
                  IconButton(
                    icon: Icon(
                      PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.regular),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: AppLocalizations.of(context).moreOptions,
                    onPressed: () => _showOptionsBottomSheet(context, expense),
                  ),
                ],
              ),

              // Category and date section
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.tag(PhosphorIconsStyle.regular),
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.categoryName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expense.expenseDate != null
                              ? DateFormatter.formatDate(expense.expenseDate!, Localizations.localeOf(context).languageCode)
                              : 'No date',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description section
              if (expense.description != null &&
                  expense.description!.isNotEmpty) ...[
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
                    expense.description!,
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
    ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // Load expense categories
  void _loadCategories() {
    ref.read(expenseCategoryListProvider.notifier).loadCategories();
  }

  // Build bottom add button
  Widget _buildBottomAddButton(BuildContext context, ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: AddButton(
          text: AppLocalizations.of(context).addExpense,
          onPressed: () => _navigateToExpenseDetail(),
        ),
      ),
    );
  }
}
