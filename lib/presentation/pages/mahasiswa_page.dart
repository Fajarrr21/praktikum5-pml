import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pertemuan4/domain/entities/mahasiswa.dart';
import 'package:flutter_pertemuan4/presentation/bloc/mahasiswa_bloc.dart';
import 'package:flutter_pertemuan4/presentation/bloc/mahasiswa_event.dart';
import 'package:flutter_pertemuan4/presentation/bloc/mahasiswa_state.dart';

class MahasiswaPage extends StatelessWidget {
  const MahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MahasiswaBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("Data Mahasiswa")),
      body: Column(
        children: [
          // Latihan 2: kolom pencarian di atas list.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Cari nama atau NIM",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => bloc.add(SearchMahasiswaEvent(value)),
            ),
          ),
          Expanded(
            child: BlocConsumer<MahasiswaBloc, MahasiswaState>(
              listenWhen: (previous, current) => current is MahasiswaError,
              listener: (context, state) {
                if (state is MahasiswaError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is MahasiswaInitial || state is MahasiswaLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MahasiswaLoaded) {
                  final data = state.mahasiswaList;

                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        state.keyword.isEmpty
                            ? "Belum ada data. Tekan + untuk menambah."
                            : 'Mahasiswa "${state.keyword}" tidak ditemukan.',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final mhs = data[i];
                      return ListTile(
                        title: Text("${mhs.nama} (${mhs.nim})"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Prodi: ${mhs.prodi}"),
                            Text("Email: ${mhs.email}"),
                            Text("IPK: ${mhs.ipk}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showForm(context, bloc, mhs: mhs);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                bloc.add(DeleteMahasiswaEvent(mhs.nim));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is MahasiswaError) {
                  // Misalnya server mati: pesan error tampil di tengah layar.
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(state.message, textAlign: TextAlign.center),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, bloc),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, MahasiswaBloc bloc, {Mahasiswa? mhs}) {
    final nimCtrl = TextEditingController(text: mhs?.nim ?? '');
    final namaCtrl = TextEditingController(text: mhs?.nama ?? '');
    final emailCtrl = TextEditingController(text: mhs?.email ?? '');
    final prodiCtrl = TextEditingController(text: mhs?.prodi ?? '');
    final ipkCtrl = TextEditingController(text: mhs?.ipk.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(mhs == null ? "Tambah Mahasiswa" : "Edit Mahasiswa"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nimCtrl,
                decoration: const InputDecoration(labelText: "NIM"),
              ),
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: prodiCtrl,
                decoration: const InputDecoration(labelText: "Prodi"),
              ),
              TextField(
                controller: ipkCtrl,
                decoration: const InputDecoration(labelText: "IPK"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final mahasiswa = Mahasiswa(
                nim: nimCtrl.text,
                nama: namaCtrl.text,
                email: emailCtrl.text,
                prodi: prodiCtrl.text,
                ipk: double.tryParse(ipkCtrl.text) ?? 0,
              );

              if (mhs == null) {
                bloc.add(AddMahasiswaEvent(mahasiswa));
              } else {
                bloc.add(UpdateMahasiswaEvent(mhs.nim, mahasiswa));
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
