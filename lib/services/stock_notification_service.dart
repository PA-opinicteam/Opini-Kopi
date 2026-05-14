import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

    for (final item in items) {
      final productName = (item['product_name'] ?? 'Bahan').toString();
      final stock = _toDouble(item['stock']);
      final unit = (item['unit'] ?? '').toString();
      final minimum = _minimumStock(item);
      final status = stock <= 0
          ? 'habis'
          : stock <= minimum
          ? 'menipis'
          : 'aman';

      if (status == 'aman') continue;

      final id = (item['id_inventory'] ?? productName).toString();
      final key = '$id:$status';
      final lastAlert = _lastAlertAt[key];
      final now = DateTime.now();
      if (lastAlert != null && now.difference(lastAlert).inHours < 6) {
        continue;
      }

      _lastAlertAt[key] = now;
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

  static Future<void> _showStockNotification(
    int id,
    String productName,
    String status,
    double stock,
    String unit,
    double minimum,
  ) async {
    const android = AndroidNotificationDetails(
      'stock_alerts',
      'Peringatan Stok',
      channelDescription: 'Notifikasi stok habis dan stok menipis',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

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

  static double _minimumStock(Map<String, dynamic> item) {
    final custom = _toDouble(item['minimum_stock']);
    if (custom > 0) return custom;

    switch ((item['unit'] ?? '').toString().toLowerCase().trim()) {
      case 'g':
      case 'gr':
      case 'gram':
        return 500;
      case 'kg':
      case 'kilogram':
        return 1;
      case 'ml':
        return 1000;
      case 'l':
      case 'lt':
      case 'liter':
        return 2;
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
