import 'package:flutter/foundation.dart';

class StockNotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;

  StockNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<StockNotificationItem> _items = [];

  List<StockNotificationItem> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((item) => !item.isRead).length;

  void syncStockRisks(List<Map<String, dynamic>> stock) {
    for (final item in stock) {
      final product = (item['product_name'] ?? 'Bahan').toString();
      final stockValue = _toDouble(item['stock']);
      final unit = (item['unit'] ?? '').toString();
      final minimum = _minimumStock(item);
      final status = stockValue <= 0
          ? 'habis'
          : stockValue <= minimum
          ? 'minimum'
          : 'aman';
      if (status == 'aman') continue;

      final id = '${item['id_inventory'] ?? product}:$status';
      if (_items.any((alert) => alert.id == id)) continue;

      _items.insert(
        0,
        StockNotificationItem(
          id: id,
          title: status == 'habis' ? 'Stok habis' : 'Stok hampir habis',
          message: status == 'habis'
              ? '$product sudah habis.'
              : '$product tersisa $stockValue $unit, minimum $minimum $unit.',
          createdAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void markAllRead() {
    for (final item in _items) {
      item.isRead = true;
    }
    notifyListeners();
  }

  void markRead(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _items[index].isRead = true;
    notifyListeners();
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
