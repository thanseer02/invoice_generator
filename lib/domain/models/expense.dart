class Expense {
  final String id;
  final String? companyId;
  final String category;
  final double amount;
  final DateTime expenseDate;
  final String? notes;
  final String? receiptPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    this.companyId,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.notes,
    this.receiptPath,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      companyId: json['companyId'] as String?,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      notes: json['notes'] as String?,
      receiptPath: json['receiptPath'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'category': category,
      'amount': amount,
      'expenseDate': expenseDate.toIso8601String(),
      'notes': notes,
      'receiptPath': receiptPath,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? companyId,
    String? category,
    double? amount,
    DateTime? expenseDate,
    String? notes,
    String? receiptPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
