import 'package:flutter/material.dart';
import '../models/return_item.dart';
import '../services/return_item_service.dart';

class ReturnManagementPage extends StatefulWidget {
  const ReturnManagementPage({super.key});

  @override
  State<ReturnManagementPage> createState() => _ReturnManagementPageState();
}

class _ReturnManagementPageState extends State<ReturnManagementPage> {
  List<ReturnItem> returns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    returns = await ReturnItemService.getAll();
    setState(() => isLoading = false);
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalRefund = returns.fold<int>(0, (s, r) => s + r.refundAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Return / Refund'),
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Total Summary
                  Container(
                    padding: EdgeInsets.all(20),
                    color: Color(0xFF667eea),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Refund',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatCurrency(totalRefund),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${returns.length}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Total Retur',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${returns.fold<int>(0, (s, r) => s + r.qty)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Total Item',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Returns List
                  if (returns.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.undo_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Belum ada return'),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: returns.length,
                      itemBuilder: (ctx, i) {
                        final ret = returns[i];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.undo, color: Colors.red),
                            ),
                            title: Text(ret.reason),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Qty: ${ret.qty}'),
                                Text(
                                  '${ret.createdAt.day}/${ret.createdAt.month}/${ret.createdAt.year}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                if (ret.notes != null && ret.notes!.isNotEmpty)
                                  Text(
                                    'Catatan: ${ret.notes}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              _formatCurrency(ret.refundAmount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
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
}
