import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result =
          await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (result['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama', result['user']['nama']);
        await prefs.setString('email', result['user']['email']);
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        _showMsg(result['message'] ?? 'Login gagal');
      }
    } catch (e) {
      _showMsg('Tidak bisa terhubung ke server: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4E342E),
                  Color(0xFF6D4C41),
                  Color(0xFFF5F0EA)
                ],
                stops: [0.0, 0.35, 0.65],
              ),
            ),
          ),
          Positioned(
              top: 60,
              left: -20,
              child: _carIcon(70, Colors.white.withOpacity(0.10))),
          Positioned(
              top: 140,
              right: -10,
              child: _carIcon(50, Colors.white.withOpacity(0.15))),
          Positioned(
              top: 230,
              left: 40,
              child: _carIcon(35, Colors.white.withOpacity(0.12))),
          Positioned(
              top: 30,
              right: 90,
              child: _carIcon(30, Colors.white.withOpacity(0.18))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        height: 110,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 5)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Image.asset('assets/images/mobil_strip.jpg',
                                height: 110, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Mobil Klasik',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const Text('Masuk untuk melanjutkan',
                          style: TextStyle(color: Color(0xFFE0D5CB))),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Email wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Password wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6D4C41)),
                                onPressed: _loading ? null : _login,
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('Login',
                                        style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen())),
                              child: const Text(
                                  'Belum punya akun? Daftar di sini'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carIcon(double size, Color color) {
    return Icon(Icons.directions_car_filled, size: size, color: color);
  }
}
