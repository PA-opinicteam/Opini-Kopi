import 'package:flutter/material.dart';
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
    await Future.delayed(const Duration(seconds: 3)); 

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5EFE6),
              Color.fromARGB(255, 255, 228, 200), 
            ],
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
                width: 200,
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

              const CircularProgressIndicator(
                color: Color(0xFF4B2E2B), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}