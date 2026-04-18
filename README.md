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

<img width="1919" height="905" alt="image" src="https://github.com/user-attachments/assets/629f5d43-842b-4d1a-be95-0f3d7bf6f6dd" />

## b). Halaman Login

<img width="1919" height="907" alt="image" src="https://github.com/user-attachments/assets/08e10d2f-2831-435d-8e5a-a2e2c45fac65" />

- Halaman login sebagai akses awal ke sistem.
- Pengguna memasukkan email dan password yang terdaftar.
- Sistem memverifikasi data dan menentukan role (kasir/owner).
- Tersedia fitur show/hide password.
- Pengguna diarahkan ke halaman sesuai role setelah login.

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


- Halaman dashboard menampilkan ringkasan bisnis secara keseluruhan dalam satu tampilan utama sehingga memudahkan owner dalam memantau kondisi usaha.
- Informasi penjualan hari ini ditampilkan secara langsung untuk memberikan gambaran pendapatan harian secara cepat.
- Jumlah transaksi harian ditampilkan untuk mengetahui aktivitas penjualan yang terjadi dalam satu hari.
- Produk terlaris ditampilkan untuk membantu owner memahami preferensi pelanggan dan produk yang paling diminati.
- Grafik penjualan mingguan disajikan dalam bentuk visual untuk mempermudah analisis tren penjualan dari waktu ke waktu.
- Informasi jam ramai (peak hour) ditampilkan untuk mengetahui waktu dengan jumlah pengunjung tertinggi.
- Distribusi pengunjung berdasarkan waktu membantu owner dalam mengatur strategi operasional, seperti penjadwalan karyawan atau persiapan stok.

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

- Halaman manajemen menu digunakan untuk mengelola seluruh daftar produk yang dijual oleh mitra dalam satu tampilan terpusat.
- Owner dapat melihat informasi produk secara lengkap seperti nama produk, harga, kategori, dan status.
- Fitur pencarian produk memudahkan owner dalam menemukan menu tertentu secara cepat.
- Fitur filter kategori memungkinkan penyaringan produk berdasarkan jenis tertentu, seperti coffee atau non-coffee.
- Owner dapat menambahkan produk baru melalui tombol tambah menu yang tersedia pada bagian atas halaman.
- Setiap produk dilengkapi dengan gambar untuk membantu identifikasi visual yang lebih jelas.
- Tersedia aksi edit untuk memperbarui informasi produk yang sudah ada.
- Tersedia aksi hapus untuk menghapus produk dari sistem jika sudah tidak digunakan.
- Status produk ditampilkan untuk menunjukkan apakah produk sedang aktif atau tidak tersedia.

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
- Tersedia fitur export laporan ke PDF dan Excel.
- Menampilkan riwayat transaksi pada bagian bawah.


## f). Halaman Manajemen Stok Owner

<img width="1919" height="907" alt="image" src="https://github.com/user-attachments/assets/b327dd50-c52b-40b2-9e67-6c8660b29731" />

- Halaman stok bahan digunakan untuk mengelola ketersediaan bahan baku yang digunakan dalam operasional coffee shop.
- Owner dapat melihat jumlah total bahan yang tersedia dalam sistem sebagai gambaran keseluruhan inventaris.
- Informasi tingkat stok optimal ditampilkan untuk menunjukkan jumlah bahan yang masih dalam kondisi aman.
- Indikator stok rendah membantu owner dalam mengidentifikasi bahan yang perlu segera ditambah.
- Indikator stok habis memberikan peringatan jika terdapat bahan yang sudah tidak tersedia.
- Fitur pencarian bahan memudahkan owner dalam menemukan bahan tertentu secara cepat.
- Owner dapat menambahkan data bahan baru melalui tombol tambah bahan.
- Setiap bahan ditampilkan dengan informasi nama, jumlah stok yang tersedia, serta satuan yang digunakan.
- Status bahan ditampilkan untuk menunjukkan kondisi stok, seperti aman, rendah, atau habis.
- Tersedia aksi edit untuk memperbarui data bahan sesuai kondisi terbaru.
- Tersedia aksi hapus untuk menghapus data bahan yang tidak digunakan.

## g). Halaman Manajemen User Owner

<img width="1919" height="917" alt="Screenshot 2026-04-14 191643" src="https://github.com/user-attachments/assets/aea7c964-3f31-4da7-b065-b79e94839722" />

