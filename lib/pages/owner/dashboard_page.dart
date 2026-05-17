import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:opini_kopi/constants/app_sizes.dart';
import 'package:opini_kopi/constants/app_colors.dart';
import 'package:opini_kopi/services/dashboard_service.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';
import 'package:opini_kopi/utils/responsive_helper.dart';
import 'package:opini_kopi/widgets/owner/peak_hour_card.dart';
import 'package:opini_kopi/widgets/owner/sidebar_widget.dart';
import 'package:opini_kopi/pages/auth/login_page.dart';
import 'package:opini_kopi/pages/owner/menu_page.dart';
import 'package:opini_kopi/pages/owner/stock_page.dart';
import 'package:opini_kopi/pages/owner/users_page.dart';
import 'package:opini_kopi/pages/owner/report_page.dart';
import 'package:opini_kopi/providers/auth_provider.dart';
import 'package:opini_kopi/providers/notification_provider.dart';
import 'package:opini_kopi/pages/owner/notification_page.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  String get _mobileTitle {
    switch (selectedIndex) {
      default:
        return 'Opini Kopi Manajemen';
    }
  }

  Widget _buildSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const _DashboardContent();
      case 1:
        return const MenuPage();
      case 2:
        return const ReportPage();
      case 3:
        return const StockPage();
      case 4:
        return const UsersPage();
      default:
        return const _DashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile
          ? AppBar(
              centerTitle: true,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              leading: IconButton(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.logout),
              ),
              title: Text(
                _mobileTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_none),
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, provider, _) {
                        if (provider.unreadCount == 0) {
                          return const SizedBox.shrink();
                        }
                        return Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              provider.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 6),
              ],
            )
          : null,
      body: isMobile
          ? _buildSelectedPage()
          : Row(
              children: [
                OwnerSidebarWidget(
                  selectedIndex: selectedIndex,
                  onTap: (i) => setState(() => selectedIndex = i),
                  onLogout: () async {
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
                Expanded(child: _buildSelectedPage()),
              ],
            ),
      bottomNavigationBar: isMobile
          ? OwnerBottomNavigationBar(
              selectedIndex: selectedIndex,
              onTap: (i) => setState(() => selectedIndex = i),
            )
          : null,
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  Future<Map<String, dynamic>> _loadAllData() async {
    final service = DashboardService();
    final results = await Future.wait([
      service.getTodayRevenue(),
      service.getTodayOrders(),
      service.getBestProduct(),
      service.getWeeklySales(),
      service.getPeakHour(),
      service.getHourlyDistribution(),
    ]);

    return {
      'sales': results[0] as double,
      'orders': results[1] as int,
      'product': results[2] as String,
      'weeklySales': results[3] as List<double>,
      'peakHour': results[4] as String,
      'distData': results[5] as List<int>,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadAllData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4A2419)),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Data tidak tersedia'));
        }

        final data = snapshot.data!;

        final isMobile = ResponsiveHelper.isMobile(context);
        final pagePadding = isMobile ? 16.0 : ResponsiveHelper.pagePadding(context);

        return SingleChildScrollView(
          padding: EdgeInsets.all(pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              SizedBox(height: isMobile ? 24 : 32),
              _SummarySection(
                sales: data['sales'],
                orders: data['orders'],
                product: data['product'],
              ),
              SizedBox(height: isMobile ? 16 : 24),
              SizedBox(
                height: isMobile ? null : 360,
                child: isMobile
                    ? Column(
                        children: [
                          SizedBox(
                            height: 280,
                            child: _ChartCard(weeklySales: data['weeklySales']),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 300,
                            child: PeakHourCard(
                              peakHour: data['peakHour'],
                              data: data['distData'],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _ChartCard(weeklySales: data['weeklySales']),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: PeakHourCard(
                              peakHour: data['peakHour'],
                              data: data['distData'],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ringkasan Bisnis",
          style: TextStyle(
            fontSize: isMobile ? 20 : 28, 
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E342E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Laporan performa harian kedai kopi Anda.",
          style: TextStyle(color: Colors.black45, fontSize: isMobile ? 13 : 15),
        ),
      ],
    );
    
    return title;
  }
}

String rupiah(double v) {
  return CurrencyFormatter.idr(v);
}

class _SummarySection extends StatelessWidget {
  final double sales;
  final int orders;
  final String product;

  const _SummarySection({
    required this.sales,
    required this.orders,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        "PENJUALAN HARI INI",
        rupiah(sales),
        Icons.account_balance_wallet,
        const Color(0xFFFBE9E7),
      ),
      _StatCard(
        "TRANSAKSI HARI INI",
        "$orders",
        Icons.receipt_long,
        const Color(0xFFFBE9E7),
      ),
      _StatCard(
        "PRODUK TERLARIS",
        product,
        Icons.stars,
        const Color(0xFFFBE9E7),
      ),
    ];

    if (ResponsiveHelper.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards 
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: card,
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 20),
        Expanded(child: cards[1]),
        const SizedBox(width: 20),
        Expanded(child: cards[2]),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color bg;

  const _StatCard(this.title, this.value, this.icon, this.bg);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      constraints: isMobile
          ? const BoxConstraints(minHeight: 80)
          : const BoxConstraints(minHeight: 178),
      padding: isMobile
          ? const EdgeInsets.all(12)
          : const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4A2419),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4E342E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, color: const Color(0xFF4A2419), size: 20),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E342E),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<double> weeklySales;

  const _ChartCard({required this.weeklySales});

  @override
  Widget build(BuildContext context) {
    double maxVal = weeklySales.isEmpty ? 0 : weeklySales.reduce((a, b) => a > b ? a : b);
    double dynamicMaxY = maxVal == 0 ? 1000000 : maxVal * 1.2;

    return Container(
      padding: ResponsiveHelper.isMobile(context)
          ? const EdgeInsets.all(24)
          : const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Grafik Penjualan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: dynamicMaxY,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF6D4C41),
                    getTooltipItems: (spots) {
                      return spots.map((s) {
                        return LineTooltipItem(
                          rupiah(s.y),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'SEN',
                          'SEL',
                          'RAB',
                          'KAM',
                          'JUM',
                          'SAB',
                          'MIN',
                        ];
                        int index = value.toInt();
                        if (index >= 0 && index < 7) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      7,
                      (i) => FlSpot(i.toDouble(), weeklySales[i]),
                    ),
                    isCurved: true,
                    color: const Color(0xFF6D4C41),
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
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
  }
}