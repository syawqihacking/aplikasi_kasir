class TransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final int qty;
  final int sellPrice;
  final int buyPrice;
  final double discountPercent;

  TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.qty,
    required this.sellPrice,
    required this.buyPrice,
    this.discountPercent = 0.0,
  });

  int get discountAmount => (sellPrice * discountPercent / 100).toInt();
  int get finalPrice => sellPrice - discountAmount;
  int get profit => (finalPrice - buyPrice) * qty;

  Map<String, dynamic> toMap() => {
        'id': id,
        'transaction_id': transactionId,
        'product_id': productId,
        'qty': qty,
        'sell_price': sellPrice,
        'buy_price': buyPrice,
        'discount_percent': discountPercent,
      };
}