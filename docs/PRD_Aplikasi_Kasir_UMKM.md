# PRD - Aplikasi Kasir Digital untuk UMKM
**"KasirKu"** *(nama sementara, bebas diganti)*

| | |
|---|---|
| **Versi** | 1.0 |
| **Tanggal** | 13 Agustus 2026 |
| **Author** | Iqbal |
| **Status** | Draft |

---

## 1. Latar Belakang & Masalah

Banyak UMKM dan warung kecil di Indonesia masih mencatat transaksi secara manual (buku tulis/kalkulator), yang menyebabkan:

- Sulit melacak stok barang secara real-time
- Tidak ada laporan keuangan otomatis (laba/rugi tidak jelas)
- Rawan human error saat hitung kembalian atau catat penjualan
- Tidak ada data histori penjualan untuk pengambilan keputusan bisnis
- Owner tidak bisa memantau tokonya saat sedang tidak di lokasi

**Peluang:** UMKM di Indonesia jumlahnya sangat besar, dan digitalisasi UMKM masih rendah — terutama di segmen warung, toko kelontong, kedai kopi, dan usaha rumahan skala kecil-menengah yang belum mampu/mau bayar POS enterprise (mis. Moka, Pawoon) yang harganya relatif mahal untuk skala mereka.

---

## 2. Tujuan Produk

1. Menyediakan aplikasi kasir yang **simpel, cepat dipelajari (< 10 menit)**, dan terjangkau untuk UMKM skala kecil-menengah
2. Digitalisasi pencatatan transaksi, stok, dan laporan keuangan secara otomatis
3. Memungkinkan owner memantau bisnisnya dari mana saja (real-time)
4. Menjadi produk yang bisa dijual/disewakan ke UMKM lokal (model bisnis: freemium atau langganan bulanan)

---

## 3. Target Pengguna

| Peran | Deskripsi |
|---|---|
| **Owner/Admin** | Pemilik usaha — kelola produk, stok, laporan, dan karyawan |
| **Kasir (Staff)** | Karyawan yang input transaksi penjualan sehari-hari |

**Target pasar awal:** warung, toko kelontong, kedai kopi/jajanan, toko sembako skala kecil-menengah (1-3 cabang).

---

## 4. Ruang Lingkup (Scope)

### 4.1 In-Scope (MVP)
- Manajemen produk & kategori
- Transaksi penjualan (kasir)
- Manajemen stok otomatis (berkurang saat transaksi)
- Laporan penjualan harian/mingguan/bulanan
- Multi-user (owner & kasir) dengan role-based access
- Riwayat transaksi
- Cetak/kirim struk digital (PDF/gambar via WhatsApp)

### 4.2 Out-of-Scope (Fase Berikutnya)
- Integrasi payment gateway (QRIS otomatis, cashless)
- Multi-cabang/multi-toko dalam satu akun
- Manajemen supplier & purchase order
- Sistem member/loyalty pelanggan
- Integrasi marketplace (Shopee, Tokopedia)

---

## 5. Fitur Utama (MVP)

### 5.1 Autentikasi & Role
- Login owner (email/password via Firebase Auth)
- Owner bisa invite/tambah akun kasir
- Role: **Owner** (akses penuh) vs **Kasir** (hanya transaksi & lihat stok)

### 5.2 Manajemen Produk
- Tambah/edit/hapus produk (nama, harga, kategori, foto, stok awal)
- Kategori produk (custom per toko)
- Notifikasi stok menipis (threshold bisa diatur)

### 5.3 Transaksi Kasir (POS)
- Pilih produk → keranjang → hitung total otomatis
- Input jumlah uang diterima → hitung kembalian otomatis
- Metode bayar: Tunai / Transfer / QRIS manual (tanpa gateway dulu)
- Simpan transaksi ke histori
- Generate struk (bisa di-share ke WhatsApp/print via bluetooth printer — opsional fase 2)

### 5.4 Manajemen Stok
- Stok otomatis berkurang saat transaksi tersimpan
- Fitur restock manual (tambah stok)
- Riwayat pergerakan stok (masuk/keluar)

### 5.5 Laporan & Dashboard
- Dashboard ringkasan: total penjualan hari ini, produk terlaris, grafik mingguan
- Laporan laba rugi sederhana (harga jual - harga modal)
- Export laporan (PDF/Excel) — bisa fase 2
- Filter laporan by tanggal/rentang waktu

### 5.6 Pengaturan Toko
- Profil toko (nama, alamat, logo)
- Manajemen kasir/karyawan
- Pengaturan mata uang & pajak (opsional)

---

## 6. User Flow Utama

