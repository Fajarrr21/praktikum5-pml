import 'package:flutter_pertemuan4/data/data_sources/mahasiswa_data_source.dart';
import 'package:flutter_pertemuan4/data/models/mahasiswa_model.dart';

abstract class MahasiswaLocalDataSource implements MahasiswaDataSource {}

// Data disimpan di RAM (List), jadi akan kembali ke awal setiap aplikasi di-restart.
class MahasiswaLocalDataSourceImpl implements MahasiswaLocalDataSource {
  final List<MahasiswaModel> _storage = [
    const MahasiswaModel(
      nim: "220101",
      nama: "Ahmad Dahlan (Local)",
      email: "ahmad@kampus.ac.id",
      prodi: "Teknik Informatika",
      ipk: 3.85,
    ),
    const MahasiswaModel(
      nim: "220102",
      nama: "Siti Nurhaliza (Local)",
      email: "siti@kampus.ac.id",
      prodi: "Sistem Informasi",
      ipk: 3.90,
    ),
  ];

  @override
  Future<List<MahasiswaModel>> getAllMahasiswa() async {
    // Pura-pura ada jeda kecil, seperti mengambil data dari tempat lain.
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_storage);
  }

  @override
  Future<void> addMahasiswa(MahasiswaModel mahasiswa) async {
    _storage.add(mahasiswa);
  }

  @override
  Future<void> updateMahasiswa(String nim, MahasiswaModel mahasiswa) async {
    final index = _storage.indexWhere((m) => m.nim == nim);
    if (index != -1) _storage[index] = mahasiswa;
  }

  @override
  Future<void> deleteMahasiswa(String nim) async {
    _storage.removeWhere((m) => m.nim == nim);
  }

  // Latihan 2: cari pakai .where(), cocokkan nama ATAU NIM,
  // tidak peka huruf besar/kecil (semua diubah ke huruf kecil dulu).
  @override
  Future<List<MahasiswaModel>> searchMahasiswa(String query) async {
    final kata = query.trim().toLowerCase();
    if (kata.isEmpty) return getAllMahasiswa();

    return _storage
        .where((m) =>
            m.nama.toLowerCase().contains(kata) ||
            m.nim.toLowerCase().contains(kata))
        .toList();
  }
}
