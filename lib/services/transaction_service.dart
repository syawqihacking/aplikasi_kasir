import '../models/product.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/return_item.dart';
import 'database_service.dart';
import 'return_item_service.dart';

class TransactionService {
  static Future<int> createTransaction({
    required List<Product> products,
    required List<int> qtys,
    required int serviceFee,
    int? paymentMethodId,
    int? createdByUserId,
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
        paymentMethodId: paymentMethodId,
        createdByUserId: createdByUserId,
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

    return trxId;
  }

  static Future<StoreTransaction?> getById(int id) async {
    final maps = await DatabaseService.db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isEmpty ? null : StoreTransaction.fromMap(maps.first);
  }

  static Future<List<StoreTransaction>> getAll() async {
    final maps = await DatabaseService.db.query(
      'transactions',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => StoreTransaction.fromMap(m)).toList();
  }

  static Future<List<StoreTransaction>> getByUserId(int userId) async {
    final maps = await DatabaseService.db.query(
      'transactions',
      where: 'created_by_user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => StoreTransaction.fromMap(m)).toList();
  }

  static Future<List<StoreTransaction>> getByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await DatabaseService.db.query(
      'transactions',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => StoreTransaction.fromMap(m)).toList();
  }

  // Refund transaction (full or partial)
  static Future<void> refundTransaction({
    required int transactionId,
    required int productId,
    required int qty,
    required String reason,
    String? notes,
  }) async {
    final db = DatabaseService.db;
    
    // Get transaction items
    final itemMaps = await db.query(
      'transaction_items',
      where: 'transaction_id = ? AND product_id = ?',
      whereArgs: [transactionId, productId],
    );

    if (itemMaps.isEmpty) return;

    final item = itemMaps.first;
    final refundAmount = (item['sell_price'] as int) * qty;

    // Create return record
    await ReturnItemService.create(
      ReturnItem(
        transactionId: transactionId,
        productId: productId,
        qty: qty,
        reason: reason,
        refundAmount: refundAmount,
        createdAt: DateTime.now(),
        notes: notes,
      ),
    );

    // Restore stock
    await db.rawUpdate(
      'UPDATE products SET stock = stock + ? WHERE id = ?',
      [qty, productId],
    );

    // Update transaction total
    final txn = await getById(transactionId);
    if (txn != null) {
      final updatedGross = txn.totalGross - refundAmount;
      final netDeduction = ((item['sell_price'] as int) - (item['buy_price'] as int)) * qty;
      final updatedNet = txn.totalNet - netDeduction;

      await db.update(
        'transactions',
        {
          'total_gross': updatedGross,
          'total_net': updatedNet,
        },
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    }
  }

  static Future<int> getTotalByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await DatabaseService.db.rawQuery(
      'SELECT COALESCE(SUM(total_gross), 0) as total FROM transactions WHERE created_at >= ? AND created_at < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.first['total'] as int;
  }

  static Future<int> getProfitByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await DatabaseService.db.rawQuery(
      'SELECT COALESCE(SUM(total_net), 0) as total FROM transactions WHERE created_at >= ? AND created_at < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.first['total'] as int;
  }
}