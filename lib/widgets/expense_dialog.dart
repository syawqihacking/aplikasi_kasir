import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseDialog extends StatefulWidget {
  final Function() onSuccess;
  final int? userId;

  const ExpenseDialog({
    super.key,
    required this.onSuccess,
    this.userId,
  });

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final descriptionCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String selectedCategory = 'Supplies';
  bool isLoading = false;

  final expenseCategories = [
    'Supplies',
    'Utilities',
    'Maintenance',
    'Transportation',
    'Other',
  ];

  Future<void> _submit() async {
    if (descriptionCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi semua field')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ExpenseService.create(
        Expense(
          category: selectedCategory,
          amount: int.parse(amountCtrl.text),
          description: descriptionCtrl.text,
          date: DateTime.now(),
          createdByUserId: widget.userId,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengeluaran berhasil dicatat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Catat Pengeluaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: expenseCategories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedCategory = val);
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionCtrl,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              decoration: InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Simpan'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    descriptionCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }
}
