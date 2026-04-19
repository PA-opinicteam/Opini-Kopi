# OPINI KOPI - APLIKASI OPINI POS
## Anggota Tim - Opinicteam
| Nama                        |     NIM    |
| :-------------------------- | :--------: |
| Moch. Farris Alfiansyah     | 2409116079 |
| Muhammad Irdhan Nur Faudzan | 2409116077 |
| Khairunisa Aprilia          | 2409116060 |
| Elmy Fadillah               | 2409116075 |

---

# A. Deskripsi Aplikasi

Aplikasi Opini POS merupakan aplikasi berbasis Flutter yang dikembangkan berdasarkan studi kasus dari mitra usaha coffee shop, yaitu Opini Kopi.

Pengembangan aplikasi ini dilatarbelakangi oleh kebutuhan mitra dalam mengelola operasional bisnis yang sebelumnya masih dilakukan secara manual, seperti pencatatan transaksi, pengelolaan produk, serta pemantauan penjualan.

Melalui aplikasi ini, mitra dapat melakukan pengelolaan bisnis secara lebih efektif, terstruktur, dan berbasis data. Selain itu, integrasi dengan backend menggunakan Supabase memungkinkan penyimpanan data secara real-time.

---
# B. Fitur Aplikasi
Aplikasi ini dirancang untuk membantu operasional coffee shop secara digital, mulai dari pengelolaan menu, transaksi kasir, hingga laporan penjualan dalam satu sistem terintegrasi.

## a. Login

Halaman **Login** digunakan sebagai akses awal ke sistem untuk mengautentikasi pengguna.

* Input email & password
* Validasi data user
* Role otomatis (Owner / Kasir)
* Show / hide password
* Redirect sesuai peran

## b. Dashboard

Halaman **Dashboard** digunakan untuk menampilkan ringkasan kondisi bisnis secara keseluruhan.

* Ringkasan penjualan
* Jumlah transaksi
* Produk terlaris
* Grafik penjualan
* Analisis jam ramai

## c. Manajemen Menu

Halaman **Manajemen Menu** digunakan untuk mengelola seluruh daftar produk dalam satu tampilan terpusat.

* Lihat daftar produk
* Tambah menu
* Edit data produk
* Hapus menu
* Pencarian & filter
* Status produk

## d. Laporan Penjualan

Halaman **Laporan Penjualan** digunakan untuk memantau performa bisnis berdasarkan periode tertentu.

* Filter tanggal
* Pilih periode
* Total penjualan & transaksi
* Rata-rata pesanan
* Grafik penjualan
* Produk terlaris
* Riwayat order
* Export PDF & Excel

## e. Manajemen Stok

Halaman **Manajemen Stok** digunakan untuk mengelola ketersediaan bahan baku.

* Ringkasan stok
* Tambah bahan
* Edit data
* Hapus bahan
* Pencarian
* Status stok
* Export data

## f. Manajemen Pengguna

Halaman **Manajemen Pengguna** digunakan untuk mengatur data dan hak akses pengguna.

* Lihat user
* Tambah user
* Edit data
* Hapus user
* Role (Owner/Kasir)
* Status user
* Pencarian

## g. Transaksi Kasir

Halaman **Kasir** digunakan untuk melakukan transaksi penjualan secara langsung.

* Pilih kategori
* Cari produk
* Tambah ke pesanan
* Atur jumlah & tambahan
* Input nama pelanggan
* Hitung total otomatis
* Edit / hapus item
* Reset pesanan

## h. Pembayaran

Halaman **Pembayaran** digunakan untuk menyelesaikan proses transaksi.

* Ringkasan pesanan
* Metode pembayaran
* Input nominal
* Hitung kembalian
* Konfirmasi transaksi

## i. Struk

Halaman **Struk** digunakan untuk menampilkan bukti transaksi.

* Status transaksi
* Detail pesanan
* Rincian pembayaran
* Metode pembayaran
* Cetak struk

  
---
 
# C. Widget Yang Digunakan
# Daftar Widget yang Digunakan

Aplikasi **Opini POS** menggunakan berbagai widget Flutter untuk membangun tampilan kasir, dashboard owner, form input, popup dialog, navigasi, dan visualisasi data. Berikut daftar widget yang digunakan beserta penjelasan singkatnya.

