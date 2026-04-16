import 'package:flutter/material.dart';
import 'package:opini_kopi/pages/cashier/home_page.dart';
import 'package:opini_kopi/pages/owner/dashboard_page.dart';
import 'package:opini_kopi/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isObscure = true;
  bool isLoading = false;

  String? passwordError;
  String? emailError;

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      passwordError = null;
      emailError = null;
    });

    try {
      final userData = await AuthService().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final role = userData['role'];

      if (!mounted) return;

      if (role == 'kasir') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        emailError = 'Email atau password salah';
        passwordError = 'Email atau password salah';
      });

      _formKey.currentState!.validate();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Email atau password salah',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF4B2E2B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration inputStyle(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5EFE6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6F4E37), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.black38),
      suffixIcon: suffix,
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F2),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8DFD8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EFE6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.coffee,
                    color: Color(0xFF6F4E37),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Opini Kopi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B2E2B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Masuk untuk melanjutkan sebagai Owner atau Kasir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label('Email'),
                      TextFormField(
                        controller: emailController,
                        decoration: inputStyle('admin@gmail.com'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          if (emailError != null) {
                            final err = emailError;
                            emailError = null;
                            return err;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      label('Password'),
                      TextFormField(
                        controller: passwordController,
                        obscureText: isObscure,
                        decoration: inputStyle(
                          '********',
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 8) {
                            return 'Minimal 8 karakter';
                          }
                          if (passwordError != null) {
                            final err = passwordError;
                            passwordError = null;
                            return err;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4B2E2B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isLoading ? null : handleLogin,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
