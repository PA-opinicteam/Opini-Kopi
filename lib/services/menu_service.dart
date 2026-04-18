import 'supabase_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class MenuService {
  final supabase = SupabaseService.client;

  String _normalizeCategory(String value) {
    return value.toLowerCase().replaceAll('-', ' ').trim();
  }

  Future<List<Map<String, dynamic>>> getMenusByCategory(String category) async {
    final c = _normalizeCategory(category);

    final res = c.contains('non')
        ? await supabase
              .from('menu')
              .select()
              .eq('is_available', true)
              .ilike('category', '%non%')
              .order('menu_name', ascending: true)
        : c.contains('coffee')
        ? await supabase
              .from('menu')
              .select()
              .eq('is_available', true)
              .not('category', 'ilike', '%non%')
              .ilike('category', '%coffee%')
              .order('menu_name', ascending: true)
        : await supabase
              .from('menu')
              .select()
              .eq('is_available', true)
              .ilike('category', '%snack%')
              .order('menu_name', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getVariants(String menuId) async {
    final res = await supabase
        .from('menu_variants')
        .select()
        .eq('id_menu', menuId)
        .order('price', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getAddons() async {
    final res = await supabase
        .from('menu_addons')
        .select()
        .eq('is_active', true)
        .order('price', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<String?> uploadImage(dynamic file, String fileName) async {
    try {
      final String path = 'public/$fileName';

      if (kIsWeb) {
        await supabase.storage.from('menu_images').uploadBinary(path, file);
      } else {
        await supabase.storage.from('menu_images').upload(path, file as File);
      }

      return supabase.storage.from('menu_images').getPublicUrl(path);
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  Future<void> insertMenu(Map<String, dynamic> data) async {
    await supabase.from('menu').insert(data);
  }

  Future<void> updateMenu(String id, Map<String, dynamic> data) async {
    await supabase.from('menu').update(data).eq('id_menu', id);
  }

  Future<void> deleteMenu(dynamic id) async {
    await supabase.from('menu').delete().eq('id_menu', id);
  }

  Future<List<Map<String, dynamic>>> getAllMenus() async {
    final res = await supabase
        .from('menu')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }
}
