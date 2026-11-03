import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pertemuan4/data/data_sources/mahasiswa_local_data_source.dart';
import 'package:flutter_pertemuan4/data/repositories/mahasiswa_repository_impl.dart';
import 'package:flutter_pertemuan4/main.dart';

// Test memakai Local Data Source supaya tidak butuh server kampus-api.
MyApp buatApp() => MyApp(
      repo: MahasiswaRepositoryImpl(
        dataSource: MahasiswaLocalDataSourceImpl(),
      ),
    );

void main() {
  testWidgets('Halaman Data Mahasiswa tampil dengan data lokal',
      (WidgetTester tester) async {
    await tester.pumpWidget(buatApp());
    // Tunggu proses async (loading) selesai.
    await tester.pumpAndSettle();

    expect(find.text('Data Mahasiswa'), findsOneWidget);
    expect(find.text('Ahmad Dahlan (Local) (220101)'), findsOneWidget);
    expect(find.text('Siti Nurhaliza (Local) (220102)'), findsOneWidget);
  });

  testWidgets('Pencarian berdasarkan nama dan NIM (Latihan 2)',
      (WidgetTester tester) async {
    await tester.pumpWidget(buatApp());
    await tester.pumpAndSettle();

    // Cari nama, huruf kecil semua.
    await tester.enterText(find.byType(TextField), 'siti');
    await tester.pumpAndSettle();
    expect(find.text('Siti Nurhaliza (Local) (220102)'), findsOneWidget);
    expect(find.text('Ahmad Dahlan (Local) (220101)'), findsNothing);

    // Cari NIM.
    await tester.enterText(find.byType(TextField), '220101');
    await tester.pumpAndSettle();
    expect(find.text('Ahmad Dahlan (Local) (220101)'), findsOneWidget);
    expect(find.text('Siti Nurhaliza (Local) (220102)'), findsNothing);

    // Kata yang tidak ada.
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Mahasiswa "zzz" tidak ditemukan.'), findsOneWidget);
  });
}
