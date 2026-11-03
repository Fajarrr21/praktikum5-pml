import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_pertemuan4/data/data_sources/mahasiswa_data_source.dart';
import 'package:flutter_pertemuan4/data/models/mahasiswa_model.dart';

abstract class MahasiswaRemoteDataSource implements MahasiswaDataSource {}

// Data diambil dari REST API kampus-api (Node.js + MySQL).
class MahasiswaRemoteDataSourceImpl implements MahasiswaRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  // Batas waktu tunggu jawaban dari server.
  // Latihan 1: diubah dari 5 detik (modul) menjadi 1 detik.
  static const Duration _timeout = Duration(seconds: 1);

  MahasiswaRemoteDataSourceImpl({
    this.baseUrl = "http://localhost:3000/api/mahasiswa",
    http.Client? client,
  }) : client = client ?? http.Client();

  // Ambil pesan error dari body JSON server, misalnya {"error": "..."}.
  String _extractError(http.Response response, String defaultMsg) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('error')) {
        return body['error'].toString();
      }
      if (body is Map && body.containsKey('message')) {
        return body['message'].toString();
      }
    } catch (_) {}
    return "$defaultMsg (Status: ${response.statusCode})";
  }

  @override
  Future<List<MahasiswaModel>> getAllMahasiswa() async {
    http.Response response;
    try {
      response = await client.get(Uri.parse(baseUrl)).timeout(_timeout);
    } catch (e) {
      throw Exception(
        "Gagal terhubung ke REST API ($baseUrl).\n"
        "Pastikan backend kampus-api sudah berjalan.",
      );
    }
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((item) => MahasiswaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_extractError(response, "Gagal memuat data"));
  }

  @override
  Future<void> addMahasiswa(MahasiswaModel mahasiswa) async {
    http.Response response;
    try {
      response = await client
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(mahasiswa.toJson()),
          )
          .timeout(_timeout);
    } catch (e) {
      throw Exception("Gagal terhubung ke REST API ($baseUrl): $e");
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractError(response, "Gagal menambahkan data"));
    }
  }

  @override
  Future<void> updateMahasiswa(String nim, MahasiswaModel mahasiswa) async {
    http.Response response;
    try {
      response = await client
          .put(
            Uri.parse("$baseUrl/$nim"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(mahasiswa.toJson()),
          )
          .timeout(_timeout);
    } catch (e) {
      throw Exception("Gagal terhubung ke REST API ($baseUrl): $e");
    }
    if (response.statusCode != 200) {
      throw Exception(_extractError(response, "Gagal memperbarui data"));
    }
  }

  @override
  Future<void> deleteMahasiswa(String nim) async {
    http.Response response;
    try {
      response =
          await client.delete(Uri.parse("$baseUrl/$nim")).timeout(_timeout);
    } catch (e) {
      throw Exception("Gagal terhubung ke REST API ($baseUrl): $e");
    }
    if (response.statusCode != 200) {
      throw Exception(_extractError(response, "Gagal menghapus data"));
    }
  }

  // Latihan 2: GET http://localhost:3000/api/mahasiswa/search?q=<kata>
  // Pencarian dilakukan oleh MySQL di server (LIKE %kata%).
  @override
  Future<List<MahasiswaModel>> searchMahasiswa(String query) async {
    final kata = query.trim();
    if (kata.isEmpty) return getAllMahasiswa();

    // queryParameters otomatis meng-encode karakter khusus (spasi, &, %, dll).
    final uri = Uri.parse("$baseUrl/search").replace(
      queryParameters: {'q': kata},
    );

    http.Response response;
    try {
      response = await client.get(uri).timeout(_timeout);
    } catch (e) {
      throw Exception(
        "Gagal terhubung ke REST API ($baseUrl).\n"
        "Pastikan backend kampus-api sudah berjalan.",
      );
    }
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((item) => MahasiswaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_extractError(response, "Gagal mencari data"));
  }
}