## 1. Root Widget
| Nama Widget     | Deskripsi                                                                                                                        |
| :-------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| MaterialApp     | Digunakan sebagai pembungkus utama aplikasi Flutter yang mengatur struktur dasar seperti tema, halaman awal, dan navigasi.       |
| StatelessWidget | Digunakan untuk widget yang tampilannya tidak berubah selama dijalankan, misalnya sidebar atau komponen kecil.                   |
| StatefulWidget  | Digunakan untuk widget yang memiliki state atau data yang bisa berubah, misalnya halaman login, halaman kasir, dan dialog input. |


## 2. Struktur dan Layout
| Nama Widget    | Deskripsi                                                                                          |
| :------------- | -------------------------------------------------------------------------------------------------- |
| Scaffold       | Kerangka utama halaman Flutter, biasanya berisi AppBar, body, dan bottomNavigationBar.             |
| SafeArea       | Digunakan agar tampilan tidak tertutup oleh notch, status bar, atau bagian sistem pada perangkat.  |
| Container      | Widget serbaguna untuk membungkus elemen UI, memberi warna, ukuran, padding, margin, dan dekorasi. |
| SizedBox       | Digunakan untuk memberi jarak atau menentukan ukuran tetap pada widget.                            |
| Padding        | Memberi ruang di sekeliling widget agar tampilan lebih rapi.                                       |
| Expanded       | Membuat widget mengisi sisa ruang yang tersedia di dalam Row atau Column.                          |
| Spacer         | Digunakan untuk memberi jarak fleksibel antar widget di dalam Row atau Column.                     |
| ConstrainedBox | Memberi batas ukuran minimum atau maksimum pada widget.                                            |
| LayoutBuilder  | Digunakan untuk membuat tampilan responsif berdasarkan ukuran area yang tersedia.                  |


## 3. Susunan Posisi
| Nama Widget | Deskripsi                                                                                   |
| :---------- | ------------------------------------------------------------------------------------------- |
| Column      | Menyusun widget secara vertikal dari atas ke bawah.                                         |
| Row         | Menyusun widget secara horizontal dari kiri ke kanan.                                       |
| Wrap        | Menyusun widget seperti Row, tetapi bisa pindah ke baris berikutnya jika ruang tidak cukup. |
| Stack       | Menumpuk beberapa widget di area yang sama.                                                 |
| Positioned  | Digunakan di dalam Stack untuk menentukan posisi widget secara spesifik.                    |
| Center      | Menempatkan widget tepat di tengah area yang tersedia.                                      |


## 4. Teks dan Ikon
| Nama Widget  | Deskripsi                                                                        |
| :----------- | -------------------------------------------------------------------------------- |
| Text         | Menampilkan teks pada layar, seperti judul, label, deskripsi, dan isi informasi. |
| Icon         | Menampilkan ikon bawaan Flutter, misalnya ikon kopi, logout, edit, dan hapus.    |
| CircleAvatar | Menampilkan avatar berbentuk lingkaran, misalnya ikon pengguna atau logo kecil.  |


## 5. Gambar
| Nama Widget       | Deskripsi                                                                                |
| :---------------- | ---------------------------------------------------------------------------------------- |
| Image.asset       | Menampilkan gambar dari folder assets project, misalnya logo aplikasi.                   |
| Image.network     | Menampilkan gambar dari URL internet.                                                    |
| Image.memory      | Menampilkan gambar dari data bytes, biasanya dipakai setelah memilih gambar dari galeri. |
| FancyShimmerImage | Widget untuk menampilkan gambar dengan efek loading shimmer agar tampilan lebih menarik. |


## 6. Tombol dan Interaksi
| Nama Widget     | Deskripsi                                                                                                         |
| :-------------- | ----------------------------------------------------------------------------------------------------------------- |
| ElevatedButton  | Tombol utama dengan background berwarna, biasanya digunakan untuk aksi penting seperti simpan, login, atau bayar. |
| OutlinedButton  | Tombol dengan garis tepi, biasanya untuk aksi sekunder seperti batal atau export.                                 |
| TextButton      | Tombol berbentuk teks tanpa background besar, biasanya dipakai untuk aksi ringan.                                 |
| FilledButton    | Tombol modern Flutter dengan tampilan terisi warna.                                                               |
| IconButton      | Tombol yang hanya berisi ikon, misalnya tombol close atau show/hide password.                                     |
| GestureDetector | Mendeteksi interaksi seperti tap pada widget custom.                                                              |
| InkWell         | Widget interaktif dengan efek sentuh ripple, biasanya dipakai pada item menu.                                     |


