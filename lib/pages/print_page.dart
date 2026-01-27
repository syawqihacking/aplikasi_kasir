import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/product.dart';
import '../models/transaction.dart';
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
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  bool isLoading = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => isLoading = true);
    try {
      final list = await bluetooth.getBondedDevices();
      setState(() {
        devices = list;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    setState(() => isLoading = true);
    try {
      await bluetooth.connect(device);
      setState(() {
        selectedDevice = device;
        isConnected = true;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terhubung: ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnectDevice() async {
    try {
      await bluetooth.disconnect();
      setState(() {
        selectedDevice = null;
        isConnected = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terputus dari printer'),
          backgroundColor: Color(0xFF3B82F6),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _printStruk() async {
    if (!isConnected || selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan hubungkan printer terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Header
      await bluetooth.write("================================\n");
      await bluetooth.write("        STRUK PENJUALAN\n");
      await bluetooth.write("================================\n\n");

      // Tanggal & Waktu
      final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
      final dateStr = formatter.format(widget.transaction.createdAt);
      await bluetooth.write("$dateStr\n");
      await bluetooth.write("ID: ${widget.transaction.id}\n\n");

      // Items
      await bluetooth.write("BARANG\n");
      await bluetooth.write("--------------------------------\n");

      int totalGross = widget.serviceFee;
      for (int i = 0; i < widget.products.length; i++) {
        final p = widget.products[i];
        final qty = widget.qtys[i];
        final subtotal = p.sellPrice * qty;
        totalGross += subtotal;

        await bluetooth.write("${p.name}\n");
        await bluetooth.write("$qty x Rp ${p.sellPrice} = Rp $subtotal\n");
      }

      // Divider
      await bluetooth.write("--------------------------------\n\n");

      // Summary
      await bluetooth.write("SUBTOTAL        Rp ${totalGross - widget.serviceFee}\n");
      await bluetooth.write("SERVICE FEE     Rp ${widget.serviceFee}\n");
      await bluetooth.write("TOTAL GROSS     Rp $totalGross\n\n");

      // Net profit

      // Footer
      await bluetooth.write("================================\n");
      await bluetooth.write("   TERIMA KASIH ATAS BELANJA\n");
      await bluetooth.write("================================\n\n\n");

      setState(() => isLoading = false);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Struk berhasil dicetak'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );

        // Auto close after 2 seconds
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

  void _showPrinterSelectionModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Printer Bluetooth',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (devices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.bluetooth_disabled,
                          size: 48, color: const Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      const Text(
                        'Tidak ada printer yang dipasangkan',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Muat Ulang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _loadDevices();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await _connectDevice(device);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.print,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.name ?? 'Unknown Device',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  device.address ?? 'MAC Address',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward,
                              color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
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
              /// PRINTER CONNECTION SECTION
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
                    /// STATUS DAN TOMBOL KONEKSI
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🖨️ Status Printer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isConnected
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isConnected
                                        ? const Color(0xFF86EFAC)
                                        : const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isConnected
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: isConnected
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFDC2626),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isConnected
                                          ? 'Terhubung'
                                          : 'Tidak Terhubung',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isConnected
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isConnected && selectedDevice != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFBFDBFE),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.bluetooth,
                                        color: Color(0xFF3B82F6),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedDevice?.name ??
                                              'Printer Bluetooth',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF3B82F6),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        /// TOMBOL KONEKSI/PUTUS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (isConnected)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Putus Koneksi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _disconnectDevice,
                              )
                            else
                              ElevatedButton.icon(
                                icon: const Icon(Icons.bluetooth, size: 18),
                                label: const Text('Pilih Printer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () => _showPrinterSelectionModal(),
                              ),
                          ],
                        ),
                      ],
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
    buffer.writeln("   TERIMA KASIH ATAS BELANJA");
    buffer.writeln("================================");

    return buffer.toString();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
