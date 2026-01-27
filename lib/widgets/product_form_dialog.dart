import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController sku;
  late TextEditingController name;
  late TextEditingController category;
  late TextEditingController brand;
  late TextEditingController buyPrice;
  late TextEditingController sellPrice;
  late TextEditingController stock;
  late TextEditingController minStock;
  late TextEditingController warranty;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    sku = TextEditingController(text: p?.sku ?? '');
    name = TextEditingController(text: p?.name ?? '');
    category = TextEditingController(text: p?.category ?? '');
    brand = TextEditingController(text: p?.brand ?? '');
    buyPrice = TextEditingController(text: p?.buyPrice.toString() ?? '');
    sellPrice = TextEditingController(text: p?.sellPrice.toString() ?? '');
    stock = TextEditingController(text: p?.stock.toString() ?? '');
    minStock = TextEditingController(text: p?.minStock.toString() ?? '');
    warranty = TextEditingController(text: p?.warrantyDays.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(sku, 'SKU'),
                _field(name, 'Nama Produk'),
                _field(category, 'Kategori'),
                _field(brand, 'Brand'),
                _field(buyPrice, 'Harga Beli', number: true),
                _field(sellPrice, 'Harga Jual', number: true),
                _field(stock, 'Stok', number: true),
                _field(minStock, 'Minimal Stok', number: true),
                _field(warranty, 'Garansi (hari)', number: true),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop(
              context,
              Product(
                id: widget.product?.id,
                sku: sku.text,
                name: name.text,
                category: category.text,
                brand: brand.text,
                buyPrice: int.parse(buyPrice.text),
                sellPrice: int.parse(sellPrice.text),
                stock: int.parse(stock.text),
                minStock: int.parse(minStock.text),
                warrantyDays: int.parse(warranty.text),
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}