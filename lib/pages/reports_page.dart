import 'package:flutter/material.dart';
import '../core/widgets/app_layout.dart';
import '../services/report_service.dart';
import 'dashboard_page.dart';
import 'inventory_page.dart';
import 'pos_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTimeRange? range;
  List<Map<String, dynamic>> transactions = [];

  void _navigate(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardPage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const InventoryPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const PosPage()));
        break;
    }
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    range = picked;
    transactions = await ReportService.transactionsByDateRange(
      picked.start,
      picked.end,
    );
    setState(() {});
  }

  Future<void> _showDetail(int trxId) async {
    final items = await ReportService.transactionItems(trxId);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Transaksi'),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: items
                .map(
                  (i) => ListTile(
                    title: Text(
                      i['name'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing:
                        Text('${i['qty']} x Rp ${i['sell_price']}'),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      selectedIndex: 3,
      title: 'Laporan',
      onNavigate: _navigate,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Histori Transaksi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (range != null)
                        Text(
                          '${range!.start.day}/${range!.start.month}/${range!.start.year} - ${range!.end.day}/${range!.end.month}/${range!.end.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.date_range, size: 18),
                    label: const Text('Pilih Tanggal'),
                    onPressed: _pickRange,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// LIST TRANSAKSI
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 56,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada data transaksi',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pilih tanggal untuk melihat riwayat transaksi',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final t = transactions[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Rp ${t['total_gross']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.trending_up,
                                        size: 14,
                                        color: Colors.green[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Laba: Rp ${t['total_net']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.schedule,
                                        size: 14,
                                        color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Text(
                                      t['created_at'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Color(0xFF3B82F6),
                                    size: 20,
                                  ),
                                  onPressed: () => _showDetail(t['id']),
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}