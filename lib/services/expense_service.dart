import '../models/expense.dart';
import 'database_service.dart';

class ExpenseService {
  static Future<int> create(Expense expense) async {
    return await DatabaseService.db.insert('expenses', expense.toMap());
  }

  static Future<List<Expense>> getAll() async {
    final maps = await DatabaseService.db.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  static Future<List<Expense>> getByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final maps = await DatabaseService.db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  static Future<List<Expense>> getByDateRange(DateTime start, DateTime end) async {
    final maps = await DatabaseService.db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  static Future<List<Expense>> getByCategory(String category) async {
    final maps = await DatabaseService.db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  static Future<Expense?> getById(int id) async {
    final maps = await DatabaseService.db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isEmpty ? null : Expense.fromMap(maps.first);
  }

  static Future<void> update(Expense expense) async {
    await DatabaseService.db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  static Future<void> delete(int id) async {
    await DatabaseService.db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> getTotalExpenses() async {
    final result = await DatabaseService.db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses',
    );
    return result.first['total'] as int;
  }

  static Future<int> getTotalExpensesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await DatabaseService.db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE date >= ? AND date < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.first['total'] as int;
  }

  static Future<Map<String, int>> getTotalByCategory() async {
    final result = await DatabaseService.db.rawQuery(
      'SELECT category, SUM(amount) as total FROM expenses GROUP BY category',
    );
    final map = <String, int>{}; 
    for (final row in result) {
      map[row['category'] as String] = row['total'] as int;
    }
    return map;
  }
}
