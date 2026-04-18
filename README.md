# OPINI KOPI - APLIKASI POS

## OPINICTEAM
## - Moch. Farris Alfiansyah (2409116079)
## - Muhammad Irdhan Nur Faudzan (2409116077)
## - Khairunisa Aprilia (2409116060)
## - Elmy Fadillah (2409116075)

# A. Deskripsi Aplikasi

Aplikasi Opini Kopi merupakan aplikasi berbasis Flutter yang dikembangkan berdasarkan studi kasus dari mitra usaha coffee shop, yaitu Opini Kopi.

Pengembangan aplikasi ini dilatarbelakangi oleh kebutuhan mitra dalam mengelola operasional bisnis yang sebelumnya masih dilakukan secara manual, seperti pencatatan transaksi, pengelolaan produk, serta pemantauan penjualan.

Melalui aplikasi ini, mitra dapat melakukan pengelolaan bisnis secara lebih efektif, terstruktur, dan berbasis data. Selain itu, integrasi dengan backend menggunakan Supabase memungkinkan penyimpanan data secara real-time.

# B. Fitur Aplikasi

## a). Halaman Splash Screen 

### Preview Splash Screen

<img width="1919" height="905" alt="image" src="https://github.com/user-attachments/assets/629f5d43-842b-4d1a-be95-0f3d7bf6f6dd" />

## b). Halaman Login/Masuk

### Preview Halaman Login/Masuk

<img width="1919" height="907" alt="image" src="https://github.com/user-attachments/assets/08e10d2f-2831-435d-8e5a-a2e2c45fac65" />

- Halaman login sebagai akses awal ke sistem.
- Pengguna memasukkan email dan password yang terdaftar.
- Sistem memverifikasi data dan menentukan role (kasir/owner).
- Tersedia fitur show/hide password.
- Pengguna diarahkan ke halaman sesuai peran setelah login.

## c). Halaman Dashboard Owner

### Preview Dashboard Owner

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

- Dashboard menampilkan ringkasan kondisi bisnis secara keseluruhan.
- Menampilkan penjualan dan jumlah transaksi harian.
- Menyediakan informasi produk terlaris.
- Dilengkapi grafik penjualan mingguan untuk melihat tren.
- Menampilkan peak hour dan distribusi pengunjung.
- Membantu pengambilan keputusan operasional dan strategi bisnis.

## d). Halaman Manajemen Menu Owner

### Preview Manajemen Menu Owner

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

- Halaman manajemen menu digunakan untuk mengelola seluruh produk dalam satu tempat.
- Menampilkan informasi produk seperti nama, harga, kategori, dan status.
- Dilengkapi fitur pencarian dan filter kategori.
- Owner dapat menambah, mengedit, dan menghapus produk.
- Setiap produk memiliki gambar untuk identifikasi visual.
- Status produk menunjukkan ketersediaan (aktif/nonaktif).


## e). Halaman Laporan Penjualan Owner

### Preview Laporan Penjualan Owner

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

- Halaman laporan penjualan digunakan untuk memantau performa bisnis berdasarkan periode tertentu (mingguan/bulanan).
- Owner dapat memilih rentang tanggal secara fleksibel untuk melihat data yang diinginkan.
- Menampilkan total penjualan, jumlah order, dan rata-rata transaksi.
- Dilengkapi grafik untuk melihat tren penjualan.
- Menampilkan beberapa top produk beserta jumlah terjual.
- Tersedia fitur ekspor laporan ke PDF dan Excel.
- Menampilkan riwayat transaksi pada bagian bawah.


## f). Halaman Manajemen Stok Owner

### Preview Manajemen Stok Owner

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

- Halaman stok bahan digunakan untuk mengelola ketersediaan bahan baku.
- Menampilkan jumlah stok, satuan, dan status (aman, rendah, habis).
- Dilengkapi indikator stok untuk memantau kondisi bahan.
- Tersedia fitur pencarian untuk memudahkan pencarian bahan.
- Owner dapat menambah, mengedit, dan menghapus data bahan.
- Tersedia fitur ekspor lke Excel.

## g). Halaman Manajemen Pengguna Owner

### Preview Manajemen Pengguna Owner

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

