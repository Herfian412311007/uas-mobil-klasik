import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/mobil.dart';

class ApiService {
  // ---------- AUTH ----------
  static Future<Map<String, dynamic>> register(
      String nama, String email, String password) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/register.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nama": nama, "email": email, "password": password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(res.body);
  }

  // ---------- CRUD MOBIL ----------
  static Future<List<Mobil>> getMobilList() async {
    final res = await http.get(Uri.parse("${ApiConfig.baseUrl}/mobil.php"));
    final body = jsonDecode(res.body);
    if (body['status'] == 'success') {
      List data = body['data'];
      return data.map((e) => Mobil.fromJson(e)).toList();
    }
    throw Exception(body['message'] ?? 'Gagal mengambil data');
  }

  static Future<Map<String, dynamic>> createMobil(
      Mobil mobil, File? gambar) async {
    var request = http.MultipartRequest(
        "POST", Uri.parse("${ApiConfig.baseUrl}/mobil.php"));
    request.fields['nama_mobil'] = mobil.namaMobil;
    request.fields['merek'] = mobil.merek;
    request.fields['tahun'] = mobil.tahun.toString();
    request.fields['harga'] = mobil.harga.toString();
    request.fields['deskripsi'] = mobil.deskripsi;
    if (gambar != null) {
      request.files
          .add(await http.MultipartFile.fromPath('gambar', gambar.path));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateMobil(
      Mobil mobil, File? gambar) async {
    var request = http.MultipartRequest(
        "POST", Uri.parse("${ApiConfig.baseUrl}/mobil.php"));
    request.fields['_method'] = 'PUT';
    request.fields['id'] = mobil.id.toString();
    request.fields['nama_mobil'] = mobil.namaMobil;
    request.fields['merek'] = mobil.merek;
    request.fields['tahun'] = mobil.tahun.toString();
    request.fields['harga'] = mobil.harga.toString();
    request.fields['deskripsi'] = mobil.deskripsi;
    if (gambar != null) {
      request.files
          .add(await http.MultipartFile.fromPath('gambar', gambar.path));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteMobil(int id) async {
    var request = http.MultipartRequest(
        "POST", Uri.parse("${ApiConfig.baseUrl}/mobil.php"));
    request.fields['_method'] = 'DELETE';
    request.fields['id'] = id.toString();
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }
}
