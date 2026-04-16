import 'supabase_service.dart';

class AuthService {
  final supabase = SupabaseService.client;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password)
        .eq('is_actived', true)
        .maybeSingle();

    if (data == null) {
      throw Exception('Email atau password salah');
    }

    return data;
  }
}