- Halaman manajemen user digunakan untuk mengelola akun pengguna.
- Menampilkan total user, user aktif, dan tidak aktif.
- Menyediakan informasi nama, email, role, dan status akun.
- Dilengkapi fitur pencarian untuk memudahkan pencarian user.
- Owner dapat menambah, mengedit, dan menghapus user.
- Peran dan status menentukan hak akses dan kondisi akun.

## h). Halaman Transaksi Kasir

### Preview Transaksi 

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

- Halaman kasir digunakan untuk melakukan transaksi dengan menu berdasarkan kategori.
- Produk ditampilkan dalam bentuk kartu (gambar, nama, harga) dan dilengkapi fitur pencarian.
- Kasir dapat menambahkan produk ke pesanan dan melihatnya di order summary.
- Sistem menghitung subtotal, pajak, dan total secara otomatis.
- Kasir dapat mengisi nama customer sebelum pembayaran.
- Tersedia fitur keranjang (cart) di tampilan mobile untuk memudahkan melihat pesanan.
- Tombol bayar digunakan untuk menyelesaikan transaksi.


## i). Halaman Pembayaran Kasir

### Preview Pembayaran

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

- Halaman pembayaran digunakan untuk menyelesaikan transaksi.
- Menampilkan ringkasan pesanan (item, jumlah, harga) dan total pembayaran.
- Mendukung metode pembayaran seperti QRIS dan tunai.
- Pada pembayaran tunai, kasir dapat memasukkan jumlah uang dan sistem menghitung kembalian otomatis.
- Tersedia tombol nominal cepat untuk mempermudah input.
- Menampilkan rincian subtotal, pajak, dan total.
- Tombol konfirmasi untuk menyelesaikan transaksi dan tombol batal untuk membatalkan.

## j). Halaman Struk Kasir

### Preview Struk

<img width="1919" height="908" alt="image" src="https://github.com/user-attachments/assets/286d34d6-1a09-4e13-9059-5fb12444b278" />


- Halaman struk ditampilkan sebagai bukti transaksi setelah pembayaran berhasil.
- Menampilkan informasi transaksi seperti tanggal, pelanggan, dan ID pesanan.
- Menampilkan daftar item, jumlah, harga, serta rincian subtotal, pajak, dan total.
- Menampilkan metode pembayaran, uang diterima, dan kembalian.
- Tersedia tombol cetak struk (masih dalam pengembangan).
- Tombol selesai untuk kembali ke halaman kasir.
 
# C. Widget Yang Digunakan
- supabase_flutter: ^2.12.0

Digunakan untuk autentikasi pengguna dan pengelolaan database secara real-time.

- flutter_dotenv: ^5.0.2

Digunakan untuk menyimpan konfigurasi penting seperti API key dan URL secara aman.

- image_picker: ^1.0.4

Digunakan untuk mengambil gambar dari kamera atau galeri perangkat.

- fancy_shimmer_image: ^2.0.3

Digunakan untuk menampilkan gambar dengan efek loading (shimmer) agar tampilan lebih menarik.

- intl: ^0.19.0

Digunakan untuk formatting angka, mata uang, serta tanggal.

- fl_chart: ^1.2.0

Digunakan untuk menampilkan grafik data penjualan seperti bar chart atau line chart.

- syncfusion_flutter_datepicker: ^24.1.41

Digunakan untuk memilih tanggal atau rentang waktu dengan tampilan yang interaktif dan mudah digunakan.

- pdf (^3.11.3)

Digunakan untuk membuat file PDF, seperti struk atau laporan transaksi.

- printing (^5.14.2)

Untuk mencetak file PDF langsung dari aplikasi (print struk).

- excel (^4.0.6)

Digunakan untuk export data ke file Excel (.xlsx), misalnya laporan penjualan.

- path_provider (^2.1.5)

Mengambil lokasi penyimpanan di device (buat simpan PDF / Excel).

- esc_pos_utils_plus (^2.0.4)

Untuk generate format struk thermal printer (printer kasir).

# D. Teknologi Yang Digunakan

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" width="60"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" width="60"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/supabase/supabase-original.svg" width="60"/>
</p>


