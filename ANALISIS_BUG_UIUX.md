# Analisis Bug UI/UX — Marketing Penerbit Jagaddhita

**Platform:** Mobile (Android & iOS)  
**Tanggal:** 17 Juni 2026  
**Scope:** 101 file Dart, analisis source code (tanpa menjalankan app)

---

## 🔴 KRITIS — CRASH / FORM DATA HILANG

| # | Issue | File | Baris | Status |
|---|-------|------|-------|--------|
| 1 | ~~**Submit button disable tanpa feedback** — Tombol submit non-aktif karena `_transactionProofUrl == null` tapi tidak ada penjelasan ke user kenapa tombol tidak bisa ditekan~~ | `sales_entry_book_screen.dart` | 864 | **Selesai** |
| 2 | ~~**Tidak ada review sebelum submit** — User langsung submit tanpa lihat ringkasan pesanan. Risiko salah produk/qty baru ketahuan setelah submit~~ | `sales_entry_book_screen.dart` | - | **Selesai** |
| 3 | ~~**`_calculateValues()` dipanggil di build/method berat** — Perhitungan ulang total harga dipanggil multi kali, potensi jank di tiap rebuild~~ | `sales_entry_book_screen.dart` | 216-291 | **Selesai** |
| 4 | ~~**`_paymentStatus` default 'DP' tapi field DP muncul belakangan** — Layout jump saat data `_settings` dari Firestore tiba, field jumlah DP tiba-tiba muncul~~ | `sales_entry_book_screen.dart` | 58, 799-808 | **Selesai** |
| 5 | ~~**Cancel form tanpa konfirmasi** — `Navigator.pop()` langsung, data form yang sudah diisi hilang tanpa dialog "Yakin ingin membatalkan?"~~ | `sales_entry_book_screen.dart` | - | **Selesai** |
| 6 | ~~**Autocomplete customer terpotong widget lain** — Suggestions di-`Positioned` dengan `top: 50`, tidak ikut scroll sehingga terpotong saat user scroll~~ | `sales_entry_book_screen.dart` | 591-644 | **Selesai** |
| 7 | ~~**Tidak ada loading state waktu submit** — Form fields tetap bisa diedit saat `_isLoading = true`, berpotensi race condition data~~ | `sales_entry_book_screen.dart` | 323 | **Selesai** |
| 8 | ~~**Keyboard tidak dismiss setelah submit** — Tidak ada `FocusScope.of(context).unfocus()` sebelum submit, keyboard nutup SnackBar sukses/error~~ | `sales_entry_book_screen.dart` | - | **Selesai** |

---

## 🟠 USER EXPERIENCE — FORM, NAVIGASI, FEEDBACK

