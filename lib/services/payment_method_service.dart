import '../models/payment_method.dart';
import 'database_service.dart';

class PaymentMethodService {
  static Future<void> create(PaymentMethod method) async {
    await DatabaseService.db.insert('payment_methods', method.toMap());
  }

  static Future<List<PaymentMethod>> getAll() async {
    final maps = await DatabaseService.db.query('payment_methods');
    return maps.map((m) => PaymentMethod.fromMap(m)).toList();
  }

  static Future<List<PaymentMethod>> getActive() async {
    final maps = await DatabaseService.db.query(
      'payment_methods',
      where: 'is_active = 1',
    );
    return maps.map((m) => PaymentMethod.fromMap(m)).toList();
  }

  static Future<PaymentMethod?> getById(int id) async {
    final maps = await DatabaseService.db.query(
      'payment_methods',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isEmpty ? null : PaymentMethod.fromMap(maps.first);
  }

  static Future<void> update(PaymentMethod method) async {
    await DatabaseService.db.update(
      'payment_methods',
      method.toMap(),
      where: 'id = ?',
      whereArgs: [method.id],
    );
  }

  static Future<void> delete(int id) async {
    await DatabaseService.db.delete(
      'payment_methods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Initialize default payment methods
  static Future<void> initDefaults() async {
    final existing = await getAll();
    if (existing.isEmpty) {
      await create(PaymentMethod(name: 'Tunai', type: 'cash'));
      await create(PaymentMethod(name: 'Transfer Bank', type: 'transfer'));
      await create(PaymentMethod(name: 'E-Wallet', type: 'ewallet'));
      await create(PaymentMethod(name: 'Kartu Kredit', type: 'card'));
    }
  }
}
