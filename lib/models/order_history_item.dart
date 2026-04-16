class OrderHistoryItem {
  final String id;
  final String customerName;
  final String invoiceCode;
  final String paymentMethod;
  final num totalPrice;
  final DateTime? createdAt;

  const OrderHistoryItem({
    required this.id,
    required this.customerName,
    required this.invoiceCode,
    required this.paymentMethod,
    required this.totalPrice,
    required this.createdAt,
  });

  factory OrderHistoryItem.fromMap(Map<String, dynamic> map) {
    final payment = _firstPayment(map);
    return OrderHistoryItem(
      id: (map['id_order'] ?? '').toString(),
      customerName: (map['customer_name'] ?? 'Guest').toString(),
      invoiceCode: (payment?['invoice_code'] ?? map['invoice_code'] ?? '-')
          .toString(),
      paymentMethod:
          (payment?['payment_method'] ?? map['payment_method'] ?? '-')
              .toString(),
      totalPrice: (map['total_price'] ?? 0) as num,
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()),
    );
  }

  static Map<String, dynamic>? _firstPayment(Map<String, dynamic> map) {
    final payments = map['payments'];
    if (payments is List && payments.isNotEmpty) {
      return Map<String, dynamic>.from(payments.first as Map);
    }
    if (payments is Map) return Map<String, dynamic>.from(payments);
    return null;
  }
}