| # | Issue | File | Baris | Status |
|---|-----| 9 | ~~**Label "Diskon" mengelirukan** — Menampilkan "Diskon X%" yang sebenarnya adalah persentase komisi agent, bukan diskon ke customer. Bikin agent bingung soal nominal yang mereka dapat~~ | `sales_entry_shared_widgets.dart` | 93-97 | **Selesai** |
| 10 | ~~**Wallet card warna hardcoded `#1E1E1E`** — Background hitam pekat tidak mengikuti tema. Di dark mode jadi hitam di atas hitam (kurang kontras), di light mode tidak match card lain~~ | `wallet_card.dart` | 27 | **Selesai** |
| 11 | ~~**Wallet card LayoutBuilder duplikasi >150 baris** — Seluruh layout "Saldo Tunai" di-duplicate untuk `isNarrow` dan normal. Rawan bug saat satu branch di-edit tapi yang lain lupa~~ | `wallet_card.dart` | 40-198 | **Selesai** |
| 12 | ~~**Logout butuh 3 tap dari admin home** — `automaticallyImplyLeading: false` di admin home tanpa tombol logout langsung. User harus Profile > Logout~~ | `admin_home_screen.dart` | 21 | **Selesai** |
| 13 | ~~**Tidak ada refresh indicator di sales history** — Meski pakai stream, user tidak bisa force refresh secara manual~~ | `sales_history_screen.dart` | - | **Selesai** |
| 14 | ~~**Withdrawal tanpa konfirmasi sebelum submit** — Tombol "Ajukan Pencairan" langsung proses tanpa dialog konfirmasi nominal~~ | `withdrawal_request_screen.dart` | 125-150 | **Selesai** |
| 15 | ~~**Mark all read tidak optimistic** — Notifikasi di-mark via loop `for` + await tiap item. UI tidak berubah sampai stream Firestore balik, user lihat badge masih ada~~ | `notification_list_screen.dart` | 31-39 | **Selesai** |
| 16 | ~~**Search customer tanpa debounce** — `onChanged` langsung filter list tanpa jeda. Dengan 100+ customer, terjadi lag di tiap ketikan~~ | `sales_entry_book_screen.dart` | 154-163 | **Selesai** |
| 17 | ~~**Register screen tidak ada Google Sign-In** — Login screen punya opsi "Masuk dengan Google", register screen tidak punya~~ | `register_screen.dart` | - | **Selesai** |
| 18 | ~~**No retry button di error state main screen** — Jika error, yang muncul hanya tombol "Logout". User tidak punya opsi "Coba Lagi"~~ | `main_screen.dart` | 55-71 | **Selesai** |
| 19 | ~~**Login error eksposed mentah** — Error Firebase Auth (`User not found`, `Wrong password`) ditampilkan via `.toString()` tanpa diterjemahkan ke Bahasa Indonesia yang user-friendly~~ | `login_screen.dart` | 49-95 | **Selesai** |
| 20 | ~~**Register loading state tidak disable fields** — Hanya satu boolean `_isLoading`, semua field tetap bisa diedit saat proses registrasi~~ | `register_screen.dart` | - | **Selesai** |
| 21 | ~~**Minimal withdrawal tidak diinformasikan** — Validasi hanya return boolean, user tidak tahu nominal minimum payout~~ | `withdrawal_request_screen.dart` | - | **Selesai** |
| 22 | ~~**Bottom nav tabs tidak maintain state** — Tab Catalog & Profile tidak pakai `AutomaticKeepAliveClientMixin`, state hilang saat switch tab~~ | `main_screen.dart` | 50-65 | **Selesai** |
| 23 | ~~**Filter transaksi tanpa animasi** — List langsung refresh tanpa skeleton loader atau transisi~~ | `admin_transactions_screen.dart` | 96-110 | **Selesai** |
| 24 | ~~**Admin withdrawals scroll position hilang** — `DefaultTabController` tanpa `AutomaticKeepAliveClientMixin`, scroll hilang saat switch tab~~ | `admin_withdrawals_screen.dart` | 15 | **Selesai** |

---

## 🟡 POLISH & KONSISTENSI

