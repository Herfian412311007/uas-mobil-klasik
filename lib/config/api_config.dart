// Ganti sesuai alamat server PHP.
// - Jika pakai emulator Android + XAMPP di komputer yang sama: gunakan 10.0.2.2
// - Jika pakai HP fisik: gunakan alamat IP komputer kamu di jaringan wifi yang sama, misal 192.168.1.5
class ApiConfig {
  static const String baseUrl = "http://10.91.85.70/UAS_MobilKlasik";
  static const String uploadsUrl = "$baseUrl/uploads";
}
