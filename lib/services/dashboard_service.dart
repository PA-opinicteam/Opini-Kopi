import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final supabase = Supabase.instance.client;

  DateTime parseDate(String date) => DateTime.parse(date);

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<double> getTodayRevenue() async {
    final res = await supabase.from('orders').select();

    if (res.isEmpty) return 0;

    double total = 0;

    for (var item in res) {
      if (item['created_at'] == null) continue;

      final date = parseDate(item['created_at']);

      if (isToday(date)) {
        total += (item['total_price'] as num?)?.toDouble() ?? 0;
      }
    }

    return total;
  }

  Future<int> getTodayOrders() async {
    final res = await supabase.from('orders').select();

    if (res.isEmpty) return 0;

    int count = 0;

    for (var item in res) {
      if (item['created_at'] == null) continue;

      final date = parseDate(item['created_at']);

      if (isToday(date)) count++;
    }

    return count;
  }

  Future<String> getBestProduct() async {
    final res = await supabase
        .from('order_details')
        .select('id_menu, unit_quantity');

    if (res.isEmpty) return "-";

    Map<String, int> map = {};

    for (var item in res) {
      if (item['id_menu'] == null || item['unit_quantity'] == null) continue;

      String id = item['id_menu'].toString();
      int qty = (item['unit_quantity'] as num).toInt();

      map[id] = (map[id] ?? 0) + qty;
    }

    if (map.isEmpty) return "-";

    String bestId = map.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final menu = await supabase
        .from('menu')
        .select('menu_name')
        .eq('id_menu', bestId)
        .maybeSingle();

    return menu?['menu_name'] ?? "-";
  }

  Future<String> getPeakHour() async {
    final res = await supabase.from('orders').select('created_at');

    if (res.isEmpty) return "-";

    Map<int, int> hourCount = {};

    for (var item in res) {
      if (item['created_at'] == null) continue;

      final hour = parseDate(item['created_at']).hour;

      hourCount[hour] = (hourCount[hour] ?? 0) + 1;
    }

    if (hourCount.isEmpty) return "-";

    int peakHour = hourCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    String format(int h) => h.toString().padLeft(2, '0') + ':00';

    return '${format(peakHour)} - ${format((peakHour + 1) % 24)}';
  }

  Future<List<int>> getHourlyDistribution() async {
    final res = await supabase.from('orders').select('created_at');

    List<int> buckets = List.filled(7, 0);

    if (res.isEmpty) return buckets;

    for (var item in res) {
      if (item['created_at'] == null) continue;

      final hour = parseDate(item['created_at']).hour;

      if (hour >= 6 && hour < 9)
        buckets[0]++;
      else if (hour >= 9 && hour < 12)
        buckets[1]++;
      else if (hour >= 12 && hour < 15)
        buckets[2]++;
      else if (hour >= 15 && hour < 18)
        buckets[3]++;
      else if (hour >= 18 && hour < 21)
        buckets[4]++;
      else if (hour >= 21 && hour < 24)
        buckets[5]++;
      else
        buckets[6]++;
    }

    return buckets;
  }

  Future<List<double>> getWeeklySales() async {
    final res = await supabase.from('orders').select();

    List<double> weekly = List.filled(7, 0);

    if (res.isEmpty) return weekly;

    for (var item in res) {
      if (item['created_at'] == null) continue;

      final date = parseDate(item['created_at']);

      int dayIndex = date.weekday - 1;

      if (dayIndex >= 0 && dayIndex < 7) {
        weekly[dayIndex] += (item['total_price'] as num?)?.toDouble() ?? 0;
      }
    }

    return weekly;
  }
}
