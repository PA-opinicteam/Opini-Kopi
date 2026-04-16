import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opini_kopi/services/receipt_print_service.dart';
import 'package:opini_kopi/utils/snackbar_utils.dart';

class ReceiptPage extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final int subtotal;
  final int tax;
  final int total;
  final int cashReceived;
  final int change;
  final String paymentMethod;
  final String Function(int) formatRupiah;
  final Map<String, dynamic> order;
  final Map<String, dynamic> payment;

  const ReceiptPage({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.cashReceived,
    required this.change,
    required this.paymentMethod,
    required this.formatRupiah,
    required this.order,
    required this.payment,
  });

  int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  String generateReceiptText() {
    final buffer = StringBuffer();

    buffer.writeln('====== OPINI KOPI ======');
    buffer.writeln('Because every cup has an opinion');
    buffer.writeln('');
    buffer.writeln('ID Pesanan: ${payment['invoice_code']}');
    buffer.writeln('Pelanggan: ${order['customer_name']}');
    buffer.writeln(
      'Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('------------------------------');

    for (var item in cart) {
      final title = item['title'];
      final qty = toInt(item['qty']);
      final price = toInt(item['price']);

      buffer.writeln('$title');
      buffer.writeln('  $qty x ${formatRupiah(price)}');
    }

    buffer.writeln('------------------------------');
    buffer.writeln('Subtotal: ${formatRupiah(subtotal)}');
    buffer.writeln('Pajak: ${formatRupiah(tax)}');
    buffer.writeln('TOTAL: ${formatRupiah(total)}');
    buffer.writeln('');
    buffer.writeln('Metode Pembayaran: ${paymentMethod == 'cash' ? 'TUNAI' : 'QRIS'}');
    buffer.writeln('Uang Diberikan: ${formatRupiah(cashReceived)}');
    buffer.writeln('Kembalian: ${formatRupiah(change)}');
    buffer.writeln('==============================');

    return buffer.toString();
  }

  Future<void> printReceipt(BuildContext context) async {
    try {
      await ReceiptPrintService.printPdfReceipt(
        cart: cart,
        subtotal: subtotal,
        tax: tax,
        total: total,
        cashReceived: cashReceived,
        change: change,
        paymentMethod: paymentMethod,
        order: order,
        payment: payment,
      );
    } catch (e) {
      if (!context.mounted) return;
      SnackbarUtils.error(context, 'Gagal cetak struk: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EF),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'OPINI KOPI',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'BECAUSE EVERY CUP HAS AN OPINION',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F2E7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PEMBAYARAN BERHASIL',
                        style: TextStyle(
                          color: Color(0xFF2E7D6B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _row('Tanggal', formattedDate),
                  _row(
                    'Pelanggan',
                    (order['customer_name'] ?? '').toString().isEmpty
                        ? 'Guest'
                        : order['customer_name'],
                  ),
                  _row('ID Pesanan', '#${payment['invoice_code']}'),

                  const Divider(),

                  ...cart.map((item) {
                    final title = item['title'];
                    final qty = toInt(item['qty']);
                    final price = toInt(item['price']);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(title),
                              Text(formatRupiah(price * qty)),
                            ],
                          ),
                          Text(
                            'Jumlah $qty x ${formatRupiah(price)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(),

                  _row('Subtotal', formatRupiah(subtotal)),
                  _row('Pajak (10%)', formatRupiah(tax)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatRupiah(total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1ECE9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _row(
                          'Metode Pembayaran',
                          paymentMethod == 'cash' ? 'TUNAI' : 'QRIS',
                        ),
                        _row('Uang Diberikan', formatRupiah(cashReceived)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kembalian'),
                            Text(
                              formatRupiah(change),
                              style: const TextStyle(
                                color: Color(0xFF2E7D6B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Center(child: Icon(Icons.local_cafe, size: 36)),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => printReceipt(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A2419),
                        side: const BorderSide(color: Color(0xFF4A2419)),
                      ),
                      child: const Text('Cetak Struk'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2419),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Selesai'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }
}
