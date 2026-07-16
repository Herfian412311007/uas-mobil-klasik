import '../config/api_config.dart';

class Mobil {
  final int? id;
  final String namaMobil;
  final String merek;
  final int tahun;
  final double harga;
  final String deskripsi;
  final String? gambar;

  Mobil({
    this.id,
    required this.namaMobil,
    required this.merek,
    required this.tahun,
    required this.harga,
    required this.deskripsi,
    this.gambar,
  });

  factory Mobil.fromJson(Map<String, dynamic> json) {
    return Mobil(
      id: int.parse(json['id'].toString()),
      namaMobil: json['nama_mobil'] ?? '',
      merek: json['merek'] ?? '',
      tahun: int.tryParse(json['tahun'].toString()) ?? 0,
      harga: double.tryParse(json['harga'].toString()) ?? 0,
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'],
    );
  }

  String? get gambarUrl {
    if (gambar == null || gambar!.isEmpty) return null;
    return "${ApiConfig.uploadsUrl}/$gambar";
  }
}
