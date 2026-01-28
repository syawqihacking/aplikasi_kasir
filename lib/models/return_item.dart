class ReturnItem {
  final int? id;
  final int transactionId;
  final int productId;
  final int qty;
  final String reason;
  final int refundAmount;
  final DateTime createdAt;
  final String? notes;

  ReturnItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.qty,
    required this.reason,
    required this.refundAmount,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'transaction_id': transactionId,
        'product_id': productId,
        'qty': qty,
        'reason': reason,
        'refund_amount': refundAmount,
        'created_at': createdAt.toIso8601String(),
        'notes': notes,
      };

  factory ReturnItem.fromMap(Map<String, dynamic> map) => ReturnItem(
        id: map['id'],
        transactionId: map['transaction_id'],
        productId: map['product_id'],
        qty: map['qty'],
        reason: map['reason'],
        refundAmount: map['refund_amount'],
        createdAt: DateTime.parse(map['created_at']),
        notes: map['notes'],
      );
}
