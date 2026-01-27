import '../models/product.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import 'database_service.dart';

class TransactionService {
  static Future<void> createTransaction({
    required List<Product> products,
    required List<int> qtys,
    required int serviceFee,
  }) async {
    final db = DatabaseService.db;

    int gross = serviceFee;
    int net = serviceFee;

    for (int i = 0; i < products.length; i++) {
      gross += products[i].sellPrice * qtys[i];
      net += (products[i].sellPrice - products[i].buyPrice) * qtys[i];
    }

    final trxId = await db.insert(
      'transactions',
      StoreTransaction(
        totalGross: gross,
        totalNet: net,
        serviceFee: serviceFee,
        createdAt: DateTime.now(),
      ).toMap(),
    );

    for (int i = 0; i < products.length; i++) {
      await db.insert(
        'transaction_items',
        TransactionItem(
          transactionId: trxId,
          productId: products[i].id!,
          qty: qtys[i],
          sellPrice: products[i].sellPrice,
          buyPrice: products[i].buyPrice,
        ).toMap(),
      );

      await db.rawUpdate(
        'UPDATE products SET stock = stock - ? WHERE id = ?',
        [qtys[i], products[i].id],
      );
    }
  }
}