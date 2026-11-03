import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pertemuan4/domain/usecases/add_mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/usecases/delete_mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/usecases/get_all_mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/usecases/search_mahasiswa.dart';
import 'package:flutter_pertemuan4/domain/usecases/update_mahasiswa.dart';
import 'package:flutter_pertemuan4/presentation/bloc/mahasiswa_event.dart';
import 'package:flutter_pertemuan4/presentation/bloc/mahasiswa_state.dart';

class MahasiswaBloc extends Bloc<MahasiswaEvent, MahasiswaState> {
  final GetAllMahasiswa getAllMahasiswa;
  final AddMahasiswa addMahasiswa;
  final UpdateMahasiswa updateMahasiswa;
  final DeleteMahasiswa deleteMahasiswa;
  final SearchMahasiswa searchMahasiswa;

  // Kata kunci pencarian yang sedang aktif.
  String _keyword = '';

  MahasiswaBloc({
    required this.getAllMahasiswa,
    required this.addMahasiswa,
    required this.updateMahasiswa,
    required this.deleteMahasiswa,
    required this.searchMahasiswa,
  }) : super(const MahasiswaInitial()) {
    on<LoadMahasiswaEvent>((event, emit) async {
      emit(const MahasiswaLoading());
      await _muatData(emit);
    });

    on<AddMahasiswaEvent>((event, emit) async {
      emit(const MahasiswaLoading());
      try {
        await addMahasiswa(event.mahasiswa);
      } catch (e) {
        // Contoh: IPK tidak valid, NIM sudah terdaftar (409), server mati.
        emit(MahasiswaError(_pesanError(e)));
      }
      // Berhasil atau gagal, list tetap dimuat ulang supaya tidak hilang.
      await _muatData(emit);
    });

    on<UpdateMahasiswaEvent>((event, emit) async {
      emit(const MahasiswaLoading());
      try {
        await updateMahasiswa(event.nim, event.mahasiswa);
      } catch (e) {
        emit(MahasiswaError(_pesanError(e)));
      }
      await _muatData(emit);
    });

    on<DeleteMahasiswaEvent>((event, emit) async {
      emit(const MahasiswaLoading());
      try {
        await deleteMahasiswa(event.nim);
      } catch (e) {
        emit(MahasiswaError(_pesanError(e)));
      }
      await _muatData(emit);
    });

    // Latihan 2: pencarian. Sengaja tidak emit MahasiswaLoading agar list
    // tidak berkedip (muncul loading) setiap kali satu huruf diketik.
    on<SearchMahasiswaEvent>((event, emit) async {
      _keyword = event.query.trim();
      await _muatData(emit);
    });
  }

  // Ambil data terbaru: semua data, atau hasil pencarian kalau ada kata kunci.
  Future<void> _muatData(Emitter<MahasiswaState> emit) async {
    final kata = _keyword;
    try {
      final data =
          kata.isEmpty ? await getAllMahasiswa() : await searchMahasiswa(kata);
      // Kalau selama menunggu user sudah mengetik kata lain,
      // hasil lama ini dibuang supaya tidak menimpa hasil yang lebih baru.
      if (kata != _keyword) return;
      emit(MahasiswaLoaded(data, keyword: kata));
    } catch (e) {
      if (kata != _keyword) return;
      emit(MahasiswaError(_pesanError(e)));
    }
  }

  // Ubah error menjadi teks yang enak dibaca (buang awalan "Exception: ").
  String _pesanError(Object e) => e.toString().replaceAll("Exception: ", "");
}
