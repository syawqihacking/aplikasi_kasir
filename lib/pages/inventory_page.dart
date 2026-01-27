import 'package:flutter/material.dart';
import '../core/widgets/app_layout.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_form_dialog.dart';
import 'dashboard_page.dart';
import 'pos_page.dart';
import 'reports_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Product> products = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    products = await ProductService.getAll();
    setState(() {});
  }

  List<Product> get filteredProducts {
    if (searchQuery.isEmpty) {
      return products;
    }
    return products
        .where((p) =>
            p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.sku.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _nav(int i) {
    switch (i) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const PosPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ReportsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      selectedIndex: 1,
      title: 'Inventori',
      onNavigate: _nav,
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '📦 Daftar Produk',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Produk'),
                        onPressed: () async {
                          final result = await showDialog<Product>(
                            context: context,
                            builder: (context) => ProductFormDialog(
                              product: null,
                            ),
                          );
                          if (result != null) {
                            try {
                              await ProductService.insert(result);
                              _load();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✓ Produk berhasil ditambahkan'),
                                    backgroundColor: Color(0xFF16A34A),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  /// SEARCH BAR
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                        hintText: 'Cari nama atau kode produk...',
                        hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                        suffixIcon: searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () => setState(() => searchQuery = ''),
                                child: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// CARD LIST CONTAINER
            Expanded(
              child: Column(
                children: [
                  /// TABLE HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        /// SKU Header
                        Expanded(
                          flex: 2,
                          child: Text('🆔 CODE',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ),
                        /// Nama Produk Header
                        Expanded(
                          flex: 3,
                          child: Text('📝 Nama Produk',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ),
                        /// Stok Header
                        Expanded(
                          flex: 1,
                          child: Text('📦 Stok',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ),
                        /// Harga Beli Header
                        Expanded(
                          flex: 1,
                          child: Text('💰 Beli',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ),
                        /// Harga Jual Header
                        Expanded(
                          flex: 1,
                          child: Text('💵 Jual',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ),
                        /// Margin Header
                        Expanded(
                          flex: 1,
                          child: Text('📈 Margin',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ),
                        /// Aksi Header
                        SizedBox(
                          width: 100,
                          child: Text('⚙️ Aksi',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ),
                      ],
                    ),
                  ),
                  /// LIST CONTENT
                  Expanded(
                    child: products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64, color: const Color(0xFFCBD5E1)),
                                const SizedBox(height: 12),
                                const Text('Belum ada produk',
                                    style: TextStyle(
                                        color: Color(0xFF94A3B8), fontSize: 16)),
                              ],
                            ),
                          )
                        : filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 64, color: const Color(0xFFCBD5E1)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Produk "$searchQuery" tidak ditemukan',
                                      style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: filteredProducts.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) {
                                  final p = filteredProducts[i];
                                  final margin = p.sellPrice - p.buyPrice;
                                  final isLowStock = p.stock <= p.minStock && p.stock > 0;
                                  final isOutOfStock = p.stock <= 0;

                                  return _buildProductCard(p, margin, isLowStock, isOutOfStock, context);
                                },
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

  Widget _buildProductCard(Product p, int margin, bool isLowStock, bool isOutOfStock, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// SKU (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.sku,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3B82F6),
                          fontSize: 13)),
                  Text('ID: ${p.id ?? '-'}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFCBD5E1))),
                ],
              ),
            ),

            /// NAMA (flex: 3)
            Expanded(
              flex: 3,
              child: Text(p.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      fontSize: 14)),
            ),

            /// STOK (flex: 1)
            Expanded(
              flex: 1,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? const Color(0xFFFEE2E2)
                      : isLowStock
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${p.stock}',
                    style: TextStyle(
                      color: isOutOfStock
                          ? const Color(0xFFDC2626)
                          : isLowStock
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF16A34A),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    )),
              ),
            ),

            /// HARGA BELI (flex: 1)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Beli',
                      style: TextStyle(
                          fontSize: 10, color: Color(0xFFCBD5E1))),
                  Text('Rp ${p.buyPrice}',
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),

            /// HARGA JUAL (flex: 1)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jual',
                      style: TextStyle(
                          fontSize: 10, color: Color(0xFFCBD5E1))),
                  Text('Rp ${p.sellPrice}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          fontSize: 12)),
                ],
              ),
            ),

            /// MARGIN (flex: 1)
            Expanded(
              flex: 1,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: margin >= 0
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Rp $margin',
                  style: TextStyle(
                    color: margin >= 0
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            /// ACTIONS
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Tooltip(
                    message: 'Edit',
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await showDialog<Product>(
                            context: context,
                            builder: (context) =>
                                ProductFormDialog(product: p),
                          );
                          if (result != null) {
                            try {
                              await ProductService.update(result);
                              _load();
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        '✓ Produk berhasil diperbarui'),
                                    backgroundColor: Color(0xFF16A34A),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9D5FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit,
                              size: 16, color: Color(0xFF7C3AED)),
                        ),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Hapus',
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Produk'),
                              content: Text(
                                  'Yakin ingin menghapus "${p.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Hapus',
                                      style:
                                          TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && p.id != null) {
                            await ProductService.delete(p.id!);
                            _load();
                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('✓ Produk berhasil dihapus'),
                                  backgroundColor: Color(0xFF16A34A),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete,
                              size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}