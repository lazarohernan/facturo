import 'package:facturo/core/providers/supabase_providers.dart';
import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/expenses/models/expense_category_model.dart';
import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ExpenseService {
  final SupabaseClient _client;

  ExpenseService(this._client);

  // Upload receipt image
  Future<String?> uploadReceipt(File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final randomId =
          DateTime.now().millisecondsSinceEpoch
              .toString(); // Generate a unique ID based on the current timestamp
      final fileName = '$randomId$fileExt';
      final filePath = 'expenses/$fileName';

      final storageService = StorageService(_client);
      final storedPath = await storageService.uploadFile(
        filePath: filePath,
        file: imageFile,
      );

      if (kDebugMode) {
        debugPrint('Receipt uploaded successfully: $storedPath');
      }

      return storedPath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error uploading receipt: $e');
      }
      rethrow;
    }
  }

  // Get all expenses for a user
  Future<List<Expense>> getExpenses(String userId) async {
    try {
      final response = await _client
          .from('expenses')
          .select('*, expenses_categories(category_name)')
          .eq('user_id', userId)
          .eq('status', true)
          .order('expense_date', ascending: false);

      return response.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting expenses: $e');
      }
      rethrow;
    }
  }

  // Get an expense by ID
  Future<Expense> getExpense(String expenseId) async {
    try {
      final response =
          await _client
              .from('expenses')
              .select('*, expenses_categories(category_name)')
              .eq('id', expenseId)
              .single();

      return Expense.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting expense: $e');
      }
      rethrow;
    }
  }

  // Create a new expense
  Future<Expense> createExpense(Expense expense, {File? receiptFile}) async {
    try {
      String? receiptUrl;
      if (receiptFile != null) {
        receiptUrl = await uploadReceipt(receiptFile);
      }

      final data = expense.copyWith(receiptUrl: receiptUrl).toJsonForCreate();

      final response =
          await _client
              .from('expenses')
              .insert(data)
              .select('*, expenses_categories(category_name)')
              .single();

      if (kDebugMode) {
        debugPrint('Expense created successfully: ${response['id']}');
      }

      return Expense.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating expense: $e');
      }
      rethrow;
    }
  }

  // Update an existing expense
  Future<Expense> updateExpense(Expense expense, {File? receiptFile}) async {
    try {
      String? receiptUrl = expense.receiptUrl;
      if (receiptFile != null) {
        receiptUrl = await uploadReceipt(receiptFile);
      }

      final data = expense.copyWith(receiptUrl: receiptUrl).toJsonForCreate();

      final response =
          await _client
              .from('expenses')
              .update(data)
              .eq('id', expense.id)
              .select('*, expenses_categories(category_name)')
              .single();

      if (kDebugMode) {
        debugPrint('Expense updated successfully: ${expense.id}');
      }

      return Expense.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating expense: $e');
      }
      rethrow;
    }
  }

  // Update expense status (soft delete)
  Future<void> updateExpenseStatus(String expenseId, bool status) async {
    try {
      await _client
          .from('expenses')
          .update({'status': status})
          .eq('id', expenseId);

      if (kDebugMode) {
        debugPrint('Expense status updated successfully: $expenseId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating expense status: $e');
      }
      rethrow;
    }
  }

  // Search expenses by merchant or description
  Future<List<Expense>> searchExpenses(String userId, String query) async {
    try {
      final response = await _client
          .from('expenses')
          .select('*, expenses_categories(category_name)')
          .eq('user_id', userId)
          .eq('status', true)
          .or('merchant.ilike.%$query%,description.ilike.%$query%')
          .order('expense_date', ascending: false);

      if (kDebugMode) {
        debugPrint('Found ${response.length} expenses matching "$query"');
      }

      return response.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching expenses: $e');
      }
      rethrow;
    }
  }

  // EXPENSE CATEGORY METHODS

  // Get all expense categories for a user
  Future<List<ExpenseCategory>> getExpenseCategories(String userId) async {
    try {
      final response = await _client
          .from('expenses_categories')
          .select()
          .eq('user_id', userId)
          .eq('status', true)
          .order('category_name', ascending: true);

      return response.map((json) => ExpenseCategory.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting expense categories: $e');
      }
      rethrow;
    }
  }

  // Get an expense category by ID
  Future<ExpenseCategory> getExpenseCategory(int categoryId) async {
    try {
      final response =
          await _client
              .from('expenses_categories')
              .select()
              .eq('id', categoryId)
              .single();

      return ExpenseCategory.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting expense category: $e');
      }
      rethrow;
    }
  }

  // Create a new expense category
  Future<ExpenseCategory> createExpenseCategory(
    ExpenseCategory category,
  ) async {
    try {
      final data = category.toJsonForCreate();

      final response =
          await _client
              .from('expenses_categories')
              .insert(data)
              .select()
              .single();

      if (kDebugMode) {
        debugPrint('Expense category created successfully: ${response['id']}');
      }

      return ExpenseCategory.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating expense category: $e');
      }
      rethrow;
    }
  }

  // Update an existing expense category
  Future<ExpenseCategory> updateExpenseCategory(
    ExpenseCategory category,
  ) async {
    try {
      // Use toJsonForCreate but add the necessary fields for update
      final data = {
        ...category.toJsonForCreate(),
        // Don't include 'id' in the update data as it's used in the where clause
      };

      if (kDebugMode) {
        debugPrint('Updating category with ID: ${category.id}, data: $data');
      }

      final response =
          await _client
              .from('expenses_categories')
              .update(data)
              .eq('id', category.id)
              .select()
              .single();

      if (kDebugMode) {
        debugPrint('Expense category updated successfully: ${category.id}');
      }

      return ExpenseCategory.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating expense category: $e');
      }
      rethrow;
    }
  }

  // Update expense category status (soft delete)
  Future<void> updateExpenseCategoryStatus(int categoryId, bool status) async {
    try {
      await _client
          .from('expenses_categories')
          .update({'status': status})
          .eq('id', categoryId);

      if (kDebugMode) {
        debugPrint('Expense category status updated successfully: $categoryId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating expense category status: $e');
      }
      rethrow;
    }
  }
}

// Provider for ExpenseService
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ExpenseService(client);
});
