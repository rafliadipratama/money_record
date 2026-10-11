# MoneyRecord — Modern Offline-First Personal Finance Tracker

MoneyRecord adalah aplikasi manajemen keuangan pribadi (pemasukan & pengeluaran bulanan) yang dibangun dengan **Flutter**, mengadopsi **Clean Architecture**, **BLoC Pattern**, dan **Design System Modern (Bento Grid & Glassmorphism)** dengan fokus utama pada performa, keamanan data lokal, dan kemudahan penggunaan (*user-friendly*).

---

## 🚀 Fitur Unggulan & Kompleksitas Teknis

### 1. In-App Expression Evaluator (Shunting-Yard Algorithm)
Alih-alih menggunakan keyboard default sistem yang lambat atau library luar, MoneyRecord menyematkan **Custom Keypad Finansial** dengan algoritma *Shunting-Yard* bawaan:
* Mendukung operasi aritmatika real-time langsung di input nominal (misal: `15000 + 25000 * 2`).
* Memperhitungkan *operator precedence* (`*` dan `/` didahulukan dibanding `+` dan `-`), ekspresi tanda kurung, dan proteksi *division by zero*.
* Evaluasi instan saat mengetik tanpa perlu menekan tombol sama dengan (`=`).

### 2. Reactive Offline-First SQLite Engine
* Menggunakan **SQLite (sqflite / sqflite_common_ffi)** dengan mode **Write-Ahead Logging (WAL)** dan pengaktifan *Foreign Key Constraints*.
* Pemetaan query cepat dengan *Indexed Range Queries* pada kolom tanggal dan kategori.
* Arsitektur **Reactive Stream**: Setiap mutasi data (tambah, edit, hapus) langsung menyiarkan pembaruan ke UI tanpa *manual refresh* atau *loading spinner*.

### 3. Visualisasi Data Finansial Interaktif
* **Cashflow Spline Chart**: Kurva tren pengeluaran harian sepanjang bulan berjalan dengan *smooth gradient fill* dan *touch tooltip inspection*.
* **Category Donut Breakdown**: Visualisasi proporsi pengeluaran per kategori dengan lubang tengah interaktif yang menampilkan ringkasan nominal saat segmen disentuh.

### 4. Standar Desain Finansial Modern (WCAG AA Compliant)
* **Tipografi Terkurasi**: Menggunakan font **Lexend** (dirancang khusus untuk keterbacaan angka dan finansial) dipadukan dengan **Inter**.
* **Privacy Mode**: Tombol toggle ikon mata untuk menyamarkan nominal saldo (`••••••••`) saat pengguna berada di ruang publik.
* **Touch Targets & Spacing**: Seluruh tombol dan area sentuh memenuhi standar minimum aksesibilitas **48×48 dp**.
* **Export Laporan (CSV)**: Fitur ekspor data transaksi periode bulanan ke format CSV untuk analisis spreadsheet.

---

## 🏛️ Arsitektur Proyek (Clean Architecture)

```
lib/
├── core/
│   ├── constants/            # Design tokens: AppColors, AppTypography
│   ├── database/             # SQLite Helper, WAL config, indexing, migration
│   ├── math/                 # Custom Shunting-Yard arithmetic expression evaluator
│   └── utils/                # CurrencyFormatter (IDR), DateUtils (relative dates)
├── features/
│   ├── categories/           # Category Domain & Data layer with default seeds
│   ├── transactions/         # Transactions Feature:
│   │   ├── domain/           # Entities (Transaction, MonthlySummary) & UseCases
│   │   ├── data/             # Models & TransactionRepositoryImpl (Reactive Streams)
│   │   └── presentation/     # BLoC, BalanceHeroCard, SplineChart, NumpadSheet
│   ├── analytics/            # Analytics Feature: Donut Chart, KPI cards, CSV Export
│   └── navigation/           # MainNavigationScaffold (Modern pill navigation bar)
├── injection_container.dart  # Dependency Injection via GetIt
└── main.dart                 # Application entry point & theme setup
```

---

## 🧪 Pengujian & Kualitas Kode (Testing)

Proyek ini dilengkapi dengan unit test dan widget test komprehensif:

* **Math Evaluator Tests**: Menguji keakuratan evaluasi aritmatika, tanda kurung, desimal, dan *division by zero*.
* **Domain Use Case Tests**: Pengujian business rules `SaveTransaction` dengan *Mocktail*.
* **Widget Tests**: Pengujian interaksi UI pada `BalanceHeroCard` (toggle privacy) dan `TransactionTile`.

Jalankan test suite:
```bash
flutter test
```

Verifikasi linting dan analisis kode:
```bash
flutter analyze
```

---

## 💻 Cara Menjalankan

1. Clone repositori ini atau masuk ke direktori proyek:
   ```bash
   cd money_record
   ```
2. Pasang seluruh dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi di emulator atau perangkat fisik (Android / iOS / Linux Desktop):
   ```bash
   flutter run
   ```
