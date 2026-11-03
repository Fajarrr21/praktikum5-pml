import 'package:equatable/equatable.dart';

class Mahasiswa extends Equatable {
  final String nim;
  final String nama;
  final String email;
  final String prodi;
  final double ipk;

  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.email,
    required this.prodi,
    required this.ipk,
  });

  Mahasiswa copyWith({
    String? nim,
    String? nama,
    String? email,
    String? prodi,
    double? ipk,
  }) {
    return Mahasiswa(
      nim: nim ?? this.nim,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      prodi: prodi ?? this.prodi,
      ipk: ipk ?? this.ipk,
    );
  }

  // Equatable: dua objek Mahasiswa dianggap sama kalau isi props-nya sama.
  @override
  List<Object?> get props => [nim, nama, email, prodi, ipk];
}