| # | Issue | File | Baris | Status |
|---|-------|------|-------|--------|
| 25 | ~~**Version splash tidak sync pubspec** — Hardcode `v1.1.1` di splash screen, sementara pubspec `1.1.2+4`~~ | `splash_screen.dart` | 101 | **Selesai** |
| 26 | ~~**Tombol "Klaim Pulsa" selalu aktif** — `TextButton` tetap bisa ditekan walau `pulsaBalance == 0`, user masuk form klaim lalu ditolak~~ | `wallet_card.dart` | 238-246 | **Selesai** |
| 27 | ~~**Tidak ada empty state ilustrasi** — Sales history & notification list kosong cuma teks doang, tanpa ikon/ilustrasi yang engaging~~ | `sales_history_screen.dart`, `notification_list_screen.dart` | 42-49 | **Selesai** |
| 28 | ~~**SnackBar tidak konsisten** — Ada yang pakai `SnackBarBehavior.floating`, ada yang default. Muncul di posisi beda-beda~~ | Seluruh codebase | - | **Selesai** |
| 29 | ~~**Date formatting tidak seragam** — Beberapa screen pakai `dd MMM yyyy, HH:mm`, beberapa `d MMM yyyy`, beberapa `AppFormatters.formatFullDate()`~~ | Seluruh codebase | - | **Selesai** |
| 30 | ~~**`DropdownButtonFormField` deprecated `initialValue`** — Harusnya pakai `value`, bukan `initialValue`~~ | `sales_entry_shared_widgets.dart`, `transaction_update_dialog.dart` | 255, 298 | **Selesai** |
| 31 | ~~**"Reset Semua Data" berbahaya** — Tombol di `DangerZoneSettingsCard` bisa hapus seluruh database dalam 2 tap tanpa audit log~~ | `global_settings_screen.dart` | 456-459 | **Selesai** |
| 32 | ~~**Image preview tanpa loading placeholder** — `NetworkImageWeb` hanya punya `errorWidget`, tidak ada loading placeholder~~ | `image_management_screen.dart` | - | **Selesai** |
| 33 | ~~**Google login tanpa loading state** — `_handleGoogleSignIn()` tidak set `_isLoading = true`, user bisa double tap tombol login~~ | `login_screen.dart` | 85-98 | **Selesai** |
| 34 | ~~**`positionInitialized` diinisialisasi di `build()`** — Side effect dalam render, setiap rebuild ubah state~~ | `poster_generator_screen.dart` | 476-484 | **Selesai** |
| 35 | ~~**Notifikasi tidak handle "Kemarin"** — Notifikasi kemarin muncul sebagai nama hari ("Wednesday, 14:30") bukan "Kemarin"~~ | `notification_list_screen.dart` | 240-251 | **Selesai** |
| 36 | ~~**Tooltip copy Bahasa Inggris** — UI pakai Bahasa Indonesia, tapi tooltip "Tap to copy" dan SnackBar "Copied:"~~ | `admin_claim_card.dart` | 357-358 | **Selesai** |
| 37 | ~~**Icon emoji tidak konsisten antar platform** — `📚` `🏛️` render beda di Android vs iOS, sebaiknya pakai `Icons` Material Design~~ | `product_picker_field.dart` | 497, 524 | **Selesai** |
| 38 | ~~**Splash screen hardcoded 2 detik** — Tidak memperhitungkan waktu loading Firebase, ada white screen singkat~~ | `splash_screen.dart` | 37 | **Selesai** |
| 39 | ~~**Login form tanpa SafeArea** — Bisa ketutup notch di iPhone~~ | `login_form.dart` | - | **Selesai** |
| 40 | ~~**`app_text_field.dart` tidak handle `autofillHints`** — Password manager tidak bisa auto-fill, semua field manual~~ | `app_text_field.dart` | - | **Selesai** |
| 41 | ~~**File upload tanpa progress** — Upload bukti transfer & foto profile hanya pakai `CircularProgressIndicator` tanpa persentase/estimasi~~ | `sales_entry_book_screen.dart`, `edit_profile_sheet.dart` | - | **Selesai** |
| 42 | ~~**Poster generator error download tidak ke user** — `catch (e)` hanya print ke console, user tidak tahu download gagal~~ | `poster_generator_screen.dart` | 380-400 | **Selesai** |
| 43 | ~~**Poster edit dialog tanpa validasi input** — Nama & telepon bisa dikirim kosong atau tidak valid~~ | `poster_generator_screen.dart` | 128-181 | **Selesai** |
| 44 | ~~**Theme toggle ada tapi tidak dipakai** — `AppTheme` sudah definisikan light + dark lengkap, tapi tidak ada switch di UI~~ | `app_theme.dart` | - | **Selesai** |
| 45 | ~~**Notifikasi mark-as-read loop tidak optimasi** — 50 notifikasi = 50 Firestore write terpisah, lambat & mahal~~ | `notification_list_screen.dart` | 31-37 | **Selesai** |
| 46 | ~~**`SalesCalculationCard` overflow di device kecil** — Column dengan Row untuk label-value bisa overflow di HP 320px tanpa ellipsis~~ | `sales_entry_shared_widgets.dart` | 38-50 | **Selesai** |
| 47 | ~~**`home_header.dart` overflow di landscape** — Avatar + nama + role bisa terpotong di mode landscape~~ | `home_header.dart` | - | **Selesai** |
| 48 | ~~**FittedBox tidak perlu di admin home** — `FittedBox(BoxFit.scaleDown)` pada AppBar title pendek ("Admin Dashboard") tidak berguna~~ | `admin_home_screen.dart` | 21-31 | **Selesai** |
| 49 | ~~**`pushReplacementNamed('/auth_wrapper')` bikin flow tidak natural** — Setelah logout, tombol back tidak bisa kembali ke splash~~ | `splash_screen.dart` | 51 | **Selesai** |

---

## 📋 RINGKASAN PRIORITAS

| Prioritas | Jumlah | Kategori |
|-----------|--------|----------|
| 🔴 **Kritis** | 8 | Form UX, data hilang, layout jumps — dominan di `sales_entry_book_screen.dart` |
| 🟠 **User Experience** | 16 | Navigasi, feedback, konsistensi visual |
| 🟡 **Polish** | 25 | Aksesibilitas, deprecation, minor improvements |
| **Total** | **49** | |

### File Paling Bermasalah

| File | Jumlah Issue | Severity |
|------|-------------|----------|
| `sales_entry_book_screen.dart` | 8 🔴 | Form entry utama — paling kritis |
| `wallet_card.dart` | 3 🟠 | Informasi saldo tidak konsisten |
| `notification_list_screen.dart` | 3 🟡 | Feedback & optimasi |
| `poster_generator_screen.dart` | 3 🟡 | Validasi & error handling |

### Top 5 Paling Berdampak ke User

1. **#1** — Tombol disabled tanpa feedback (user bingung)
2. **#2** — Tidak ada review sebelum submit (salah input baru ketahuan setelah diproses)
3. **#9** — Label "Diskon" mengelirukan (informasi komisi salah)
4. **#10** — Wallet color hardcoded (jelek di dark mode)
5. **#12** — Logout butuh 3 tap (user experience buruk)
