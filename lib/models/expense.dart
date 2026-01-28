class Expense {
  final int? id;
  final String category;
  final int amount;
  final String description;
  final DateTime date;
  final int? createdByUserId;

  Expense({
    this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.createdByUserId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String(),
        'created_by_user_id': createdByUserId,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'],
        category: map['category'],
        amount: map['amount'],
        description: map['description'],
        date: DateTime.parse(map['date']),
        createdByUserId: map['created_by_user_id'],
      );
}
