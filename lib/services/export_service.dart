import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:opini_kopi/utils/currency_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  const ExportService._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');

  static Future<void> shareOrderReportPdf({
    required List<Map<String, dynamic>> orders,
    required Map<String, dynamic> summary,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(
            'Laporan Penjualan Opini Kopi',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _summaryBox(
                'Total Penjualan',
                CurrencyFormatter.idr(summary['total_sales'] ?? 0),
              ),
              _summaryBox('Total Pesanan',
               '${summary['total_order'] ?? 0}'),
              _summaryBox(
                'Rata-rata Pesanan',
                CurrencyFormatter.idr(summary['avg_order'] ?? 0),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Riwayat Order',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Tanggal',
              'ID Pesanan',
              'Nama Pelanggan',
              'Metode',
              'Total',
            ],
            data: orders.map((order) {
              return [
                _dateText(order['created_at']),
                _invoiceText(order),
                (order['customer_name'] ?? 'Guest').toString(),
                _paymentMethodText(order),
                CurrencyFormatter.idr(order['total_price'] ?? 0),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFEADDD7),
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'laporan-opini-kopi.pdf',
    );
  }

  static Future<String> saveOrderReportExcel({
    required List<Map<String, dynamic>> orders,
    required Map<String, dynamic> summary,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Laporan'];

    sheet.appendRow([TextCellValue('Laporan Penjualan Opini Kopi')]);
    sheet.appendRow([]);
    sheet.appendRow([
      TextCellValue('Total Penjualan'),
      TextCellValue(CurrencyFormatter.idr(summary['total_sales'] ?? 0)),
    ]);
    sheet.appendRow([
      TextCellValue('Total Pesanan'),
      IntCellValue((summary['total_order'] ?? 0) as int),
    ]);
    sheet.appendRow([
      TextCellValue('Rata-rata Pesanan'),
      TextCellValue(CurrencyFormatter.idr(summary['avg_order'] ?? 0)),
    ]);
    sheet.appendRow([]);
    sheet.appendRow([
      TextCellValue('Tanggal'),
      TextCellValue('ID Pesanan'),
      TextCellValue('Nama Pelanggan'),
      TextCellValue('Metode'),
      TextCellValue('Total'),
    ]);

    for (final order in orders) {
      sheet.appendRow([
        TextCellValue(_dateText(order['created_at'])),
        TextCellValue(_invoiceText(order)),
        TextCellValue((order['customer_name'] ?? 'Guest').toString()),
        TextCellValue(_paymentMethodText(order)),
        TextCellValue(CurrencyFormatter.idr(order['total_price'] ?? 0)),
      ]);
    }

    return _saveExcel(excel, 'laporan-opini-kopi.xlsx');
  }

  static Future<String> saveStockExcel(List<Map<String, dynamic>> stock) async {
    final excel = Excel.createExcel();
    final sheet = excel['Stok'];

    sheet.appendRow([
      TextCellValue('Nama Bahan'),
      TextCellValue('Kategori'),
      TextCellValue('Stok'),
      TextCellValue('Unit'),
      TextCellValue('Status'),
    ]);

    for (final item in stock) {
      final stockValue = (item['stock'] ?? 0) as num;
      final unitValue = (item['unit'] ?? '').toString();
      sheet.appendRow([
        TextCellValue((item['product_name'] ?? '').toString()),
        TextCellValue((item['category'] ?? 'Bahan Baku').toString()),
        DoubleCellValue(stockValue.toDouble()),
        TextCellValue(unitValue),
        TextCellValue(_stockStatus(stockValue.toDouble(), unitValue)),
      ]);
    }

    return _saveExcel(excel, 'stok-opini-kopi.xlsx');
  }

  static pw.Widget _summaryBox(String title, String value) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static Future<String> _saveExcel(Excel excel, String filename) async {
    if (kIsWeb) {
      final bytes = excel.save(fileName: filename);
      if (bytes == null) throw Exception('Gagal membuat file Excel');
      return filename;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}${Platform.pathSeparator}$filename';
    final bytes = excel.save();
    if (bytes == null) throw Exception('Gagal membuat file Excel');

    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  static String _dateText(dynamic value) {
    if (value == null) return '-';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();
    return _dateFormat.format(date.toLocal());
  }

  static String _invoiceText(Map<String, dynamic> order) {
    final payment = _firstPayment(order);
    return (payment?['invoice_code'] ?? order['invoice_code'] ?? '-')
        .toString();
  }

  static String _paymentMethodText(Map<String, dynamic> order) {
    final payment = _firstPayment(order);
    final method =
        (payment?['payment_method'] ?? order['payment_method'] ?? '-')
            .toString();
    return method == 'cash' ? 'TUNAI' : method.toUpperCase();
  }

  static Map<String, dynamic>? _firstPayment(Map<String, dynamic> order) {
    final payments = order['payments'];
    if (payments is List && payments.isNotEmpty) {
      return Map<String, dynamic>.from(payments.first as Map);
    }
    if (payments is Map) return Map<String, dynamic>.from(payments);
    return null;
  }

  static String _normalizeUnit(String value) {
    return value.toLowerCase().trim();
  }

  static double _lowStockLimit(String unit) {
    switch (_normalizeUnit(unit)) {
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

  static String _stockStatus(double stock, String unit) {
    if (stock <= 0) return 'Habis';
    if (stock <= _lowStockLimit(unit)) return 'Menipis';
    return 'Aman';
  }
}
