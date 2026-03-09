import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/expenses/models/expense_category_model.dart';
import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:facturo/features/expenses/services/expense_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

// Expense state
enum ExpenseState { initial, loading, loaded, error }

// Expense list data class
class ExpenseListData {
  final ExpenseState state;
  final List<Expense> expenses;
  final String? errorMessage;
  final String? searchQuery;

  ExpenseListData({
    this.state = ExpenseState.initial,
    this.expenses = const [],
    this.errorMessage,
    this.searchQuery,
  });

  ExpenseListData copyWith({
    ExpenseState? state,
    List<Expense>? expenses,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ExpenseListData(
      state: state ?? this.state,
      expenses: expenses ?? this.expenses,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Expense detail data class
class ExpenseDetailData {
  final ExpenseState state;
  final Expense? expense;
  final String? errorMessage;

  ExpenseDetailData({
    this.state = ExpenseState.initial,
    this.expense,
    this.errorMessage,
  });

  ExpenseDetailData copyWith({
    ExpenseState? state,
    Expense? expense,
    String? errorMessage,
  }) {
    return ExpenseDetailData(
      state: state ?? this.state,
      expense: expense ?? this.expense,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Expense category list data class
class ExpenseCategoryListData {
  final ExpenseState state;
  final List<ExpenseCategory> categories;
  final String? errorMessage;

  ExpenseCategoryListData({
    this.state = ExpenseState.initial,
    this.categories = const [],
    this.errorMessage,
  });

  ExpenseCategoryListData copyWith({
    ExpenseState? state,
    List<ExpenseCategory>? categories,
    String? errorMessage,
  }) {
    return ExpenseCategoryListData(
      state: state ?? this.state,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Expense category detail data class
class ExpenseCategoryDetailData {
  final ExpenseState state;
  final ExpenseCategory? category;
  final String? errorMessage;

  ExpenseCategoryDetailData({
    this.state = ExpenseState.initial,
    this.category,
    this.errorMessage,
  });

  ExpenseCategoryDetailData copyWith({
    ExpenseState? state,
    ExpenseCategory? category,
    String? errorMessage,
  }) {
    return ExpenseCategoryDetailData(
      state: state ?? this.state,
      category: category ?? this.category,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Expense list notifier
class ExpenseListNotifier extends StateNotifier<ExpenseListData> {
  final Ref ref;

  ExpenseListNotifier(this.ref) : super(ExpenseListData()) {
    // Load expenses when created
    loadExpenses();
  }

  // Load all expenses
  Future<void> loadExpenses() async {
    try {
      state = state.copyWith(state: ExpenseState.loading);

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: ExpenseState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final expenseService = ref.read(expenseServiceProvider);
      final expenses = await expenseService.getExpenses(authState.user!.id);

      state = state.copyWith(state: ExpenseState.loaded, expenses: expenses);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading expenses: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Search expenses
  Future<void> searchExpenses(String query) async {
    try {
      state = state.copyWith(state: ExpenseState.loading, searchQuery: query);

      if (query.isEmpty) {
        await loadExpenses();
        return;
      }

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: ExpenseState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final expenseService = ref.read(expenseServiceProvider);
      final expenses = await expenseService.searchExpenses(
        authState.user!.id,
        query,
      );

      state = state.copyWith(state: ExpenseState.loaded, expenses: expenses);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching expenses: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Delete an expense (soft delete)
  Future<void> deleteExpense(String expenseId) async {
    try {
      final expenseService = ref.read(expenseServiceProvider);
      await expenseService.updateExpenseStatus(expenseId, false);

      // Refresh the expense list
      await loadExpenses();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting expense: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Reset the expense list
  void reset() {
    state = ExpenseListData();
  }
}

// Expense detail notifier
class ExpenseDetailNotifier extends StateNotifier<ExpenseDetailData> {
  final Ref ref;

  ExpenseDetailNotifier(this.ref) : super(ExpenseDetailData());

  // Load an expense by ID
  Future<void> loadExpense(String expenseId) async {
    try {
      state = state.copyWith(state: ExpenseState.loading);

      final expenseService = ref.read(expenseServiceProvider);
      final expense = await expenseService.getExpense(expenseId);

      state = state.copyWith(state: ExpenseState.loaded, expense: expense);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading expense: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Create a new expense
  Future<Expense?> createExpense(Expense expense, {File? receiptFile}) async {
    try {
      state = state.copyWith(state: ExpenseState.loading);

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: ExpenseState.error,
          errorMessage: 'User not authenticated',
        );
        return null;
      }

      final expenseService = ref.read(expenseServiceProvider);
      final createdExpense = await expenseService.createExpense(
        expense.copyWith(userId: authState.user!.id),
        receiptFile: receiptFile,
      );

      state = state.copyWith(
        state: ExpenseState.loaded,
        expense: createdExpense,
      );

      // Refresh the expense list
      ref.read(expenseListProvider.notifier).loadExpenses();

      return createdExpense;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating expense: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Update an existing expense
  Future<Expense?> updateExpense(Expense expense, {File? receiptFile}) async {
    try {
      state = state.copyWith(state: ExpenseState.loading);

      final expenseService = ref.read(expenseServiceProvider);
      final updatedExpense = await expenseService.updateExpense(
        expense,
        receiptFile: receiptFile,
      );

      state = state.copyWith(
        state: ExpenseState.loaded,
        expense: updatedExpense,
      );

      // Refresh the expense list
      ref.read(expenseListProvider.notifier).loadExpenses();

      return updatedExpense;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating expense: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Reset the expense detail
  void reset() {
    state = ExpenseDetailData();
  }
}

// Expense category list notifier
class ExpenseCategoryListNotifier
    extends StateNotifier<ExpenseCategoryListData> {
  final Ref ref;

  ExpenseCategoryListNotifier(this.ref) : super(ExpenseCategoryListData()) {
    // Load categories when created
    loadCategories();
  }

  // Load all expense categories
  Future<void> loadCategories() async {
    try {
      state = state.copyWith(state: ExpenseState.loading);

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: ExpenseState.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final expenseService = ref.read(expenseServiceProvider);
      final categories = await expenseService.getExpenseCategories(
        authState.user!.id,
      );

      state = state.copyWith(
        state: ExpenseState.loaded,
        categories: categories,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading expense categories: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Delete an expense category (soft delete)
  Future<void> deleteCategory(int categoryId) async {
    try {
      final expenseService = ref.read(expenseServiceProvider);
      await expenseService.updateExpenseCategoryStatus(categoryId, false);

      // Refresh the category list
      await loadCategories();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting expense category: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Reset the category list
  void reset() {
    state = ExpenseCategoryListData();
  }
}

// Expense category detail notifier
class ExpenseCategoryDetailNotifier
    extends StateNotifier<ExpenseCategoryDetailData> {
  final Ref ref;

  ExpenseCategoryDetailNotifier(this.ref) : super(ExpenseCategoryDetailData());

  // Load an expense category by ID
  Future<void> loadCategory(int categoryId) async {
    try {
      state = state.copyWith(state: ExpenseState.loading);

      final expenseService = ref.read(expenseServiceProvider);
      final category = await expenseService.getExpenseCategory(categoryId);

      state = state.copyWith(state: ExpenseState.loaded, category: category);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading expense category: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Create a new expense category
  Future<ExpenseCategory?> createCategory(ExpenseCategory category) async {
    try {
      state = state.copyWith(state: ExpenseState.loading);

      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        state = state.copyWith(
          state: ExpenseState.error,
          errorMessage: 'User not authenticated',
        );
        return null;
      }

      final expenseService = ref.read(expenseServiceProvider);
      final createdCategory = await expenseService.createExpenseCategory(
        category.copyWith(userId: authState.user!.id),
      );

      state = state.copyWith(
        state: ExpenseState.loaded,
        category: createdCategory,
      );

      // Refresh the category list
      ref.read(expenseCategoryListProvider.notifier).loadCategories();

      return createdCategory;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating expense category: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Update an existing expense category
  Future<ExpenseCategory?> updateCategory(ExpenseCategory category) async {
    try {
      state = state.copyWith(state: ExpenseState.loading);

      final expenseService = ref.read(expenseServiceProvider);
      final updatedCategory = await expenseService.updateExpenseCategory(
        category,
      );

      state = state.copyWith(
        state: ExpenseState.loaded,
        category: updatedCategory,
      );

      // Refresh the category list
      ref.read(expenseCategoryListProvider.notifier).loadCategories();

      return updatedCategory;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating expense category: $e');
      }
      state = state.copyWith(
        state: ExpenseState.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Reset the category detail
  void reset() {
    state = ExpenseCategoryDetailData();
  }
}

// Expense list provider
final expenseListProvider =
    StateNotifierProvider<ExpenseListNotifier, ExpenseListData>((ref) {
      return ExpenseListNotifier(ref);
    });

// Expense detail provider
final expenseDetailProvider =
    StateNotifierProvider<ExpenseDetailNotifier, ExpenseDetailData>((ref) {
      return ExpenseDetailNotifier(ref);
    });

// Expense category list provider
final expenseCategoryListProvider =
    StateNotifierProvider<ExpenseCategoryListNotifier, ExpenseCategoryListData>(
      (ref) {
        return ExpenseCategoryListNotifier(ref);
      },
    );

// Expense category detail provider
final expenseCategoryDetailProvider = StateNotifierProvider<
  ExpenseCategoryDetailNotifier,
  ExpenseCategoryDetailData
>((ref) {
  return ExpenseCategoryDetailNotifier(ref);
});
