import '../models/product.dart';
import 'database_service.dart';

class ProductService {
  static Future<List<Product>> getAll() async {
    final result =
        await DatabaseService.db.query('products', orderBy: 'name');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  static Future<void> insert(Product p) async {
    await DatabaseService.db.insert('products', p.toMap());
  }

  static Future<void> update(Product p) async {
    await DatabaseService.db.update(
      'products',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  static Future<void> delete(int id) async {
    await DatabaseService.db
        .delete('products', where: 'id = ?', whereArgs: [id]);
  }
}