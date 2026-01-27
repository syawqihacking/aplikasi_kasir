class StoreTransaction {
  final int? id;
  final int totalGross;
  final int totalNet;
  final int serviceFee;
  final DateTime createdAt;

  StoreTransaction({
    this.id,
    required this.totalGross,
    required this.totalNet,
    required this.serviceFee,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'total_gross': totalGross,
        'total_net': totalNet,
        'service_fee': serviceFee,
        'created_at': createdAt.toIso8601String(),
      };

  factory StoreTransaction.fromMap(Map<String, dynamic> map) =>
      StoreTransaction(
        id: map['id'],
        totalGross: map['total_gross'],
        totalNet: map['total_net'],
        serviceFee: map['service_fee'],
        createdAt: DateTime.parse(map['created_at']),
      );
}