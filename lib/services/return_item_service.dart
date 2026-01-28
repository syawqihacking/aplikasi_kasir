import '../models/return_item.dart';
import 'database_service.dart';

class ReturnItemService {
  static Future<int> create(ReturnItem returnItem) async {
    return await DatabaseService.db.insert('return_items', returnItem.toMap());
  }

  static Future<List<ReturnItem>> getAll() async {
    final maps = await DatabaseService.db.query('return_items');
    return maps.map((m) => ReturnItem.fromMap(m)).toList();
  }

  static Future<List<ReturnItem>> getByTransactionId(int transactionId) async {
    final maps = await DatabaseService.db.query(
      'return_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
    return maps.map((m) => ReturnItem.fromMap(m)).toList();
  }

  static Future<ReturnItem?> getById(int id) async {
    final maps = await DatabaseService.db.query(
      'return_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isEmpty ? null : ReturnItem.fromMap(maps.first);
  }

  static Future<void> update(ReturnItem returnItem) async {
    await DatabaseService.db.update(
      'return_items',
      returnItem.toMap(),
      where: 'id = ?',
      whereArgs: [returnItem.id],
    );
  }

  static Future<void> delete(int id) async {
    await DatabaseService.db.delete(
      'return_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> getTotalRefunds() async {
    final result = await DatabaseService.db.rawQuery(
      'SELECT COALESCE(SUM(refund_amount), 0) as total FROM return_items',
    );
    return result.first['total'] as int;
  }

  static Future<int> getTotalRefundsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await DatabaseService.db.rawQuery(
      'SELECT COALESCE(SUM(refund_amount), 0) as total FROM return_items WHERE created_at >= ? AND created_at < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.first['total'] as int;
  }
}
