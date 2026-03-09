class ExpenseCategory {
  final int id;
  final String userId;
  final String categoryName;
  final String? categoryDescription;
  final DateTime createdAt;
  final bool status;

  ExpenseCategory({
    int? id,
    required this.userId,
    required this.categoryName,
    this.categoryDescription,
    DateTime? createdAt,
    this.status = true,
  }) : id = id ?? 0,
       createdAt = createdAt ?? DateTime.now();

  // Create an ExpenseCategory from a JSON map
  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      userId: json['user_id'],
      categoryName: json['category_name'],
      categoryDescription: json['category_description'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? true,
    );
  }

  // Convert ExpenseCategory to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_name': categoryName,
      'category_description': categoryDescription,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  // Convert ExpenseCategory to a JSON map for creating a new category (without ID and createdAt)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'user_id': userId,
      'category_name': categoryName,
      'category_description': categoryDescription,
      'status': status,
    };
  }

  // Create a copy of ExpenseCategory with updated fields
  ExpenseCategory copyWith({
    int? id,
    String? userId,
    String? categoryName,
    String? categoryDescription,
    DateTime? createdAt,
    bool? status,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryName: categoryName ?? this.categoryName,
      categoryDescription: categoryDescription ?? this.categoryDescription,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
