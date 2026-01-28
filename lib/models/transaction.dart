class StoreTransaction {
  final int? id;
  final int totalGross;
  final int totalNet;
  final int serviceFee;
  final int? paymentMethodId;
  final int? createdByUserId;
  final DateTime createdAt;

  StoreTransaction({
    this.id,
    required this.totalGross,
    required this.totalNet,
    required this.serviceFee,
    this.paymentMethodId,
    this.createdByUserId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'total_gross': totalGross,
        'total_net': totalNet,
        'service_fee': serviceFee,
        'payment_method_id': paymentMethodId,
        'created_by_user_id': createdByUserId,
        'created_at': createdAt.toIso8601String(),
      };

  factory StoreTransaction.fromMap(Map<String, dynamic> map) =>
      StoreTransaction(
        id: map['id'],
        totalGross: map['total_gross'],
        totalNet: map['total_net'],
        serviceFee: map['service_fee'],
        paymentMethodId: map['payment_method_id'],
        createdByUserId: map['created_by_user_id'],
        createdAt: DateTime.parse(map['created_at']),
      );
}