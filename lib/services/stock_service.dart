import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockService {
  final _client = Supabase.instance.client;
  SupabaseQueryBuilder get _db => _client.from('inventory');

  Future<List<Map<String, dynamic>>> getStock() async {
    return await _db.select().order('created_at', ascending: false);
  }

  Future<void> addStock(Map<String, dynamic> data) async {
    await _writeWithOptionalColumnFallback(() async {
      await _db.insert(data);
    }, data);
  }

  Future<void> updateStock(String id, Map<String, dynamic> data) async {
    await _writeWithOptionalColumnFallback(() async {
      await _db.update(data).eq('id_inventory', id);
    }, data);
  }

  Future<void> deleteStock(String id) async {
    await _db.delete().eq('id_inventory', id);
  }

  Future<String?> uploadImage(Uint8List bytes, String fileName) async {
    try {
      final path = 'public/$fileName';
      await _client.storage.from('inventory_images').uploadBinary(path, bytes);
      return _client.storage.from('inventory_images').getPublicUrl(path);
    } catch (e) {
      debugPrint('Upload stock image error: $e');
      return null;
    }
  }

  Future<void> _writeWithOptionalColumnFallback(
    Future<void> Function() write,
    Map<String, dynamic> data,
  ) async {
    try {
      await write();
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();
      final optionalKeys = ['minimum_stock', 'image_url'];
      final hasOptionalColumnError = optionalKeys.any(message.contains);
      if (!hasOptionalColumnError) rethrow;

      data.removeWhere((key, _) => optionalKeys.contains(key));
      await write();
    }
  }
}
