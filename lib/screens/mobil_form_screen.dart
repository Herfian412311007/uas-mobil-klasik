import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/mobil.dart';
import '../services/api_service.dart';

class MobilFormScreen extends StatefulWidget {
  final Mobil? mobil; // null = tambah baru, ada isinya = edit
  const MobilFormScreen({super.key, this.mobil});

  @override
  State<MobilFormScreen> createState() => _MobilFormScreenState();
}

class _MobilFormScreenState extends State<MobilFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _merekCtrl;
  late TextEditingController _tahunCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _deskripsiCtrl;

  File? _gambarBaru;
  bool _loading = false;
  bool get isEdit => widget.mobil != null;

  @override
  void initState() {
    super.initState();
    final m = widget.mobil;
    _namaCtrl = TextEditingController(text: m?.namaMobil ?? '');
    _merekCtrl = TextEditingController(text: m?.merek ?? '');
    _tahunCtrl = TextEditingController(text: m?.tahun.toString() ?? '');
    _hargaCtrl = TextEditingController(text: m != null ? m.harga.toStringAsFixed(0) : '');
    _deskripsiCtrl = TextEditingController(text: m?.deskripsi ?? '');
  }

  Future<void> _pilihGambar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => _gambarBaru = File(picked.path));
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final mobilBaru = Mobil(
      id: widget.mobil?.id,
      namaMobil: _namaCtrl.text.trim(),
      merek: _merekCtrl.text.trim(),
      tahun: int.tryParse(_tahunCtrl.text.trim()) ?? 0,
      harga: double.tryParse(_hargaCtrl.text.trim()) ?? 0,
      deskripsi: _deskripsiCtrl.text.trim(),
    );

    try {
      final result = isEdit
          ? await ApiService.updateMobil(mobilBaru, _gambarBaru)
          : await ApiService.createMobil(mobilBaru, _gambarBaru);

      if (!mounted) return;
      if (result['status'] == 'success') {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Selesai')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Mobil' : 'Tambah Mobil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pilihGambar,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE6DD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _gambarBaru != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_gambarBaru!, fit: BoxFit.cover))
                      : (widget.mobil?.gambarUrl != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.mobil!.gambarUrl!, fit: BoxFit.cover))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Color(0xFF6D4C41)),
                                Text('Ketuk untuk pilih gambar'),
                              ],
                            )),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama Mobil', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _merekCtrl,
                decoration: const InputDecoration(labelText: 'Merek', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _tahunCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tahun', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _hargaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga (Rp)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _simpan,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(isEdit ? 'Update' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
