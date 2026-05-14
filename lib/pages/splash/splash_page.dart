import 'package:flutter/material.dart';
import 'package:opini_kopi/pages/cashier/home_page.dart';
import 'package:opini_kopi/pages/owner/dashboard_page.dart';
import 'package:opini_kopi/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../auth/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.restoreSession();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (!auth.isAuthenticated) return const LoginPage();
          return auth.isCashier ? const HomePage() : const DashboardPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5EFE6), Color.fromARGB(255, 255, 228, 200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/opini_kopi_no_bg.png',
                width: MediaQuery.sizeOf(context).width < 480 ? 150 : 190,
              ),

              const SizedBox(height: 20),

              const Text(
                "Your Coffee, Your Opinion",
                style: TextStyle(
                  color: Color(0xFF6C86B7),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 30),

              const CircularProgressIndicator(color: Color(0xFF4B2E2B)),
            ],
          ),
        ),
      ),
    );
  }
}
