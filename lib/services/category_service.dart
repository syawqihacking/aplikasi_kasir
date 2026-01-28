import '../models/category.dart';
import 'database_service.dart';

class CategoryService {
  static Future<void> create(Category category) async {
    await DatabaseService.db.insert('categories', category.toMap());
  }

  static Future<List<Category>> getAll() async {
    final maps = await DatabaseService.db.query('categories');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  static Future<Category?> getById(int id) async {
    final maps = await DatabaseService.db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isEmpty ? null : Category.fromMap(maps.first);
  }

  static Future<void> update(Category category) async {
    await DatabaseService.db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<void> delete(int id) async {
    await DatabaseService.db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
