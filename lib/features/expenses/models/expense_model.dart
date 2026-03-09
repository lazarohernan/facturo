import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String merchant;
  final int? category;
  final DateTime? expenseDate;
  final double? total;
  final double? tax;
  final String? description;
  final bool status;
  final String? receiptUrl;
  final String? categoryName;

  Expense({
    String? id,
    DateTime? createdAt,
    required this.userId,
    required this.merchant,
    this.category,
    this.expenseDate,
    this.total = 0.0,
    this.tax = 0.0,
    this.description,
    this.status = true,
    this.receiptUrl,
    this.categoryName,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Create an Expense from a JSON map
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      merchant: json['merchant'],
      category: json['category'],
      expenseDate:
          json['expense_date'] != null
              ? DateTime.parse(json['expense_date'])
              : null,
      total:
          json['total'] != null ? double.parse(json['total'].toString()) : 0.0,
      tax: json['tax'] != null ? double.parse(json['tax'].toString()) : 0.0,
      description: json['description'],
      status: json['status'] ?? true,
      receiptUrl: json['receipt_url'],
      categoryName: json['expenses_categories']?['category_name'],
    );
  }

  // Convert Expense to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'merchant': merchant,
      'category': category,
      'expense_date': expenseDate?.toIso8601String(),
      'total': total,
      'tax': tax,
      'description': description,
      'status': status,
      'receipt_url': receiptUrl,
    };
  }

  // Convert Expense to a JSON map for creating a new expense (without ID and createdAt)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'user_id': userId,
      'merchant': merchant,
      'category': category,
      'expense_date': expenseDate?.toIso8601String(),
      'total': total,
      'tax': tax,
      'description': description,
      'status': status,
      'receipt_url': receiptUrl,
    };
  }

  // Create a copy of Expense with updated fields
  Expense copyWith({
    String? id,
    DateTime? createdAt,
    String? userId,
    String? merchant,
    int? category,
    DateTime? expenseDate,
    double? total,
    double? tax,
    String? description,
    bool? status,
    String? receiptUrl,
    String? categoryName,
  }) {
    return Expense(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      expenseDate: expenseDate ?? this.expenseDate,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      description: description ?? this.description,
      status: status ?? this.status,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
