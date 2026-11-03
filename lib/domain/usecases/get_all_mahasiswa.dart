import 'package:flutter_pertemuan4/domain/entities/mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/repositories/mahasiswa_repository.dart';

class GetAllMahasiswa {
  final MahasiswaRepository repository;

  GetAllMahasiswa(this.repository);

  Future<List<Mahasiswa>> call() async => repository.getAllMahasiswa();
}
