import 'package:supabase_flutter/supabase_flutter.dart';

class StockService {
  final _db = Supabase.instance.client.from('inventory');

  Future<List<Map<String, dynamic>>> getStock() async {
    return await _db.select().order('created_at', ascending: false);
  }

  Future<void> addStock(Map<String, dynamic> data) async {
    await _db.insert(data);
  }

  Future<void> updateStock(String id, Map<String, dynamic> data) async {
    await _db.update(data).eq('id_inventory', id);
  }

  Future<void> deleteStock(String id) async {
    await _db.delete().eq('id_inventory', id);
  }
}
