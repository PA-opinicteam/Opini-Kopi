import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class StockNotificationService {
  StockNotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final Map<String, DateTime> _lastAlertAt = {};
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized || kIsWeb) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(settings: settings);
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> notifyStockRisks(List<Map<String, dynamic>> items) async {
    if (kIsWeb) return;
    await init();

    await notifyMonthlyReport();

    int alertCount = 0;

    for (final item in items) {
      final productName = (item['product_name'] ?? 'Bahan').toString();
      final stock = _toDouble(item['stock']);
      final unit = (item['unit'] ?? '').toString();
      final minimum = _minimumStock(item);
      final status = stock <= 0 ? 'habis' : stock <= minimum ? 'menipis' : 'aman';

      if (status == 'aman') continue;

      final id = (item['id_inventory'] ?? productName).toString();
      final key = '$id:$status';

      alertCount++;

      final lastAlert = _lastAlertAt[key];
      final now = DateTime.now();
      if (lastAlert != null && now.difference(lastAlert).inHours < 6) {
        continue;
      }

      _lastAlertAt[key] = now;

      if (alertCount <= 3) {
        await _showStockNotification(
          id.hashCode & 0x7fffffff,
          productName,
          status,
          stock,
          unit,
          minimum,
        );
      }
    }

    if (alertCount > 3) {
      await _showSummaryNotification(alertCount);
    }
  }

  static Future<void> notifyMonthlyReport() async {
    final now = DateTime.now();
    if (now.day != 30) return;

    final key = 'monthly_report_${now.month}_${now.year}';
    if (_lastAlertAt.containsKey(key)) return;

    _lastAlertAt[key] = now;

    final android = AndroidNotificationDetails(
      'report_alerts',
      'Laporan Bulanan',
      channelDescription: 'Notifikasi ketersediaan laporan bulanan',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );
    final details = NotificationDetails(android: android);

    final monthName = DateFormat('MMMM', 'id_ID').format(now);

    await _notifications.show(
      id: 100,
      title: 'Laporan Bulanan Tersedia',
      body: 'Laporan penjualan bulan $monthName sudah siap untuk dievaluasi.',
      notificationDetails: details,
    );
  }

  static Future<void> _showStockNotification(
    int id,
    String productName,
    String status,
    double stock,
    String unit,
    double minimum,
  ) async {
    final android = AndroidNotificationDetails(
      'stock_alerts',
      'Peringatan Stok',
      channelDescription: 'Notifikasi stok habis dan stok menipis',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true, 
      vibrationPattern: Int64List.fromList([0, 200, 100, 200]),
    );
    const ios = DarwinNotificationDetails();
    final details = NotificationDetails(android: android, iOS: ios);

    final title = status == 'habis' ? 'Stok habis' : 'Stok hampir habis';
    final body = status == 'habis'
        ? '$productName sudah habis.'
        : '$productName tersisa $stock $unit, minimum $minimum $unit.';

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static Future<void> _showSummaryNotification(int count) async {
    final android = AndroidNotificationDetails(
      'stock_summary',
      'Ringkasan Stok',
      channelDescription: 'Notifikasi ringkasan jika banyak stok bermasalah',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 400, 100, 400]),
    );
    final details = NotificationDetails(android: android);

    await _notifications.show(
      id: 998,
      title: 'Peringatan Stok',
      body: 'Ada $count bahan yang perlu perhatian (habis/menipis). Cek log notifikasi.',
      notificationDetails: details,
    );
  }

  static double _minimumStock(Map<String, dynamic> item) {
    switch ((item['unit'] ?? '').toString().toLowerCase().trim()) {
      case 'g':
      case 'gr':
      case 'gram':
        return 1000;
      case 'kg':
      case 'kilogram':
        return 1;
      case 'ml':
        return 1000;
      case 'l':
      case 'lt':
      case 'liter':
        return 1;
      case 'pcs':
      case 'pc':
      case 'piece':
      case 'pieces':
        return 10;
      default:
        return 5;
    }
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
