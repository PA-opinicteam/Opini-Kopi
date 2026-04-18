import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptPrintService {
  const ReceiptPrintService._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');

  static Future<void> printPdfReceipt({
    required List<Map<String, dynamic>> cart,
    required int subtotal,
    required int tax,
    required int total,
    required int cashReceived,
    required int change,
    required String paymentMethod,
    required Map<String, dynamic> order,
    required Map<String, dynamic> payment,
  }) async {
    final bytes = await buildReceiptPdf(
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

    await Printing.layoutPdf(
      name: 'struk-opini-kopi.pdf',
      format: PdfPageFormat(80 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
      onLayout: (_) async => Uint8List.fromList(bytes),
    );
  }

  static Future<List<int>> buildReceiptPdf({
    required List<Map<String, dynamic>> cart,
    required int subtotal,
    required int tax,
    required int total,
    required int cashReceived,
    required int change,
    required String paymentMethod,
    required Map<String, dynamic> order,
    required Map<String, dynamic> payment,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          297 * PdfPageFormat.mm,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'OPINI KOPI',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Because every cup has an opinion',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          _line(),
          _row('ID Pesanan', (payment['invoice_code'] ?? '-').toString()),
          _row('Pelanggan', (order['customer_name'] ?? 'Guest').toString()),
          _row('Tanggal', _dateFormat.format(DateTime.now())),
          _line(),
          ...cart.map((item) {
            final title = (item['title'] ?? '').toString();
            final qty = CurrencyFormatter.toInt(item['qty']);
            final price = CurrencyFormatter.toInt(item['price']);
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  _row(
                    '$qty x ${CurrencyFormatter.idr(price)}',
                    CurrencyFormatter.idr(price * qty),
                  ),
                ],
              ),
            );
          }),
          _line(),
          _row('Subtotal', CurrencyFormatter.idr(subtotal)),
          _row('Pajak (10%)', CurrencyFormatter.idr(tax)),
          _row('TOTAL', CurrencyFormatter.idr(total), bold: true),
          pw.SizedBox(height: 6),
          _row('Metode Pembayaran', paymentMethod == 'cash' ? 'TUNAI' : 'QRIS'),
          _row('Uang Diberikan', CurrencyFormatter.idr(cashReceived)),
          _row('Kembalian', CurrencyFormatter.idr(change)),
          _line(),
          pw.Center(
            child: pw.Text(
              'Terima kasih',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static Future<List<int>> buildThermalBytes({
    required List<Map<String, dynamic>> cart,
    required int subtotal,
    required int tax,
    required int total,
    required int cashReceived,
    required int change,
    required String paymentMethod,
    required Map<String, dynamic> order,
    required Map<String, dynamic> payment,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    bytes.addAll(
      generator.text(
        'OPINI KOPI',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(
      generator.text(
        'Because every cup has an opinion',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr());
    bytes.addAll(generator.text('ID Pesanan: ${payment['invoice_code'] ?? '-'}'));
    bytes.addAll(
      generator.text('Pelanggan: ${order['customer_name'] ?? 'Guest'}'),
    );
    bytes.addAll(generator.text('Tanggal: ${_dateFormat.format(DateTime.now())}'));
    bytes.addAll(generator.hr());

    for (final item in cart) {
      final title = (item['title'] ?? '').toString();
      final qty = CurrencyFormatter.toInt(item['qty']);
      final price = CurrencyFormatter.toInt(item['price']);
      bytes.addAll(generator.text(title));
      bytes.addAll(
        generator.row([
          PosColumn(text: '$qty x ${CurrencyFormatter.idr(price)}', width: 7),
          PosColumn(
            text: CurrencyFormatter.idr(price * qty),
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }

    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.text('Subtotal: ${CurrencyFormatter.idr(subtotal)}'),
    );
    bytes.addAll(generator.text('Pajak (10%): ${CurrencyFormatter.idr(tax)}'));
    bytes.addAll(
      generator.text(
        'TOTAL: ${CurrencyFormatter.idr(total)}',
        styles: const PosStyles(bold: true),
      ),
    );
    bytes.addAll(
      generator.text('Metode Pembayaran: ${paymentMethod == 'cash' ? 'TUNAI' : 'QRIS'}'),
    );
    bytes.addAll(
      generator.text('Uang Diberikan: ${CurrencyFormatter.idr(cashReceived)}'),
    );
    bytes.addAll(generator.text('Kembalian: ${CurrencyFormatter.idr(change)}'));
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    return bytes;
  }

  static pw.Widget _line() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Divider(thickness: 0.5),
  );

  static pw.Widget _row(String title, String value, {bool bold = false}) {
    final style = pw.TextStyle(
      fontSize: 9,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(child: pw.Text(title, style: style)),
        pw.Text(value, style: style),
      ],
    );
  }
}
