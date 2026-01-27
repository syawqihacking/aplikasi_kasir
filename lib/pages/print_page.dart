import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../models/transaction.dart';
import '../services/printer_service.dart';
import 'pos_page.dart';

class PrintPage extends StatefulWidget {
  final List<Product> products;
  final List<int> qtys;
  final int serviceFee;
  final StoreTransaction transaction;

  const PrintPage({
    super.key,
    required this.products,
    required this.qtys,
    required this.serviceFee,
    required this.transaction,
  });

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _printStruk() async {
    setState(() => isLoading = true);
    try {
      await PrinterService().printReceipt(widget.products, widget.qtys, widget.serviceFee, widget.transaction);

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Struk berhasil dicetak'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PosPage()),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cetak: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Cetak Struk'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PRINTER INFO (USB / SYSTEM)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🖨️ Printer (USB / Sistem)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cetak akan menggunakan dialog cetak sistem. Pilih printer USB yang terpasang di perangkat Anda.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// STRUK PREVIEW
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Preview Struk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            style: BorderStyle.solid),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _buildStrukPreview(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: Color(0xFF1F2937),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// PRINT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.print, size: 20),
                  label: const Text('CETAK SEKARANG'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _printStruk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildStrukPreview() {
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    final dateStr = formatter.format(widget.transaction.createdAt);

    StringBuffer buffer = StringBuffer();
    buffer.writeln("================================");
    buffer.writeln("        STRUK PENJUALAN");
    buffer.writeln("================================");
    buffer.writeln();
    buffer.writeln(dateStr);
    buffer.writeln("ID: ${widget.transaction.id}");
    buffer.writeln();
    buffer.writeln("BARANG");
    buffer.writeln("--------------------------------");

    int totalGross = widget.serviceFee;
    for (int i = 0; i < widget.products.length; i++) {
      final p = widget.products[i];
      final qty = widget.qtys[i];
      final subtotal = p.sellPrice * qty;
      totalGross += subtotal;

      buffer.writeln("${p.name}");
      buffer.writeln("$qty x Rp ${p.sellPrice} = Rp $subtotal");
    }

    buffer.writeln("--------------------------------");
    buffer.writeln();
    buffer.writeln(
        "SUBTOTAL        Rp ${totalGross - widget.serviceFee}");
    buffer.writeln("SERVICE FEE     Rp ${widget.serviceFee}");
    buffer.writeln("TOTAL GROSS     Rp $totalGross");
    buffer.writeln();
    buffer.writeln(
        "LABA BERSIH     Rp ${widget.transaction.totalNet}");
    buffer.writeln();
    buffer.writeln("================================");
    buffer.writeln("   TERIMA KASIH SUDAH BELANJA");
    buffer.writeln("================================");

    return buffer.toString();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
