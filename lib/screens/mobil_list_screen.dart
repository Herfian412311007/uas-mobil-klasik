import 'package:flutter/material.dart';
import '../models/mobil.dart';
import '../services/api_service.dart';
import 'mobil_form_screen.dart';

class MobilListScreen extends StatefulWidget {
  const MobilListScreen({super.key});

  @override
  State<MobilListScreen> createState() => _MobilListScreenState();
}

class _MobilListScreenState extends State<MobilListScreen> {
  late Future<List<Mobil>> _future;
  List<Mobil> _allData = [];
  List<Mobil> _filteredData = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = ApiService.getMobilList();
      _future.then((data) {
        _allData = data;
        _filteredData = data;
      });
    });
  }

  void _search(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _filteredData = _allData;
      } else {
        final lower = keyword.toLowerCase();
        _filteredData = _allData.where((mobil) {
          return mobil.namaMobil.toLowerCase().contains(lower) ||
              mobil.merek.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  Future<void> _hapus(Mobil mobil) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus "${mobil.namaMobil}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final result = await ApiService.deleteMobil(mobil.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Selesai')));
      _searchCtrl.clear();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Mobil Klasik')),
      body: Column(
        children: [
          // ---------- KOTAK PENCARIAN ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Cari nama mobil atau merek...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ---------- LIST DATA ----------
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _load(),
              child: FutureBuilder<List<Mobil>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Gagal memuat data:\n${snapshot.error}',
                          textAlign: TextAlign.center),
                    ));
                  }

                  if (_filteredData.isEmpty) {
                    return Center(
                      child: Text(
                        _searchCtrl.text.isEmpty
                            ? 'Belum ada data mobil'
                            : 'Data tidak ditemukan',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, i) {
                      final mobil = _filteredData[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: mobil.gambarUrl != null
                                ? Image.network(
                                    mobil.gambarUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _placeholderIcon(),
                                  )
                                : _placeholderIcon(),
                          ),
                          title: Text(mobil.namaMobil,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${mobil.merek} • ${mobil.tahun}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              MobilFormScreen(mobil: mobil)));
                                  _load();
                                },
                              ),
                              IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _hapus(mobil)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MobilFormScreen()));
          _load();
        },
      ),
    );
  }

  Widget _placeholderIcon() => Container(
        width: 60,
        height: 60,
        color: const Color(0xFFEFE6DD),
        child: const Icon(Icons.directions_car, color: Color(0xFF6D4C41)),
      );
}
