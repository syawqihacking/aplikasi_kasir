import 'package:flutter/material.dart';
import '../models/return_item.dart';
import '../services/return_item_service.dart';

class ReturnDialog extends StatefulWidget {
  final int transactionId;
  final Function() onSuccess;

  const ReturnDialog({
    super.key,
    required this.transactionId,
    required this.onSuccess,
  });

  @override
  State<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<ReturnDialog> {
  final reasonCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  int qtyReturn = 1;
  int refundAmount = 0;
  bool isLoading = false;

  Future<void> _submit() async {
    if (reasonCtrl.text.isEmpty || refundAmount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi semua field')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ReturnItemService.create(
        ReturnItem(
          transactionId: widget.transactionId,
          productId: 0, // Akan di-track di transaction_items
          qty: qtyReturn,
          reason: reasonCtrl.text,
          refundAmount: refundAmount,
          createdAt: DateTime.now(),
          notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Retur berhasil dicatat'),
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
      title: Text('Catat Retur Barang'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: 'Alasan Retur',
                hintText: 'Rusak, Salah barang, dll',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Qty Retur',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      setState(() => qtyReturn = int.tryParse(v) ?? 1);
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Jumlah Refund',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      setState(() => refundAmount = int.tryParse(v) ?? 0);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              decoration: InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              : Text('Simpan Retur'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }
}
