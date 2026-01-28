import 'database_service.dart';

class ReportService {
  static Future<int> totalGrossToday() async {
    final result = await DatabaseService.db.rawQuery('''
      SELECT SUM(total_gross) as total
      FROM transactions
      WHERE date(created_at) = date('now')
    ''');
    return (result.first['total'] as int?) ?? 0;
  }

  static Future<int> totalNetToday() async {
    final result = await DatabaseService.db.rawQuery('''
      SELECT SUM(total_net) as total
      FROM transactions
      WHERE date(created_at) = date('now')
    ''');
    return (result.first['total'] as int?) ?? 0;
  }

  static Future<int> totalGrossDateRange(DateTime start, DateTime end) async {
    final result = await DatabaseService.db.rawQuery('''
      SELECT SUM(total_gross) as total
      FROM transactions
      WHERE date(created_at) BETWEEN date(?) AND date(?)
    ''', [start.toIso8601String(), end.toIso8601String()]);
    return (result.first['total'] as int?) ?? 0;
  }

  static Future<int> totalNetDateRange(DateTime start, DateTime end) async {
    final result = await DatabaseService.db.rawQuery('''
      SELECT SUM(total_net) as total
      FROM transactions
      WHERE date(created_at) BETWEEN date(?) AND date(?)
    ''', [start.toIso8601String(), end.toIso8601String()]);
    return (result.first['total'] as int?) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> transactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return DatabaseService.db.rawQuery('''
      SELECT *
      FROM transactions
      WHERE date(created_at) BETWEEN date(?) AND date(?)
      ORDER BY created_at DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

  static Future<List<Map<String, dynamic>>> transactionItems(int trxId) async {
    return DatabaseService.db.rawQuery('''
      SELECT ti.qty, ti.sell_price, p.name
      FROM transaction_items ti
      JOIN products p ON p.id = ti.product_id
      WHERE ti.transaction_id = ?
    ''', [trxId]);
  }

  /// Get daily revenue for a date range
  static Future<Map<DateTime, int>> dailyRevenueByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final result = await DatabaseService.db.rawQuery('''
      SELECT date(created_at) as date, SUM(total_gross) as total
      FROM transactions
      WHERE date(created_at) BETWEEN date(?) AND date(?)
      GROUP BY date(created_at)
      ORDER BY date(created_at)
    ''', [start.toIso8601String(), end.toIso8601String()]);

    final Map<DateTime, int> dailyRevenue = {};

    for (var row in result) {
      final dateStr = row['date'] as String;
      final date = DateTime.parse(dateStr);
      final total = (row['total'] as int?) ?? 0;
      dailyRevenue[date] = total;
    }

    return dailyRevenue;
  }
}