# Jawaban Latihan – Pertemuan 5: Clean Architecture Lanjut

---

## Latihan 1 – Eksplorasi Timeout Jaringan

**Yang diubah:** di `lib/data/data_sources/mahasiswa_remote_data_source.dart`, batas waktu tunggu diubah dari 5 detik menjadi 1 detik:

```dart
static const Duration _timeout = Duration(seconds: 1);
```

**Pesan yang muncul kalau server Node.js dimatikan:**

Saat aplikasi dibuka (memuat data), di tengah layar dan di SnackBar akan muncul:

```
Gagal terhubung ke REST API (http://localhost:3000/api/mahasiswa).
Pastikan backend kampus-api sudah berjalan.
```

Kalau yang gagal adalah tambah/edit/hapus data, pesannya ikut menyertakan penyebab aslinya, misalnya:

```
Gagal terhubung ke REST API (http://localhost:3000/api/mahasiswa): TimeoutException after 0:00:01.000000: Future not completed
```

(Di Chrome, penyebabnya bisa juga berupa `ClientException: ...` dari browser, tergantung mana yang lebih dulu terjadi: browser menyerah atau timeout 1 detik habis.)

**Kenapa begitu?**

1. Aplikasi mengirim permintaan ke `localhost:3000`, tapi tidak ada yang menjawab karena server mati.
2. Ada dua kemungkinan yang terjadi:
   - **Timeout:** aplikasi sudah menunggu 1 detik dan belum ada jawaban, maka `.timeout(...)` melempar `TimeoutException`. Di Windows, mencoba konek ke port yang tertutup bisa makan waktu lebih dari 1 detik (Windows mencoba ulang beberapa kali), jadi dengan batas 1 detik, timeout biasanya yang lebih dulu kena.
   - **Koneksi ditolak:** komputer langsung bilang "port ini tidak ada yang pakai", maka muncul error koneksi (`SocketException` / `ClientException`).
3. Apa pun jenis error-nya, semuanya ditangkap oleh `try { ... } catch (e) { ... }` di remote data source, lalu diubah menjadi `Exception` dengan pesan yang ramah dibaca.
4. BLoC menangkap exception itu dan mengubahnya menjadi state `MahasiswaError(pesan)`. Halaman cukup menampilkan isi pesannya. Aplikasi **tidak crash**.

**Bedanya 1 detik vs 5 detik:** dengan 1 detik, pesan error muncul lebih cepat. Tapi kalau server sebenarnya hidup namun lambat (misalnya jaringan jelek), permintaan yang sebenarnya bisa berhasil malah dianggap gagal. Jadi timeout yang terlalu kecil juga tidak baik; 5 detik adalah nilai yang lebih aman.

---

## Latihan 2 – Search Filter (ringkasan apa yang dibuat)

| Lapisan | File | Isi |
|---|---|---|
| Domain | `domain/repositories/mahasiswa_repository.dart` | tambah `Future<List<Mahasiswa>> searchMahasiswa(String query);` |
| Domain | `domain/usecases/search_mahasiswa.dart` | use case `SearchMahasiswa` |
| Data | `data/data_sources/mahasiswa_data_source.dart` | tambah `searchMahasiswa` di kontrak |
| Data | `data/data_sources/mahasiswa_local_data_source.dart` | pakai `.where()`, cocokkan nama **atau** NIM, huruf besar/kecil tidak berpengaruh |
| Data | `data/data_sources/mahasiswa_remote_data_source.dart` | panggil `GET /api/mahasiswa/search?q=<kata>` |
| Data | `data/repositories/mahasiswa_repository_impl.dart` | teruskan ke data source, ubah Model jadi Entity |
| Presentation | `presentation/bloc/mahasiswa_event.dart` | `SearchMahasiswaEvent(query)` |
| Presentation | `presentation/bloc/mahasiswa_bloc.dart` | handler pencarian |
| Presentation | `presentation/pages/mahasiswa_page.dart` | `TextField` "Cari nama atau NIM" di atas list |
| Backend | `kampus-api/routes/mahasiswa.js` | route `GET /search` dengan `LIKE ?` |

Query SQL di backend:

```js
const sql = "SELECT * FROM mahasiswa WHERE nama LIKE ? OR nim LIKE ?";
db.query(sql, [pola, pola], ...); // pola = `%${q}%`
```

