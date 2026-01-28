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
      version: 3,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT,
            is_active INTEGER DEFAULT 1,
            created_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            description TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE payment_methods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            is_active INTEGER DEFAULT 1
          )
        ''');

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
            payment_method_id INTEGER,
            created_by_user_id INTEGER,
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

        await db.execute('''
          CREATE TABLE return_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id INTEGER,
            product_id INTEGER,
            qty INTEGER,
            reason TEXT,
            refund_amount INTEGER,
            created_at TEXT,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            amount INTEGER,
            description TEXT,
            date TEXT,
            created_by_user_id INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle migrations from older versions
        if (oldVersion < 3) {
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                email TEXT UNIQUE,
                password TEXT,
                role TEXT,
                is_active INTEGER DEFAULT 1,
                created_at TEXT
              )
            ''');
          } catch (_) {}

          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT UNIQUE,
                description TEXT
              )
            ''');
          } catch (_) {}

          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS payment_methods (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                type TEXT,
                is_active INTEGER DEFAULT 1
              )
            ''');
          } catch (_) {}

          try {
            await db.execute('''
              ALTER TABLE transactions ADD COLUMN payment_method_id INTEGER
            ''');
          } catch (_) {}

          try {
            await db.execute('''
              ALTER TABLE transactions ADD COLUMN created_by_user_id INTEGER
            ''');
          } catch (_) {}

          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS return_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                transaction_id INTEGER,
                product_id INTEGER,
                qty INTEGER,
                reason TEXT,
                refund_amount INTEGER,
                created_at TEXT,
                notes TEXT
              )
            ''');
          } catch (_) {}

          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS expenses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                category TEXT,
                amount INTEGER,
                description TEXT,
                date TEXT,
                created_by_user_id INTEGER
              )
            ''');
          } catch (_) {}
        }
      },
    );
  }
}