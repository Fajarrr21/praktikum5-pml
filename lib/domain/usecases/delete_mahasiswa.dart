import 'package:flutter_pertemuan4/domain/repositories/mahasiswa_repository.dart';

class DeleteMahasiswa {
  final MahasiswaRepository repository;

  DeleteMahasiswa(this.repository);

  Future<void> call(String nim) async => repository.deleteMahasiswa(nim);
}