Nilai pencarian dikirim lewat tanda `?`, **tidak** digabung langsung ke teks SQL. Jadi kalau ada orang mengetik `' OR 1=1 --`, MySQL menganggapnya teks biasa yang dicari, bukan perintah SQL. Inilah yang membuat aman dari **SQL injection** (sudah dicoba: hasilnya `[]`).

---

## Latihan 3 – Analisis Error Duplikasi NIM

### Kenapa NIM yang sudah ada memunculkan 409 atau 500?

Di database, kolom `nim` dibuat sebagai **PRIMARY KEY**:

```sql
nim VARCHAR(20) NOT NULL PRIMARY KEY
```

Primary key artinya **tidak boleh ada dua baris dengan nilai yang sama**, mirip nomor KTP: satu nomor hanya untuk satu orang. Jadi kalau kita mengirim `POST` dengan NIM `220101` padahal `220101` sudah ada, MySQL **menolak** perintah `INSERT` dan mengirim error dengan kode `ER_DUP_ENTRY`.

Lalu server Node.js memutuskan mau membalas dengan status apa:

- **409 Conflict:** di `routes/mahasiswa.js` ada pengecekan khusus:
  ```js
  if (err.code === "ER_DUP_ENTRY") {
    return res.status(409).json({ error: `NIM '${nim}' sudah terdaftar di database!` });
  }
  ```
  409 artinya "permintaanmu bentrok dengan data yang sudah ada". Ini status yang paling tepat, karena kesalahannya ada di data yang dikirim, bukan servernya rusak.

- **500 Internal Server Error:** kalau pengecekan `ER_DUP_ENTRY` di atas **tidak ada**, error dari MySQL jatuh ke baris umum:
  ```js
  return res.status(500).json({ error: err.message });
  ```
  500 artinya "ada masalah di server". Statusnya kurang tepat (sebenarnya bukan server yang salah), dan pesannya adalah pesan teknis MySQL seperti `Duplicate entry '220101' for key 'PRIMARY'` yang kurang ramah untuk pengguna. Status 500 juga muncul untuk error lain yang tidak diduga, misalnya MySQL mati atau isi data tidak sesuai kolom.

Jadi: **409 = duplikat yang sudah diantisipasi programmer**, **500 = error yang tidak ditangani secara khusus**.

### Bagaimana Clean Architecture melindungi aplikasi dari crash?

Bayangkan error berjalan naik dari bawah ke atas, dan di setiap lapisan ada "penjaga":

```
MySQL  →  Node.js  →  Remote Data Source  →  Repository  →  Use Case  →  BLoC  →  UI
(tolak)   (409+pesan)  (ubah jadi Exception)   (teruskan)     (teruskan)  (tangkap!)  (tampilkan)
```

1. **Data Source (lapisan Data)** adalah satu-satunya bagian yang mengurus HTTP. Ia memeriksa status code. Kalau bukan 200/201, ia membaca pesan `error` dari JSON lalu melempar `Exception("NIM '220101' sudah terdaftar di database!")`. Error jaringan (server mati, timeout) juga dibungkus jadi `Exception` yang rapi. Lapisan di atasnya **tidak perlu tahu** soal status code, JSON, atau HTTP.
2. **Repository dan Use Case (lapisan Domain)** hanya meneruskan. Use Case bahkan punya penjaga sendiri: IPK di luar 0–4 sudah ditolak **sebelum** data dikirim ke server.
3. **BLoC (lapisan Presentation)** membungkus setiap pemanggilan dengan `try { ... } catch (e) { ... }`. Error apa pun berubah menjadi **state** `MahasiswaError(pesan)`, bukan dibiarkan "meledak". Setelah itu BLoC memuat ulang data, jadi list tidak hilang.
4. **UI** tidak berisi logika error sama sekali. Ia hanya melihat state: kalau `MahasiswaError`, tampilkan SnackBar berisi pesannya.

Hasilnya:
- Aplikasi **tidak crash / layar merah**. Error dianggap sebagai "keadaan" biasa yang ditampilkan ke pengguna.
- Setiap lapisan punya tugas jelas, jadi kalau ada masalah kita tahu harus mencari di mana.
- Karena UI dan BLoC hanya kenal `Exception` dan state, kita bisa mengganti sumber data (lokal ↔ server) di `main.dart` tanpa mengubah cara menangani error.
