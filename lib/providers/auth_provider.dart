import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:opini_kopi/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  static const _sessionKey = 'opini_pos_user_session';

  final AuthService _authService;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  AuthStatus status = AuthStatus.checking;
  Map<String, dynamic>? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  String get role => (user?['role'] ?? '').toString();
  bool get isCashier => role.toLowerCase() == 'kasir';

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      user = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      status = AuthStatus.authenticated;
    } catch (_) {
      await prefs.remove(_sessionKey);
      user = null;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    status = AuthStatus.checking;
    notifyListeners();

    final data = await _authService.login(email, password);
    user = data;
    status = AuthStatus.authenticated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(data));
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
