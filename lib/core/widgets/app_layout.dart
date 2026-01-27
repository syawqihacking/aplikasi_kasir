import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final int selectedIndex;
  final String title;
  final Widget child;
  final Function(int) onNavigate;

  const AppLayout({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.child,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // LIGHT CONTENT AREA
      body: Row(
        children: [
          // ================= SIDEBAR (DARK) =================
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: Color(0xFF0B1437),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'DATAKOM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _nav(Icons.dashboard, 'Dashboard', 0),
                _nav(Icons.inventory_2, 'Inventori', 1),
                _nav(Icons.point_of_sale, 'Kasir', 2),
                _nav(Icons.receipt_long, 'Laporan', 3),
              ],
            ),
          ),

          // ================= MAIN CONTENT =================
          Expanded(
            child: Column(
              children: [
                // HEADER
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                // PAGE BODY
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _nav(IconData icon, String label, int index) {
    return Builder(builder: (context) {
      final layout = context.findAncestorWidgetOfExactType<AppLayout>()!;
      final active = index == layout.selectedIndex;

      return InkWell(
        onTap: () => layout.onNavigate(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: active ? Colors.white : Colors.white70),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white70,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}