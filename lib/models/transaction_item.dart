class TransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final int qty;
  final int sellPrice;
  final int buyPrice;

  TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.qty,
    required this.sellPrice,
    required this.buyPrice,
  });

  int get profit => (sellPrice - buyPrice) * qty;

  Map<String, dynamic> toMap() => {
        'id': id,
        'transaction_id': transactionId,
        'product_id': productId,
        'qty': qty,
        'sell_price': sellPrice,
        'buy_price': buyPrice,
      };
}