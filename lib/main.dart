import 'package:flutter/material.dart';
import 'package:opini_kopi/services/stock_notification_service.dart';
import 'services/supabase_service.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  await initializeDateFormatting('id_ID', null);
  await StockNotificationService.init();
  runApp(const MainApp());
}
