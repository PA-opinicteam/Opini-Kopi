import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static final NumberFormat _idr = NumberFormat.decimalPattern('id_ID');

  static String idr(num value) => 'Rp ${_idr.format(value)}';

  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }
}