## 7. Input Pengguna
| Nama Widget             | Deskripsi                                                                                       |
| :---------------------- | ----------------------------------------------------------------------------------------------- |
| TextField               | Digunakan untuk input teks sederhana, misalnya pencarian atau catatan.                          |
| TextFormField           | Digunakan untuk input yang membutuhkan validasi, seperti email, password, nama menu, dan harga. |
| Form                    | Membungkus beberapa field input agar bisa divalidasi secara bersamaan.                          |
| DropdownButton          | Menampilkan pilihan dropdown sederhana.                                                         |
| DropdownButtonFormField | Versi dropdown yang terintegrasi dengan Form dan bisa divalidasi.                               |
| Radio                   | Digunakan untuk memilih satu opsi dari beberapa pilihan.                                        |
| Checkbox                | Digunakan untuk memilih addon atau tambahan pada menu.                                          |


## 8. List dan Scroll
| Nama Widget           | Deskripsi                                                           |
| :-------------------- | ------------------------------------------------------------------- |
| ListView              | Menampilkan daftar item yang bisa discroll.                         |
| ListView.builder      | Digunakan untuk membuat daftar secara dinamis dari data.            |
| ListView.separated    | Sama seperti ListView, tetapi dengan pemisah antar item.            |
| GridView.builder      | Menampilkan data dalam bentuk grid, misalnya daftar menu kasir.     |
| SingleChildScrollView | Membuat satu area dapat discroll jika isi lebih panjang dari layar. |

## 9. Navigasi
| Nama Widget       | Deskripsi                                                              |
| :---------------- | ---------------------------------------------------------------------- |
| Navigator         | Digunakan untuk berpindah halaman di dalam aplikasi.                   |
| MaterialPageRoute | Membuat transisi ke halaman baru dengan gaya navigasi material design. |

## 10. Feedback ke Pengguna
| Nama Widget               | Deskripsi                                                                                                  |
| :------------------------ | ---------------------------------------------------------------------------------------------------------- |
| SnackBar                  | Menampilkan pesan singkat di bagian bawah layar, misalnya saat data berhasil disimpan atau gagal diproses. |
| ScaffoldMessenger         | Digunakan untuk menampilkan SnackBar.                                                                      |
| CircularProgressIndicator | Menampilkan indikator loading saat proses sedang berjalan.                                                 |

## 11. Dialog dan Popup
| Nama Widget | Deskripsi                                                                                |
| :---------- | ---------------------------------------------------------------------------------------- |
| Dialog      | Digunakan untuk menampilkan popup seperti tambah data, edit data, atau konfirmasi hapus. |


## 12. Dekorasi dan Styling
| Nama Widget            | Deskripsi                                                                       |
| :--------------------- | ------------------------------------------------------------------------------- |
| BoxDecoration          | Digunakan untuk memberi warna, border, shadow, atau radius pada Container.      |
| Border                 | Menambahkan garis tepi pada widget.                                             |
| OutlineInputBorder     | Border khusus untuk field input.                                                |
| RoundedRectangleBorder | Membuat sudut melengkung pada tombol, dialog, atau snackbar.                    |
| LinearGradient         | Membuat background gradasi warna.                                               |
| ClipRRect              | Memotong tampilan widget dengan sudut melengkung, biasanya dipakai pada gambar. |
| Divider                | Membuat garis pemisah antar bagian tampilan.                                    |


## 13. Navigasi Modern
| Nama Widget           | Deskripsi                                                      |
| :-------------------- | -------------------------------------------------------------- |
| NavigationBar         | Digunakan sebagai navigasi bawah modern untuk tampilan mobile. |
| NavigationDestination | Item tujuan (menu) yang terdapat di dalam NavigationBar.       |


## 14. Data dan Async
| Nama Widget   | Deskripsi                                                                                    |
| :------------ | -------------------------------------------------------------------------------------------- |
| FutureBuilder | Digunakan untuk menampilkan data hasil proses asynchronous, misalnya dari database Supabase. |


