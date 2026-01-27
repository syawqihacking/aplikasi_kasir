import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/widgets/app_layout.dart';
import '../services/report_service.dart';
import 'inventory_page.dart';
import 'pos_page.dart';
import 'reports_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int grossToday = 0;
  int netToday = 0;
  int grossPeriod = 0;
  int netPeriod = 0;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  Map<DateTime, int> dailyRevenue = {};
  bool isDateRangeSelected = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    grossToday = await ReportService.totalGrossToday();
    netToday = await ReportService.totalNetToday();
    await _loadChartData();
    setState(() {});
  }

  Future<void> _loadChartData() async {
    dailyRevenue = {};
    for (int i = 0; i < endDate.difference(startDate).inDays + 1; i++) {
      final date = startDate.add(Duration(days: i));
      // Simulasi data - dalam production bisa ambil dari database
      dailyRevenue[date] = (50000 + (i * 10000) % 100000).toInt();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      startDate = picked.start;
      endDate = picked.end;
      grossPeriod = await ReportService.totalGrossDateRange(startDate, endDate);
      netPeriod = await ReportService.totalNetDateRange(startDate, endDate);
      await _loadChartData();
      setState(() {
        isDateRangeSelected = true;
      });
    }
  }

  void _nav(int i) {
    switch (i) {
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const InventoryPage()));
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
      selectedIndex: 0,
      title: 'Dashboard',
      onNavigate: _nav,
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE & RESET BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDateRangeSelected ? '📊 Ringkasan Periode' : '📊 Ringkasan Hari Ini',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (isDateRangeSelected)
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      onPressed: () {
                        setState(() {
                          isDateRangeSelected = false;
                          grossPeriod = 0;
                          netPeriod = 0;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  _metric(
                    isDateRangeSelected ? 'Omzet Periode' : 'Omzet Hari Ini',
                    isDateRangeSelected ? grossPeriod : grossToday,
                    Icons.payments,
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 20),
                  _metric(
                    isDateRangeSelected ? 'Laba Periode' : 'Laba Bersih',
                    isDateRangeSelected ? netPeriod : netToday,
                    Icons.trending_up,
                    const Color(0xFF16A34A),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// CHART SECTION
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📈 Grafik Omzet Periode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Pilih Tanggal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _selectDateRange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 50000,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: const Color(0xFFE5E7EB),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  final dateList = dailyRevenue.keys.toList();
                                  if (value.toInt() >= 0 && value.toInt() < dateList.length) {
                                    final date = dateList[value.toInt()];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${date.day}/${date.month}',
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      'Rp ${(value / 1000).toStringAsFixed(0)}k',
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          minX: 0,
                          maxX: (dailyRevenue.length - 1).toDouble(),
                          minY: 0,
                          maxY: (dailyRevenue.values.isNotEmpty
                                  ? dailyRevenue.values.reduce((a, b) => a > b ? a : b) * 1.2
                                  : 100000)
                              .toDouble(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: dailyRevenue.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble()))
                                  .toList(),
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                              ),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: const Color(0xFF3B82F6),
                                    strokeColor: Colors.white,
                                    strokeWidth: 2,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF3B82F6).withOpacity(0.3),
                                    const Color(0xFF3B82F6).withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6).withOpacity(0.9),
                      const Color(0xFF2563EB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flash_on,
                          color: Color(0xFFFCD34D), size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mulai Transaksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Akses cepat untuk aktivitas utama toko',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.point_of_sale),
                      label: const Text('Kasir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _nav(2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp $value',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}