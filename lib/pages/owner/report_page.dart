import 'package:flutter/material.dart';
import '../../services/report_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:opini_kopi/services/export_service.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';
import 'package:opini_kopi/utils/responsive_helper.dart';
import 'package:opini_kopi/utils/snackbar_utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ReportService service = ReportService();
  final dateFormat = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

  String selectedFilter = 'Mingguan';
  DateTimeRange? selectedRange;
  bool _isExporting = false;
  Map<String, dynamic>? _latestSummary;
  List<Map<String, dynamic>> _latestOrders = [];

  late Future<Map<String, dynamic>> summaryFuture;
  late Future<List<Map<String, dynamic>>> topProductsFuture;
  late Future<List<FlSpot>> chartFuture;
  late Future<List<Map<String, dynamic>>> orderHistoryFuture;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    final range = getActiveRange();
    summaryFuture = service.getSalesSummary(range);
    topProductsFuture = service.getTopProducts(range);
    chartFuture = service.getChartDataGrouped(range, selectedFilter);
    orderHistoryFuture = service.getOrderHistory(range);
  }

  Future<void> _exportPdf() async {
    await _runExport(() async {
      await ExportService.shareOrderReportPdf(
        orders: _latestOrders,
        summary: _latestSummary ?? await summaryFuture,
      );
      if (!mounted) return;
      SnackbarUtils.success(context, 'PDF berhasil dibuat');
    });
  }

  Future<void> _exportExcel() async {
    await _runExport(() async {
      final path = await ExportService.saveOrderReportExcel(
        orders: _latestOrders,
        summary: _latestSummary ?? await summaryFuture,
      );
      if (!mounted) return;
      SnackbarUtils.success(context, 'Excel tersimpan: $path');
    });
  }

  Future<void> _runExport(Future<void> Function() task) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      await task();
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.error(context, 'Export gagal: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  DateTimeRange? getActiveRange() {
    final now = DateTime.now();
    if (selectedFilter == 'Mingguan') {
      return DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      );
    } else if (selectedFilter == 'Bulanan') {
      return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    }
    return selectedRange;
  }

  Future<void> _openDatePicker() async {
    DateTimeRange? tempRange = selectedRange;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pilih Tanggal",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2419),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 350,
                  child: SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.range,

                    selectionColor: const Color(0xFF6D4C41),
                    startRangeSelectionColor: const Color(0xFF6D4C41),
                    endRangeSelectionColor: const Color(0xFF6D4C41),
                    rangeSelectionColor: const Color(0xFFD7CCC8),
                    todayHighlightColor: const Color(0xFF6D4C41),

                    monthCellStyle: DateRangePickerMonthCellStyle(
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      todayCellDecoration: BoxDecoration(
                        color: Color(0xFF6D4C41),
                        shape: BoxShape.circle,
                      ),
                    ),

                    headerStyle: const DateRangePickerHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4A2419),
                      ),
                    ),

                    onSelectionChanged: (args) {
                      if (args.value is PickerDateRange) {
                        final range = args.value;
                        tempRange = DateTimeRange(
                          start: range.startDate!,
                          end: range.endDate ?? range.startDate!,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A2419),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (tempRange != null) {
                            setState(() {
                              selectedFilter = "Custom";
                              selectedRange = tempRange;
                              loadData();
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2419),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.pagePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildFilterBar(),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 32),
            ResponsiveHelper.isMobile(context)
                ? Column(
                    children: [
                      _buildChart(),
                      const SizedBox(height: 16),
                      _buildTopProducts(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 12, child: _buildChart()),
                      const SizedBox(width: 24),
                      Expanded(flex: 8, child: _buildTopProducts()),
                    ],
                  ),
            const SizedBox(height: 24),
            _buildOrderHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Laporan Penjualan",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B3932),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Pantau laporan bisnis anda.",
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [_pill("Mingguan"), _pill("Bulanan")],
          ),
        ),
        GestureDetector(
          onTap: _openDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF6D4C41).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Color(0xFF6D4C41),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedRange == null
                      ? "Pilih Tanggal"
                      : "${selectedRange!.start.day}/${selectedRange!.start.month} - ...",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6D4C41),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: _isExporting ? null : _exportPdf,
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: const Text('PDF'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4A2419),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportExcel,
          icon: const Icon(Icons.table_chart_outlined, size: 18),
          label: const Text('Excel'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A5240),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );

    if (ResponsiveHelper.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [filters, const SizedBox(height: 12), actions],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [filters, actions],
    );
  }

  Widget _pill(String label) {
    final isActive = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          loadData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6D4C41) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return FutureBuilder(
      future: summaryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        final data = snapshot.data!;
        _latestSummary = data;
        if (ResponsiveHelper.isMobile(context)) {
          return Column(
            children: [
              _card(
                "TOTAL PENJUALAN",
                CurrencyFormatter.idr(data['total_sales']),
                true,
              ),
              const SizedBox(height: 12),
              _card("TOTAL PESANAN", "${data['total_order']}", false),
              const SizedBox(height: 12),
              _card(
                "RATA-RATA PESANAN",
                CurrencyFormatter.idr(data['avg_order']),
                false,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _card(
                "TOTAL PENJUALAN",
                CurrencyFormatter.idr(data['total_sales']),
                true,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _card("TOTAL PESANAN", "${data['total_order']}", false),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _card(
                "RATA-RATA PESANAN",
                CurrencyFormatter.idr(data['avg_order']),
                false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _card(String title, String value, bool isDark) {
    final icon = _summaryIcon(title);
    final iconColor = isDark ? Colors.white : const Color(0xFF6D4C41);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF6D4C41) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.14)
                  : const Color(0xFF6D4C41).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _summaryIcon(String title) {
    switch (title) {
      case "TOTAL PENJUALAN":
        return Icons.payments_outlined;
      case "TOTAL PESANAN":
        return Icons.receipt_long_outlined;
      case "RATA-RATA PESANAN":
        return Icons.analytics_outlined;
      default:
        return Icons.insights_outlined;
    }
  }

  Widget _buildChart() {
    return FutureBuilder<List<FlSpot>>(
      future: chartFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyCard("Belum ada data grafik");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return _emptyCard("Belum ada data grafik");

        double maxDataValue = snapshot.data!
            .map((spot) => spot.y)
            .reduce((a, b) => a > b ? a : b);
        double dynamicMaxY = maxDataValue == 0 ? 1000000 : maxDataValue * 1.2;

        return Container(
          padding: const EdgeInsets.all(32),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Grafik Penjualan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 260,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: dynamicMaxY,
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => const Color(0xFF6D4C41),
                        getTooltipItems: (spots) {
                          return spots
                              .map(
                                (s) => LineTooltipItem(
                                  CurrencyFormatter.idr(s.y),
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              .toList();
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (val, _) {
                            if (selectedFilter == 'Bulanan') {
                              if (val < 1 || val > 4) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Mgg ${val.toInt()}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            } else {
                              const days = [
                                'SENIN',
                                'SELASA',
                                'RABU',
                                'KAMIS',
                                'JUMAT',
                                'SABTU',
                                'MINGGU',
                              ];
                              int index = val.toInt();
                              if (index < 0 || index > 6)
                                return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  days[index],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: snapshot.data!,
                        isCurved: true,
                        color: const Color(0xFF6D4C41),
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF6D4C41).withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopProducts() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: topProductsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyCard("Belum ada data produk");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return _emptyCard("Belum ada data produk");

        final products = snapshot.data!;

        return Container(
          height: 370,
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Produk Terlaris",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ...products.asMap().entries.map((entry) {
                int index = entry.key + 1;
                Map<String, dynamic> p = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6D4C41).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "$index",
                            style: const TextStyle(
                              color: Color(0xFF6D4C41),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${p['sold']} terjual",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 14,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderHistory() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: orderHistoryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _emptyCard("Memuat riwayat order...");
        }

        final orders = snapshot.data!;
        _latestOrders = orders;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Riwayat Order",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                const SizedBox(
                  height: 120,
                  child: Center(child: Text("Belum ada riwayat order")),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _historyRow(order);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _historyRow(Map<String, dynamic> order) {
    final payment = _firstPayment(order);
    final invoice = (payment?['invoice_code'] ?? '-').toString();
    final method = (payment?['payment_method'] ?? '-').toString();
    final date = DateTime.tryParse((order['created_at'] ?? '').toString());

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                date == null ? '-' : dateFormat.format(date.toLocal()),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text((order['customer_name'] ?? 'Guest').toString()),
        ),
        Expanded(
          child: Text(
            method == 'cash' ? 'TUNAI' : method.toUpperCase(),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            CurrencyFormatter.idr(order['total_price'] ?? 0),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic>? _firstPayment(Map<String, dynamic> order) {
    final payments = order['payments'];
    if (payments is List && payments.isNotEmpty) {
      return Map<String, dynamic>.from(payments.first as Map);
    }
    if (payments is Map) return Map<String, dynamic>.from(payments);
    return null;
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
    ],
  );

  Widget _emptyCard(String text) => Container(
    height: 200,
    decoration: _cardDecoration(),
    child: Center(child: Text(text)),
  );
}
