import 'package:flutter_pertemuan4/domain/entities/mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/repositories/mahasiswa_repository.dart';

// Latihan 2: use case pencarian mahasiswa (nama atau NIM).
class SearchMahasiswa {
  final MahasiswaRepository repository;

  SearchMahasiswa(this.repository);

  Future<List<Mahasiswa>> call(String query) async =>
      repository.searchMahasiswa(query);
}