```
[Kasir Login] 
   → Dashboard Kasir 
   → Pilih Produk (tap/search) 
   → Keranjang → Input Nominal Bayar 
   → Konfirmasi → Struk Digital → Selesai

[Owner Login] 
   → Dashboard Bisnis 
   → Kelola Produk / Lihat Laporan / Kelola Kasir 
   → Export/Analisa
```

---

## 7. Tech Stack (disesuaikan dengan yang lo kuasai)

| Layer | Teknologi |
|---|---|
| **Frontend** | Flutter (Android prioritas, iOS opsional) |
| **State Management** | Provider |
| **Backend** | Firebase Firestore (database), Firebase Auth |
| **Storage** | Firebase Storage (foto produk, logo toko) |
| **Notifikasi** | Firebase Cloud Messaging (stok menipis, dll) |
| **Struk Digital** | Package `pdf` / `screenshot` Flutter + share ke WhatsApp |
| **Hosting Admin Web (opsional)** | Firebase Hosting, kalau mau ada versi web dashboard buat owner |

> Stack ini sengaja disamakan dengan project padel booking lo — jadi banyak reusable knowledge (struktur Firestore, auth flow, Provider pattern).

---

## 8. Struktur Data (Firestore) — Draft

```
/toko/{tokoId}
  - nama, alamat, logoUrl, ownerId

/toko/{tokoId}/produk/{produkId}
  - nama, kategori, hargaJual, hargaModal, stok, fotoUrl, thresholdStokMinim

/toko/{tokoId}/transaksi/{transaksiId}
  - items: [{produkId, nama, qty, hargaSatuan}]
  - total, metodeBayar, uangDiterima, kembalian
  - kasirId, timestamp

/toko/{tokoId}/karyawan/{userId}
  - nama, role (owner/kasir), email
```

---

## 9. Desain UI/UX (Arahan Umum)

- **Gaya:** Clean, minimalis, mirip aplikasi kasir modern (POS-style grid produk dengan foto)
- **Warna:** Bebas ditentukan sesuai branding — bisa pakai palet hijau/teal seperti project sebelumnya, atau warna netral (biru/oranye) yang umum dipakai aplikasi finansial
- **Navigasi kasir:** Harus **super cepat** — minim tap untuk transaksi (target: transaksi selesai < 5 tap)
- **Dashboard owner:** Grafik sederhana (bar/line chart) pakai package `fl_chart`
- Mobile-first, karena kasir biasanya pakai HP/tablet murah

---

## 10. Metrik Keberhasilan (Success Metrics)

- Waktu rata-rata 1 transaksi < 30 detik
- Owner bisa lihat laporan harian tanpa hitung manual
- Zero data loss (semua transaksi tersimpan real-time ke cloud)
- Tingkat adopsi: minimal 1-3 UMKM lokal pakai sebagai pilot/testimoni

---

## 11. Model Monetisasi (kalau mau dijual)

| Model | Deskripsi |
|---|---|
| **Freemium** | Gratis untuk 1 toko/produk terbatas, upgrade untuk fitur lengkap |
| **Langganan Bulanan** | Rp15.000 - Rp50.000/bulan per toko (sesuaikan riset pasar lokal) |
| **Jasa Setup + Custom** | Jual sebagai jasa instalasi + custom branding ke UMKM sekitar |

---

## 12. Roadmap Fase Pengembangan

| Fase | Fitur |
|---|---|
| **Fase 1 (MVP)** | Auth, Produk, Transaksi Kasir, Stok Dasar |
| **Fase 2** | Laporan & Dashboard, Export PDF, Notifikasi Stok |
| **Fase 3** | Multi-cabang, QRIS integration, Struk print bluetooth |
| **Fase 4** | Loyalty member, Integrasi marketplace |

---

## 13. Risiko & Pertimbangan

- **Koneksi internet:** Warung kecil kadang sinyal lemah → pertimbangkan offline-first (Firestore offline persistence sudah built-in, bisa dimanfaatkan)
- **Kompetitor:** Sudah ada Moka POS, Pawoon, Qasir — diferensiasi lo harus di kesederhanaan + harga + servis personal ke UMKM lokal
- **Validasi pasar:** Sebelum full build, coba tawarkan konsep ke 2-3 pemilik warung terdekat untuk validasi fitur mana yang paling mereka butuhkan

---

## 14. Next Steps

1. Validasi ide ke calon user (pemilik warung/UMKM) — cukup ngobrol santai, tanya pain point mereka
2. Bikin wireframe/mockup sederhana (Figma atau langsung ke Flutter)
3. Breakdown PRD ini jadi vibe coding prompt sequence (seperti padel booking app) untuk development bertahap
4. Setup Firebase project baru
