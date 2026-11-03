import 'package:flutter_pertemuan4/data/models/mahasiswa_model.dart';

// Abstraksi (kontrak) data source.
// Local dan Remote data source sama-sama mengikuti kontrak ini,
// sehingga Repository tidak perlu tahu data datang dari mana.
abstract class MahasiswaDataSource {
  Future<List<MahasiswaModel>> getAllMahasiswa();
  Future<void> addMahasiswa(MahasiswaModel mahasiswa);
  Future<void> updateMahasiswa(String nim, MahasiswaModel mahasiswa);
  Future<void> deleteMahasiswa(String nim);

  // Latihan 2
  Future<List<MahasiswaModel>> searchMahasiswa(String query);
}
