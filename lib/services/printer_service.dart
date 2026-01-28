import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/product.dart';
import '../models/transaction.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();

  factory PrinterService() => _instance;

  PrinterService._internal();

  Future<Uint8List> generateReceiptPdf(
    List<Product> products,
    List<int> qtys,
    int serviceFee,
    StoreTransaction trx,
  ) async {
    final doc = pw.Document();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm:ss');
    final dateStr = dateFmt.format(trx.createdAt);

    final subtotal = products.asMap().entries.fold<int>(0, (s, e) => s + e.value.sellPrice * qtys[e.key]);
    final totalGross = subtotal + serviceFee;

    doc.addPage(
      pw.Page(
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text('STRUK PENJUALAN', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 6),
                pw.Text(dateStr),
                pw.Text('ID: ${trx.id}'),
                pw.SizedBox(height: 8),
                pw.Text('BARANG', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                ...List.generate(products.length, (i) {
                  final p = products[i];
                  final qty = qtys[i];
                  final lineTotal = p.sellPrice * qty;
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(p.name),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('$qty x ${currency.format(p.sellPrice)}'),
                          pw.Text(currency.format(lineTotal)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                    ],
                  );
                }),
                pw.Divider(),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('SUBTOTAL'), pw.Text(currency.format(subtotal))]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('SERVICE FEE'), pw.Text(currency.format(serviceFee))]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('TOTAL GROSS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(currency.format(totalGross), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
                pw.SizedBox(height: 8),
                pw.Text('TERIMA KASIH ATAS BELANJA ANDA', style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  Future<void> printReceipt(
    List<Product> products,
    List<int> qtys,
    int serviceFee,
    StoreTransaction trx,
  ) async {
    final bytes = await generateReceiptPdf(products, qtys, serviceFee, trx);
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  /// Check if printer is available on the system
  Future<bool> isPrinterAvailable() async {
    try {
      final info = await Printing.info();
      return info.canPrint;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available printers
  Future<List<String>> getAvailablePrinters() async {
    try {
      final printers = await Printing.listPrinters();
      return printers.map((p) => p.name).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get printer details including name and status
  Future<List<Map<String, String>>> getPrinterDetails() async {
    try {
      final printers = await Printing.listPrinters();
      return printers
          .map((p) => {
                'name': p.name,
                'isDefault': p.isDefault ? 'Ya' : 'Tidak',
                'url': p.url,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }
}
