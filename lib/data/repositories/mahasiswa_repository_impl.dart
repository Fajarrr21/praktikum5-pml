import 'package:flutter_pertemuan4/data/data_sources/mahasiswa_data_source.dart';
import 'package:flutter_pertemuan4/data/models/mahasiswa_model.dart';
import 'package:flutter_pertemuan4/domain/entities/mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/repositories/mahasiswa_repository.dart';

class MahasiswaRepositoryImpl implements MahasiswaRepository {
  // Dependency Inversion: Repository hanya kenal abstraksi MahasiswaDataSource,
  // bukan kelas Local/Remote secara langsung. Isinya dikirim dari main.dart.
  final MahasiswaDataSource dataSource;

  MahasiswaRepositoryImpl({required this.dataSource});

  @override
  Future<List<Mahasiswa>> getAllMahasiswa() async {
    final models = await dataSource.getAllMahasiswa();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addMahasiswa(Mahasiswa mahasiswa) async {
    await dataSource.addMahasiswa(MahasiswaModel.fromEntity(mahasiswa));
  }

  @override
  Future<void> updateMahasiswa(String nim, Mahasiswa mahasiswa) async {
    await dataSource.updateMahasiswa(nim, MahasiswaModel.fromEntity(mahasiswa));
  }

  @override
  Future<void> deleteMahasiswa(String nim) async {
    await dataSource.deleteMahasiswa(nim);
  }

  @override
  Future<List<Mahasiswa>> searchMahasiswa(String query) async {
    final models = await dataSource.searchMahasiswa(query);
    return models.map((model) => model.toEntity()).toList();
  }
}