- Halaman manajemen user digunakan untuk mengelola akun pengguna yang terlibat dalam operasional coffee shop.
- Owner dapat melihat jumlah total user yang terdaftar dalam sistem.
- Informasi jumlah user aktif ditampilkan untuk mengetahui pengguna yang masih dapat mengakses sistem.
- Informasi user tidak aktif membantu dalam memantau akun yang sudah tidak digunakan.
- Owner dapat melihat detail data user seperti nama, email, peran (role), dan status akun.
- Setiap user memiliki role yang membedakan hak akses, seperti kasir atau owner.
- Fitur pencarian user memudahkan dalam menemukan akun tertentu dengan cepat.
- Owner dapat menambahkan user baru melalui tombol tambah user.
- Tersedia aksi edit untuk memperbarui informasi user.
- Tersedia aksi hapus untuk menghapus user dari sistem.
- Status user ditampilkan untuk menunjukkan apakah akun sedang aktif atau tidak.

## h). Halaman Order Kasir

<img width="1919" height="905" alt="image" src="https://github.com/user-attachments/assets/2313147a-2de1-4cae-86f6-74ae3d4b2a13" />

- Halaman kasir digunakan untuk melakukan transaksi penjualan secara langsung dengan tampilan menu yang terstruktur berdasarkan kategori.
- Kasir dapat memilih kategori produk seperti coffee, non-coffee, dan snack untuk mempermudah pencarian menu.
- Setiap produk ditampilkan dalam bentuk kartu yang berisi gambar, nama, dan harga untuk memudahkan identifikasi.
- Fitur pencarian menu memungkinkan kasir menemukan produk dengan cepat.
- Kasir dapat menambahkan produk ke dalam pesanan dengan memilih item yang diinginkan.
- Bagian order summary menampilkan daftar pesanan yang telah dipilih oleh kasir.
- Kasir dapat memasukkan nama customer untuk keperluan pencatatan transaksi.
- Sistem secara otomatis menghitung subtotal, pajak, dan total pembayaran.
- Tombol bayar digunakan untuk menyelesaikan proses transaksi setelah pesanan dikonfirmasi.

## i). Halaman Pembayaran Kasir

<img width="1919" height="904" alt="image" src="https://github.com/user-attachments/assets/29b5db88-ce18-4f96-b3bb-dcd7170e82de" />

- Halaman pembayaran digunakan untuk menyelesaikan transaksi setelah pesanan dipilih.
- Sistem menampilkan ringkasan pesanan yang berisi daftar item, jumlah, dan harga masing-masing produk.
- Total pembayaran ditampilkan secara jelas sebagai jumlah yang harus dibayarkan oleh customer.
- Kasir dapat memilih metode pembayaran yang tersedia, seperti QRIS atau tunai.
- Pada pembayaran tunai, kasir dapat memasukkan jumlah uang yang diterima dari customer.
- Sistem secara otomatis menghitung jumlah kembalian berdasarkan uang yang diberikan.
- Tersedia tombol nominal cepat untuk mempermudah input jumlah uang tanpa mengetik manual.
- Informasi subtotal, pajak, dan total tetap ditampilkan sebagai rincian transaksi.
- Tombol konfirmasi pembayaran digunakan untuk menyelesaikan transaksi dan menyimpan data ke sistem.
- Tombol batal disediakan untuk membatalkan proses pembayaran jika diperlukan.

## j). Halaman Struk Kasri

<img width="1917" height="909" alt="image" src="https://github.com/user-attachments/assets/5fc4e37f-7ad9-4ec4-8543-ef75b07f71dc" />

- Halaman struk ditampilkan setelah transaksi berhasil dilakukan sebagai bukti pembayaran.
- Sistem menampilkan status transaksi berhasil untuk memastikan pembayaran telah diproses.
- Informasi transaksi ditampilkan secara lengkap, seperti tanggal, nama customer, dan ID pesanan.
- Daftar item yang dibeli ditampilkan beserta jumlah dan harga masing-masing produk.
- Rincian pembayaran mencakup subtotal, pajak, dan total pembayaran.
- Metode pembayaran yang digunakan serta jumlah uang yang diterima ditampilkan pada bagian bawah.
- Sistem juga menampilkan jumlah kembalian yang diberikan kepada customer.
- Tersedia tombol cetak struk yang dirancang untuk mencetak bukti transaksi.
- Fitur cetak struk saat ini masih dalam tahap pengembangan dan belum dapat digunakan.
- Tombol selesai digunakan untuk mengakhiri transaksi dan kembali ke halaman kasir.
 
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

<p align="left">
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/supabase/supabase-original.svg" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/android/android-original.svg" width="50" height="50"/>
</p>

