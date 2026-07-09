class SuddenExpenseModel {
  final int id;
  final int tripId;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final double amount;
  final String? description;
  final DateTime? createdAt;

  SuddenExpenseModel({
    required this.id,
    required this.tripId,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    required this.amount,
    this.description,
    this.createdAt,
  });

  factory SuddenExpenseModel.fromJson(Map<String, dynamic> json) {
    // Handle amount as both String and num from backend
    dynamic rawAmount = json['amount'];
    double parsedAmount;
    if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    } else if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else {
      parsedAmount = 0.0;
    }

    // Handle id
    int parsedId;
    if (json['id'] is int) {
      parsedId = json['id'];
    } else if (json['id'] is num) {
      parsedId = (json['id'] as num).toInt();
    } else {
      parsedId = 0;
    }

    // Handle trip_id
    int parsedTripId;
    if (json['trip_id'] is int) {
      parsedTripId = json['trip_id'];
    } else if (json['trip_id'] is num) {
      parsedTripId = (json['trip_id'] as num).toInt();
    } else {
      parsedTripId = 0;
    }

    // Handle category_id
    int? parsedCategoryId;
    if (json['expense_category_id'] != null) {
      if (json['expense_category_id'] is int) {
        parsedCategoryId = json['expense_category_id'];
      } else if (json['expense_category_id'] is num) {
        parsedCategoryId = (json['expense_category_id'] as num).toInt();
      }
    }

    return SuddenExpenseModel(
      id: parsedId,
      tripId: parsedTripId,
      name: json['name'] as String? ?? '',
      categoryId: parsedCategoryId,
      categoryName: json['categoryName'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      amount: parsedAmount,
      description: json['description'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'expense_category_id': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'amount': amount,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