## 15. Theme dan Media
| Nama Widget  | Deskripsi                                                                     |
| :------------| ----------------------------------------------------------------------------- |
| Theme        | Digunakan untuk mengatur tampilan tema pada bagian tertentu, misalnya dialog. |
| MediaQuery   | Digunakan untuk mengetahui ukuran layar agar tampilan bisa responsif.         |


## 16. Widget Package Tambahan
| Nama Widget         | Deskripsi                                                                                          |
| :-------------------| -------------------------------------------------------------------------------------------------- |
| LineChart           | Widget yang digunakan untuk menampilkan grafik penjualan dalam bentuk line chart.                  |
| FlSpot              | Struktur data yang digunakan untuk merepresentasikan titik (x, y) pada grafik.                     |
| SfDateRangePicker   | Widget untuk memilih tanggal atau rentang tanggal pada halaman laporan dengan tampilan interaktif. |


# D. Package Yang Digunakan

Berikut adalah beberapa package yang digunakan dalam pengembangan aplikasi:

| Nama Package                  |   Versi  | Deskripsi                                                                                               |
| :---------------------------- | :------: | ------------------------------------------------------------------------------------------------------- |
| supabase_flutter              |  ^2.12.0 | Digunakan untuk autentikasi pengguna dan pengelolaan database secara real-time menggunakan Supabase.    |
| flutter_dotenv                |  ^5.0.2  | Digunakan untuk menyimpan konfigurasi penting seperti API key dan URL secara aman melalui file .env.    |
| image_picker                  |  ^1.0.4  | Digunakan untuk mengambil gambar dari kamera atau galeri perangkat.                                     |
| fancy_shimmer_image           |  ^2.0.3  | Digunakan untuk menampilkan gambar dengan efek loading (shimmer) agar tampilan lebih menarik.           |
| intl                          |  ^0.19.0 | Digunakan untuk formatting angka, mata uang, serta tanggal sesuai locale.                               |
| fl_chart                      |  ^1.2.0  | Digunakan untuk menampilkan grafik data seperti penjualan dalam bentuk line chart atau bar chart.       |
| syncfusion_flutter_datepicker | ^24.1.41 | Digunakan untuk memilih tanggal atau rentang waktu dengan tampilan yang interaktif dan mudah digunakan. |
| pdf                           |  ^3.11.3 | Digunakan untuk membuat file PDF, seperti struk atau laporan transaksi.                                 |
| printing                      |  ^5.14.2 | Digunakan untuk mencetak file PDF langsung dari aplikasi (print struk).                                 |
| excel                         |  ^4.0.6  | Digunakan untuk export data ke file Excel (.xlsx), misalnya laporan penjualan.                          |
| path_provider                 |  ^2.1.5  | Digunakan untuk mengambil lokasi penyimpanan di device (untuk menyimpan PDF / Excel).                   |
| esc_pos_utils_plus            |  ^2.0.4  | Digunakan untuk generate format struk thermal printer (printer kasir).                                  |

---
# D. Teknologi Yang Digunakan

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" width="60"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" width="60"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/supabase/supabase-original.svg" width="60"/>
</p> 

---
# E. Cara Install Aplikasi

Ikuti langkah berikut untuk menginstall aplikasi di perangkat Android:

1. Download APK di bawah

