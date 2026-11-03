import 'package:equatable/equatable.dart';
import 'package:flutter_pertemuan4/domain/entities/mahasiswa.dart';

abstract class MahasiswaState extends Equatable {
  const MahasiswaState();

  @override
  List<Object?> get props => [];
}

class MahasiswaInitial extends MahasiswaState {
  const MahasiswaInitial();
}

class MahasiswaLoading extends MahasiswaState {
  const MahasiswaLoading();
}

class MahasiswaLoaded extends MahasiswaState {
  final List<Mahasiswa> mahasiswaList;
  // Kata kunci pencarian yang sedang aktif (dari Pertemuan 4).
  final String keyword;
  const MahasiswaLoaded(this.mahasiswaList, {this.keyword = ''});

  @override
  List<Object?> get props => [mahasiswaList, keyword];
}

class MahasiswaError extends MahasiswaState {
  final String message;
  const MahasiswaError(this.message);

  @override
  List<Object?> get props => [message];
}
