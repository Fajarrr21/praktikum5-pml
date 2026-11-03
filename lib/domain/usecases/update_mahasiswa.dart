import 'package:flutter_pertemuan4/domain/entities/mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/exceptions/ipk_tidak_valid_exception.dart';
import 'package:flutter_pertemuan4/domain/repositories/mahasiswa_repository.dart';

class UpdateMahasiswa {
  final MahasiswaRepository repository;

  UpdateMahasiswa(this.repository);

  Future<void> call(String nim, Mahasiswa mahasiswa) async {
    // Aturan bisnis dari Pertemuan 4 tetap dipertahankan.
    if (mahasiswa.ipk < 0.0 || mahasiswa.ipk > 4.0) {
      throw IpkTidakValidException();
    }
    await repository.updateMahasiswa(nim, mahasiswa);
  }
}
