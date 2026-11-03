import 'package:flutter_pertemuan4/domain/entities/mahasiswa.dart';

class MahasiswaModel extends Mahasiswa {
  const MahasiswaModel({
    required super.nim,
    required super.nama,
    required super.email,
    required super.prodi,
    required super.ipk,
  });

  factory MahasiswaModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaModel(
      nim: json['nim']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      prodi: json['prodi']?.toString() ?? '',
      // MySQL (DECIMAL) bisa mengirim IPK sebagai teks, misalnya "3.85",
      // jadi kita terima dua-duanya: angka atau teks.
      ipk: json['ipk'] is num
          ? (json['ipk'] as num).toDouble()
          : double.tryParse(json['ipk']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nim': nim,
      'nama': nama,
      'email': email,
      'prodi': prodi,
      'ipk': ipk,
    };
  }

  factory MahasiswaModel.fromEntity(Mahasiswa entity) {
    return MahasiswaModel(
      nim: entity.nim,
      nama: entity.nama,
      email: entity.email,
      prodi: entity.prodi,
      ipk: entity.ipk,
    );
  }

  Mahasiswa toEntity() {
    return Mahasiswa(
      nim: nim,
      nama: nama,
      email: email,
      prodi: prodi,
      ipk: ipk,
    );
  }
}
