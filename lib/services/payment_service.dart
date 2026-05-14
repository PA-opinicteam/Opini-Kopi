import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final supabase = Supabase.instance.client;
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  String? _uuidOrNull(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return _uuidPattern.hasMatch(text) ? text : null;
  }

  Future<Map<String, dynamic>> processPayment({
    required List<Map<String, dynamic>> cart,
    required int subtotal,
    required int tax,
    required int total,
    required int cashReceived,
    required int change,
    required String paymentMethod,
    required String customerName,
  }) async {
    final now = DateTime.now();
    final invoiceCode =
        'INV-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

    final orderRes = await supabase
        .from('orders')
        .insert({
          'subtotal_price': subtotal,
          'total_price': total,
          'tax': tax,
          'customer_name': customerName,
          'status': 'paid',
        })
        .select()
        .single();

    final orderId = orderRes['id_order'];

    for (final item in cart) {
      final qty = int.tryParse(item['qty'].toString()) ?? 1;
      final price =
          int.tryParse(
            item['price'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;
      final note = (item['note'] ?? item['notes'] ?? '').toString().trim();
      final menuId = _uuidOrNull(item['menuId'] ?? item['id_menu']);
      if (menuId == null) {
        throw Exception('Menu tidak valid untuk item ${item['title'] ?? ''}');
      }

      await supabase.from('order_details').insert({
        'id_order': orderId,
        'id_menu': menuId,
        'unit_quantity': qty,
        'unit_price': price,
        'subtotal': qty * price,
        'notes': note.isEmpty ? null : note,
      });
    }

    final paymentRes = await supabase
        .from('payments')
        .insert({
          'id_order': orderId,
          'payment_method': paymentMethod,
          'amount_paid': cashReceived,
          'change_amount': change,
          'invoice_code': invoiceCode,
        })
        .select()
        .single();

    return {'order': orderRes, 'payment': paymentRes};
  }
}
