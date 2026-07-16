import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result = await ApiService.register(_namaCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
      if (result['status'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil, silakan login')));
        Navigator.pop(context);
      } else {
        _showMsg(result['message'] ?? 'Registrasi gagal');
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
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                    validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                    validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Daftar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
