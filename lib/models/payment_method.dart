class PaymentMethod {
  final int? id;
  final String name;
  final String type; // 'cash', 'transfer', 'ewallet', 'card'
  final bool isActive;

  PaymentMethod({
    this.id,
    required this.name,
    required this.type,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'is_active': isActive ? 1 : 0,
      };

  factory PaymentMethod.fromMap(Map<String, dynamic> map) => PaymentMethod(
        id: map['id'],
        name: map['name'],
        type: map['type'],
        isActive: map['is_active'] == 1,
      );
}
