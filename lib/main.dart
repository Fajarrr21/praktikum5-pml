import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unused_import
import 'package:flutter_pertemuan4/data/data_sources/mahasiswa_local_data_source.dart';
// ignore: unused_import
import 'package:flutter_pertemuan4/data/data_sources/mahasiswa_remote_data_source.dart';
import 'package:flutter_pertemuan4/data/repositories/mahasiswa_repository_impl.dart';
import 'package:flutter_pertemuan4/domain/repositories/mahasiswa_repository.dart';
import 'package:flutter_pertemuan4/domain/usecases/add_mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/usecases/delete_mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/usecases/get_all_mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/usecases/search_mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/usecases/update_mahasiswa.dart';
import 'package:flutter_pertemuan4/presentation/bloc/mahasiswa_bloc.dart';
import 'package:flutter_pertemuan4/presentation/bloc/mahasiswa_event.dart';
import 'package:flutter_pertemuan4/presentation/pages/mahasiswa_page.dart';

void main() {
  // ===========================================================================
  // CARA MEMILIH SUMBER DATA:
  // Cukup aktifkan salah satu baris di bawah ini (comment yang lain):
  // ===========================================================================

  // OPSI 1: Data Lokal (In-Memory List seperti Pertemuan 04)
  // final dataSource = MahasiswaLocalDataSourceImpl();

  // OPSI 2: REST API Server (kampus-api: Node.js + MySQL)
  final dataSource = MahasiswaRemoteDataSourceImpl();

  // ===========================================================================

  // Injeksi Data Source ke Repository (Dependency Inversion)
  final MahasiswaRepository repo = MahasiswaRepositoryImpl(
    dataSource: dataSource,
  );

  runApp(MyApp(repo: repo));
}

class MyApp extends StatelessWidget {
  final MahasiswaRepository repo;

  const MyApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture + BLoC',
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        // Injeksi Repository ke Use Cases, lalu Use Cases ke BLoC
        create: (_) => MahasiswaBloc(
          getAllMahasiswa: GetAllMahasiswa(repo),
          addMahasiswa: AddMahasiswa(repo),
          updateMahasiswa: UpdateMahasiswa(repo),
          deleteMahasiswa: DeleteMahasiswa(repo),
          searchMahasiswa: SearchMahasiswa(repo),
        )..add(const LoadMahasiswaEvent()), // Muat data di awal
        child: const MahasiswaPage(),
      ),
    );
  }
}
