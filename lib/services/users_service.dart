import 'package:supabase_flutter/supabase_flutter.dart';

class UsersService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> addUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required bool isActived,
  }) async {
    await supabase.from('users').insert({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'is_actived': isActived,
    });
  }

  Future<void> updateUser({
    required String id,
    required String name,
    required String email,
    required String role,
    required bool isActived,
  }) async {
    await supabase
        .from('users')
        .update({
          'name': name,
          'email': email,
          'role': role,
          'is_actived': isActived,
        })
        .eq('id_user', id);
  }

  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id_user', id);
  }
}
