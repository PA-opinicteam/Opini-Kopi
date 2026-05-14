import 'package:flutter/foundation.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  int get subtotal {
    var total = 0;
    for (final item in _items) {
      final unitPrice = CurrencyFormatter.toInt(
        item['unitPrice'] ?? item['price'],
      );
      final qty = CurrencyFormatter.toInt(item['qty']);
      total += unitPrice * qty;
    }
    return total;
  }

  int get tax => (subtotal * 0.1).round();
  int get total => subtotal + tax;

  String itemKey(Map<String, dynamic> item) {
    final menuId = (item['menuId'] ?? '').toString();
    final variantId = (item['variantId'] ?? '').toString();
    final addonIds = item['addonIds'] is List
        ? List<String>.from((item['addonIds'] as List).map((e) => e.toString()))
        : <String>[];
    addonIds.sort();
    final note = (item['note'] ?? item['notes'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    return '$menuId|$variantId|${addonIds.join(',')}|$note';
  }

  void addOrMerge(Map<String, dynamic> item) {
    final newItem = Map<String, dynamic>.from(item);
    final key = itemKey(newItem);
    newItem['itemKey'] = key;

    final existingIndex = _items.indexWhere((e) => itemKey(e) == key);
    if (existingIndex >= 0) {
      _items[existingIndex]['qty'] =
          CurrencyFormatter.toInt(_items[existingIndex]['qty']) +
          CurrencyFormatter.toInt(newItem['qty']);
      _items[existingIndex].addAll(newItem);
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void replaceAt(int index, Map<String, dynamic> item) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = Map<String, dynamic>.from(item);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void decreaseQty(int index) {
    if (index < 0 || index >= _items.length) return;
    final qty = CurrencyFormatter.toInt(_items[index]['qty']);
    if (qty > 1) {
      _items[index]['qty'] = qty - 1;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void increaseQty(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index]['qty'] = CurrencyFormatter.toInt(_items[index]['qty']) + 1;
    notifyListeners();
  }
}
