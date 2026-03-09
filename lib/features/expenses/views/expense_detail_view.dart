import 'package:facturo/common/widgets/app_bar_widget.dart';
import 'package:facturo/common/widgets/loading_widget.dart';
import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/features/expenses/widgets/expense_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/services/snackbar_service.dart';
import 'package:facturo/core/design_system/design_system.dart';

class ExpenseDetailView extends ConsumerStatefulWidget {
  static const String routeName = 'expense-detail';
  static const String routePath = '/expenses/detail';

  final Expense? expense;

  const ExpenseDetailView({super.key, this.expense});

  @override
  ConsumerState<ExpenseDetailView> createState() => _ExpenseDetailViewState();
}

class _ExpenseDetailViewState extends ConsumerState<ExpenseDetailView>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isEditing = widget.expense != null;

    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(expenseDetailProvider.notifier)
            .loadExpense(widget.expense!.id);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Handle form completion
  void _handleFormComplete(bool success) {
    final localizations = AppLocalizations.of(context);
    
    if (success) {
      // Show success message
      SnackbarService.showSuccess(
        context,
        message: _isEditing
            ? localizations.expenseCreatedUpdated
            : localizations.expenseCreatedUpdated,
      );

      // Navigate back
      if (_isEditing) {
        context.pop(true);
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseDetailData = ref.watch(expenseDetailProvider);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBarWidget(title: _isEditing ? localizations.editExpense : localizations.newExpense),
      body: _buildBody(expenseDetailData, theme),
    );
  }

  Widget _buildBody(ExpenseDetailData data, ThemeData theme) {
    final localizations = AppLocalizations.of(context);
    
    // If we're editing and still loading the expense
    if (_isEditing && data.state == ExpenseState.loading) {
      return Semantics(
        label: localizations.loadingExpenses,
        liveRegion: true,
        child: LoadingWidget(message: localizations.loadingExpenses),
      );
    }

    // If we're editing and there was an error loading the expense
    if (_isEditing && data.state == ExpenseState.error) {
      return Semantics(
        label: '${localizations.errorLoadingExpense}: ${data.errorMessage ?? localizations.unknownErrorOccurred}',
        liveRegion: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(localizations.errorLoadingExpense, style: theme.textTheme.titleLarge),
              DesignTokens.gapLg,
              Text(
                data.errorMessage ?? localizations.unknownErrorOccurred,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              DesignTokens.gap2xl,
              Semantics(
                label: localizations.retry,
                button: true,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(expenseDetailProvider.notifier)
                        .loadExpense(widget.expense!.id);
                  },
                  child: Text(localizations.retry),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // For editing, use the loaded expense or fall back to the passed expense
    final expense = _isEditing ? (data.expense ?? widget.expense) : null;

    // Show the expense form
    return ExpenseForm(expense: expense, onComplete: _handleFormComplete);
  }
}
