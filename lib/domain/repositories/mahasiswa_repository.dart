import 'package:flutter_pertemuan4/domain/entities/mahasiswa.dart';

// Kontrak repository: semua method sekarang async (Future),
// karena data bisa datang dari server lewat jaringan.
abstract class MahasiswaRepository {
  Future<List<Mahasiswa>> getAllMahasiswa();
  Future<void> addMahasiswa(Mahasiswa mahasiswa);
  Future<void> updateMahasiswa(String nim, Mahasiswa mahasiswa);
  Future<void> deleteMahasiswa(String nim);

  // Latihan 2: pencarian berdasarkan nama atau NIM.
  Future<List<Mahasiswa>> searchMahasiswa(String query);
}