[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://github.com/PA-opinicteam/Opini-Kopi/releases/download/v0.1.0/app-release.apk)
   
2. Buka file APK di perangkat.
  
3. Aktifkan izin **Install dari sumber tidak dikenal** jika diminta.
   
4. Klik **Install** dan tunggu hingga selesai.

5. Aplikasi siap digunakan.


# F. Preview Aplikasi 
<p align="center">
  <img src="https://github.com/user-attachments/assets/629f5d43-842b-4d1a-be95-0f3d7bf6f6dd" width="800"/>
</p>
<p align="center">
  <em>Halaman Splash</em>
</p>

---

<p align="center">
  <img src="https://github.com/user-attachments/assets/08e10d2f-2831-435d-8e5a-a2e2c45fac65" width="800"/>
</p>
<p align="center">
  <em>Halaman Login</em>
</p>

---

<table align="center">
  <tr>
    <td align="center">
      <img width="1919" height="910" alt="image" src="https://github.com/user-attachments/assets/73b02b44-b285-4052-94d8-d7f0d01d0d8e" />
      <br/>
      <sub><b>Desktop View</b></sub>
    </td>
    <td align="center">
      <img width="621" height="906" alt="image" src="https://github.com/user-attachments/assets/c3316228-b502-457e-b9f8-ea39659ed2af" />
      <br/>
      <sub><b>Mobile View</b></sub>
    </td>
  </tr>
</table>
<p align="center">
  <em>Halaman Dashboard Owner</em>
</p>

---

<table align="center">
  <tr>
    <td align="center">
      <img width="1919" height="906" alt="image" src="https://github.com/user-attachments/assets/d0f0b0fd-c892-4770-a031-83422c35157e" />
       <br/>
      <sub><b>Desktop View</b></sub>
    </td>
    <td align="center">
      <img width="616" height="903" alt="image" src="https://github.com/user-attachments/assets/66f6cfba-cb13-4158-85c7-22e9722e5444" />
      <sub><b>Mobile View</b></sub>
    </td>
  </tr>
</table>
<p align="center">
  <em>Halaman Manajemen Menu Owner</em>
</p>

---

<table align="center">
  <tr>
    <td align="center">
      <img width="1919" height="914" alt="image" src="https://github.com/user-attachments/assets/28e2cd93-d68d-4033-980f-75a65d73c341" />
       <br/>
      <sub><b>Desktop View</b></sub>
    </td>
    <td align="center">
      <img width="619" height="906" alt="image" src="https://github.com/user-attachments/assets/9dc44021-29c5-4c7a-8319-2b5ded63b55a" />
      <sub><b>Mobile View</b></sub>
    </td>
  </tr>
</table>
<p align="center">
  <em>Halaman Laporan Penjualan Owner</em>
</p>

---

<table align="center">
  <tr>
    <td align="center">
      <img width="1919" height="900" alt="image" src="https://github.com/user-attachments/assets/b2f0b0fc-2ea5-4965-9b4d-31d9d6016895" />
       <br/>
      <sub><b>Desktop View</b></sub>
    </td>
    <td align="center">
      <img width="619" height="910" alt="image" src="https://github.com/user-attachments/assets/2b878d73-6f9f-4a84-9934-a8e39a744d25" />
      <sub><b>Mobile View</b></sub>
    </td>
  </tr>
</table>
<p align="center">
  <em>Halaman Manajemen Stok Owner</em>
</p>

---

<table align="center">
  <tr>
    <td align="center">
      <img width="1909" height="898" alt="image" src="https://github.com/user-attachments/assets/db50824a-63f1-4340-a50a-8aaf65b1171c" />
       <br/>
      <sub><b>Desktop View</b></sub>
    </td>
    <td align="center">
      <img width="619" height="905" alt="image" src="https://github.com/user-attachments/assets/ac6a48d9-d3e4-437d-bc37-24af87b8540b" />
      <sub><b>Mobile View</b></sub>
    </td>
  </tr>
</table>
<p align="center">
  <em>Halaman Manajemen Pengguna Owner</em>
</p>

---

<table align="center">
  <tr>
    <td align="center">
      <img width="1916" height="898" alt="image" src="https://github.com/user-attachments/assets/9e5e39f0-690e-4a88-81d9-a5c05d6a9ff3" />
       <br/>
      <sub><b>Desktop View</b></sub>
    </td>
    <td align="center">
      <img width="618" height="908" alt="image" src="https://github.com/user-attachments/assets/fe505a45-888e-4f44-97f2-a9086550e433" />
      <sub><b>Mobile View</b></sub>
    </td>
  </tr>
</table>
<p align="center">
  <em>Halaman Transaksi Kasir</em>
</p>

---

<table align="center">
  <tr>
    <td align="center">
      <img width="1919" height="905" alt="image" src="https://github.com/user-attachments/assets/90451112-c859-4909-be6b-55b47bb10e68" />
       <br/>
      <sub><b>Desktop View</b></sub>
    </td>
    <td align="center">
      <img width="622" height="905" alt="image" src="https://github.com/user-attachments/assets/2ea5da1c-0e98-4f35-b7fd-b9e4cbb4ef64" />
      <sub><b>Mobile View</b></sub>
    </td>
  </tr>
</table>
<p align="center">
  <em>Halaman Pembayaran Kasir</em>
</p>

---

<p align="center">
  <img src="https://github.com/user-attachments/assets/286d34d6-1a09-4e13-9059-5fb12444b278"/>
</p>
<p align="center">
  <em>Halaman Struk Kasir</em>
</p>

