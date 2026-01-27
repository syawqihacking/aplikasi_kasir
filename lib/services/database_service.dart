import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Database get db => _db!;

  static Future<void> init() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'datacom_jember.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sku TEXT,
            name TEXT,
            category TEXT,
            brand TEXT,
            buy_price INTEGER,
            sell_price INTEGER,
            stock INTEGER,
            min_stock INTEGER,
            warranty_days INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            total_gross INTEGER,
            total_net INTEGER,
            service_fee INTEGER,
            created_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE transaction_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id INTEGER,
            product_id INTEGER,
            qty INTEGER,
            sell_price INTEGER,
            buy_price INTEGER
          )
        ''');
      },
    );
  }
}