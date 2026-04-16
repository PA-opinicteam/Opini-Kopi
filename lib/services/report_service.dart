import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportService {
  final supabase = Supabase.instance.client;

  DateTime getStartDate(String period) {
    final now = DateTime.now().toUtc();
    switch (period) {
      case 'Harian':
        return DateTime.utc(now.year, now.month, now.day);
      case 'Mingguan':
        return now.subtract(const Duration(days: 7));
      case 'Bulanan':
        return DateTime.utc(now.year, now.month, 1);
      default:
        return now;
    }
  }

  Future<Map<String, dynamic>> getSalesSummary(DateTimeRange? range) async {
    var query = supabase.from('orders').select('total_price');
    if (range != null) {
      query = query
          .gte('created_at', range.start.toIso8601String())
          .lte('created_at', range.end.toIso8601String());
    }
    final orders = await query;
    double totalSales = 0;
    for (var o in orders) {
      totalSales += (o['total_price'] ?? 0);
    }
    int totalOrder = orders.length;
    double avgOrder = totalOrder == 0 ? 0 : totalSales / totalOrder;
    return {
      'total_sales': totalSales,
      'total_order': totalOrder,
      'avg_order': avgOrder,
    };
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(
    DateTimeRange? range,
  ) async {
    try {
      var query = supabase
          .from('orders')
          .select(
            'id_order, customer_name, subtotal_price, tax, total_price, status, created_at, payments(invoice_code, payment_method, amount_paid, change_amount)',
          );

      if (range != null) {
        query = query
            .gte('created_at', range.start.toIso8601String())
            .lte('created_at', range.end.toIso8601String());
      }

      final List<dynamic> res = await query.order(
        'created_at',
        ascending: false,
      );

      return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint("ORDER HISTORY ERROR: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTopProducts(
    DateTimeRange? range,
  ) async {
    try {
      var query = supabase
          .from('order_details')
          .select('unit_quantity, menu(menu_name), orders!inner(created_at)');

      if (range != null) {
        query = query
            .gte('orders.created_at', range.start.toIso8601String())
            .lte('orders.created_at', range.end.toIso8601String());
      }

      final List<dynamic> res = await query;

      if (res.isEmpty) return [];

      Map<String, int> result = {};

      for (var d in res) {
        final menuData = d['menu'] as Map<String, dynamic>?;
        final name = menuData?['menu_name'] ?? 'Unknown';
        final qty = (d['unit_quantity'] ?? 0) as int;

        result[name] = (result[name] ?? 0) + qty;
      }

      final sorted = result.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(5).map((e) {
        return {'name': e.key, 'sold': e.value};
      }).toList();
    } catch (e) {
      debugPrint("TOP PRODUCT ERROR: $e");
      return [];
    }
  }

  Future<List<FlSpot>> getChartDataGrouped(
    DateTimeRange? range,
    String filterType,
  ) async {
    var query = supabase.from('orders').select('total_price, created_at');
    if (range != null) {
      query = query
          .gte('created_at', range.start.toIso8601String())
          .lte('created_at', range.end.toIso8601String());
    }
    final res = await query.order('created_at');

    if (filterType == 'Bulanan') {
      Map<int, double> weekValues = {1: 0, 2: 0, 3: 0, 4: 0};
      for (var row in res) {
        DateTime date = DateTime.parse(row['created_at']).toLocal();
        int weekNum = ((date.day - 1) / 7).floor() + 1;
        if (weekNum > 4) weekNum = 4;
        weekValues[weekNum] =
            (weekValues[weekNum] ?? 0) + (row['total_price'] as num).toDouble();
      }
      return weekValues.entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
    } else {
      Map<int, double> dayValues = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
      for (var row in res) {
        DateTime date = DateTime.parse(row['created_at']).toLocal();
        int weekday = date.weekday - 1;
        dayValues[weekday] =
            (dayValues[weekday] ?? 0) + (row['total_price'] as num).toDouble();
      }
      return dayValues.entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
    }
  }
}
