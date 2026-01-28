import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'database_service.dart';

class BackupService {
  /// Backup data penjualan (transactions)
  static Future<String> backupTransactions() async {
    try {
      final result = await DatabaseService.db.rawQuery('''
        SELECT t.*, 
               GROUP_CONCAT(ti.product_id || ',' || ti.qty || ',' || ti.sell_price || ',' || ti.buy_price, '|') as items
        FROM transactions t
        LEFT JOIN transaction_items ti ON ti.transaction_id = t.id
        GROUP BY t.id
        ORDER BY t.created_at DESC
      ''');

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filename = 'backup_penjualan_$timestamp.json';
      
      final data = {
        'backup_date': DateTime.now().toIso8601String(),
        'backup_type': 'penjualan',
        'total_records': result.length,
        'data': result,
      };

      final jsonData = jsonEncode(data);
      final file = File('/tmp/$filename');
      await file.writeAsString(jsonData);

      return file.path;
    } catch (e) {
      throw Exception('Gagal backup penjualan: $e');
    }
  }

  /// Backup data inventaris (products)
  static Future<String> backupInventory() async {
    try {
      final result = await DatabaseService.db.query('products');

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filename = 'backup_inventaris_$timestamp.json';
      
      final data = {
        'backup_date': DateTime.now().toIso8601String(),
        'backup_type': 'inventaris',
        'total_records': result.length,
        'data': result,
      };

      final jsonData = jsonEncode(data);
      final file = File('/tmp/$filename');
      await file.writeAsString(jsonData);

      return file.path;
    } catch (e) {
      throw Exception('Gagal backup inventaris: $e');
    }
  }

  /// Backup semua data
  static Future<Map<String, String>> backupAll() async {
    try {
      final transactionPath = await backupTransactions();
      final inventoryPath = await backupInventory();

      return {
        'transactions': transactionPath,
        'inventory': inventoryPath,
      };
    } catch (e) {
      throw Exception('Gagal backup semua data: $e');
    }
  }

  /// Get file size in human readable format
  static String getFileSize(File file) {
    if (!file.existsSync()) return '0 B';
    
    int bytes = file.lengthSync();
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// Get list of backup files
  static Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      final dir = Directory('/tmp');
      final files = dir.listSync();
      return files
          .where((f) => f.path.contains('backup_') && f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
    } catch (e) {
      return [];
    }
  }

  /// Delete backup file
  static Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Gagal hapus backup: $e');
    }
  }

  /// Export transactions to Excel
  static Future<String> exportTransactionsExcel() async {
    try {
      final result = await DatabaseService.db.rawQuery('''
        SELECT id, total_gross, total_net, service_fee, created_at
        FROM transactions
        ORDER BY created_at DESC
      ''');

      final excel = Excel.createExcel();
      final sheet = excel['Penjualan'];
      
      // Add headers
      sheet.appendRow([
        'ID',
        'Total Gross (Rp)',
        'Total Net (Rp)',
        'Service Fee (Rp)',
        'Tanggal',
      ]);

      // Add data
      for (var row in result) {
        sheet.appendRow([
          row['id'].toString(),
          row['total_gross'].toString(),
          row['total_net'].toString(),
          row['service_fee'].toString(),
          row['created_at'].toString(),
        ]);
      }

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filename = 'backup_penjualan_$timestamp.xlsx';
      final file = File('/tmp/$filename');
      
      List<int>? excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);
      }

      return file.path;
    } catch (e) {
      throw Exception('Gagal export penjualan ke Excel: $e');
    }
  }

  /// Export inventory to Excel
  static Future<String> exportInventoryExcel() async {
    try {
      final result = await DatabaseService.db.query('products');

      final excel = Excel.createExcel();
      final sheet = excel['Inventaris'];
      
      // Add headers
      sheet.appendRow([
        'ID',
        'SKU',
        'Nama',
        'Kategori',
        'Brand',
        'Harga Beli (Rp)',
        'Harga Jual (Rp)',
        'Stock',
        'Min Stock',
        'Garansi (Hari)',
      ]);

      // Add data
      for (var row in result) {
        sheet.appendRow([
          row['id'].toString(),
          row['sku'].toString(),
          row['name'].toString(),
          row['category'].toString(),
          row['brand'].toString(),
          row['buy_price'].toString(),
          row['sell_price'].toString(),
          row['stock'].toString(),
          row['min_stock'].toString(),
          row['warranty_days'].toString(),
        ]);
      }

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filename = 'backup_inventaris_$timestamp.xlsx';
      final file = File('/tmp/$filename');
      
      List<int>? excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);
      }

      return file.path;
    } catch (e) {
      throw Exception('Gagal export inventaris ke Excel: $e');
    }
  }

  /// Export all data to Excel
  static Future<Map<String, String>> exportAllExcel() async {
    try {
      final transactionPath = await exportTransactionsExcel();
      final inventoryPath = await exportInventoryExcel();

      return {
        'transactions': transactionPath,
        'inventory': inventoryPath,
      };
    } catch (e) {
      throw Exception('Gagal export semua data ke Excel: $e');
    }
  }
}
