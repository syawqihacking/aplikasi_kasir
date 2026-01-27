import 'package:flutter/material.dart';
import '../core/widgets/app_layout.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/product_service.dart';
import '../services/transaction_service.dart';
import '../services/report_service.dart';
import 'dashboard_page.dart';
import 'inventory_page.dart';
import 'reports_page.dart';
import 'print_page.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  List<Product> products = [];
  final Map<Product, int> cart = {};
  final TextEditingController serviceCtrl = TextEditingController(text: '0');
  String search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    products = await ProductService.getAll();
    setState(() {});
  }

  void _nav(int i) {
    switch (i) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardPage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const InventoryPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ReportsPage()));
        break;
    }
  }

  int get serviceFee => int.tryParse(serviceCtrl.text) ?? 0;
  int get totalBarang =>
      cart.entries.fold(0, (s, e) => s + e.key.sellPrice * e.value);
  int get totalGross => totalBarang + serviceFee;
  int get totalNet => cart.entries.fold(
      serviceFee, (s, e) => s + (e.key.sellPrice - e.key.buyPrice) * e.value);

  @override
  Widget build(BuildContext context) {
    final filtered = products
        .where((p) =>
            p.name.toLowerCase().contains(search.toLowerCase()) ||
            p.sku.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return AppLayout(
      selectedIndex: 2,
      title: 'Kasir',
      onNavigate: _nav,
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            /// LEFT — PRODUCT LIST
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                        hintText: 'Cari SKU / Nama Produk',
                        hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (v) => setState(() => search = v),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('Stok: ${p.stock}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Rp ${p.sellPrice}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
                              ],
                            ),
                            onTap: () =>
                                setState(() => cart[p] = (cart[p] ?? 0) + 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            /// RIGHT — CART & SUMMARY
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📦 Keranjang Belanja',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                          const SizedBox(height: 16),
                          Expanded(
                            child: cart.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.shopping_cart_outlined,
                                            size: 48, color: const Color(0xFFCBD5E1)),
                                        const SizedBox(height: 8),
                                        const Text('Keranjang kosong',
                                            style: TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontSize: 14)),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    separatorBuilder: (_, __) => const Divider(height: 16),
                                    itemCount: cart.length,
                                    itemBuilder: (_, i) {
                                      final e = cart.entries.elementAt(i);
                                      return Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(e.key.name,
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.w600, fontSize: 13)),
                                                  Text(
                                                      '${e.value} x Rp ${e.key.sellPrice}',
                                                      style: const TextStyle(
                                                          fontSize: 12, color: Color(0xFF64748B))),
                                                ],
                                              ),
                                            ),
                                            Text('Rp ${e.value * e.key.sellPrice}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const Divider(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: TextField(
                              controller: serviceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: 'Jasa Servis (100% laba)',
                                  hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                                  prefixText: 'Rp ',
                                  border: InputBorder.none),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL BAYAR',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('Rp $totalGross',
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Laba Bersih: Rp $totalNet',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Selesaikan Transaksi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF3B82F6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (cart.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Keranjang masih kosong')),
                                );
                                return;
                              }
                              
                              final cartProducts = cart.keys.toList();
                              final cartQtys = cart.values.toList();
                              final now = DateTime.now();
                              
                              // Create transaction
                              await TransactionService.createTransaction(
                                products: cartProducts,
                                qtys: cartQtys,
                                serviceFee: serviceFee,
                              );
                              
                              // Get last transaction
                              final transactions = await ReportService.transactionsByDateRange(
                                DateTime(now.year, now.month, now.day),
                                DateTime(now.year, now.month, now.day, 23, 59, 59),
                              );
                              
                              if (transactions.isNotEmpty) {
                                final lastTrx = transactions.first;
                                int grossTotal = serviceFee;
                                for (final product in cartProducts) {
                                  grossTotal += product.sellPrice * (cart[product] ?? 0);
                                }
                                
                                final transaction = StoreTransaction(
                                  id: lastTrx['id'],
                                  totalGross: grossTotal,
                                  totalNet: lastTrx['total_net'],
                                  serviceFee: serviceFee,
                                  createdAt: DateTime.parse(lastTrx['created_at']),
                                );
                                
                                cart.clear();
                                serviceCtrl.clear();
                                setState(() {});
                                
                                // Navigate to print page
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PrintPage(
                                        products: cartProducts,
                                        qtys: cartQtys,
                                        serviceFee: serviceFee,
                                        transaction: transaction,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}