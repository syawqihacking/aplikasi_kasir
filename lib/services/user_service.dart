import '../models/user.dart';
import 'database_service.dart';

class UserService {
  static Future<void> create(User user) async {
    await DatabaseService.db.insert('users', user.toMap());
  }

  static Future<List<User>> getAll() async {
    final maps = await DatabaseService.db.query('users');
    return maps.map((m) => User.fromMap(m)).toList();
  }

  static Future<User?> getById(int id) async {
    final maps = await DatabaseService.db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  static Future<User?> getByEmail(String email) async {
    final maps = await DatabaseService.db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  static Future<User?> login(String email, String password) async {
    final maps = await DatabaseService.db.query(
      'users',
      where: 'email = ? AND password = ? AND is_active = 1',
      whereArgs: [email, password],
    );
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  static Future<void> update(User user) async {
    await DatabaseService.db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<void> toggleActive(int userId) async {
    final user = await getById(userId);
    if (user == null) return;
    await update(user.copyWith(isActive: !user.isActive));
  }

  static Future<void> delete(int id) async {
    await DatabaseService.db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> countActive() async {
    final result = await DatabaseService.db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE is_active = 1',
    );
    return result.first['count'] as int;
  }
}
