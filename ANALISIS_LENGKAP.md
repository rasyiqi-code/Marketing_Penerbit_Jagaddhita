# Analisis Lengkap Bug UI/UX — Marketing Penerbit Jagaddhita

**Total file dianalisis:** 101 file Dart  
**Metode:** Analisis source code (tanpa menjalankan app)  
**Stack:** Flutter, Provider, Google Fonts (Outfit), Material 3, Firebase  
**Target platform:** Mobile (Android & iOS) + Web (stub files exist)

---

## 🔴 KRITIS — CRASH & KOMPILASI WEB

### 1. ~~`dart:io` di `network_image_web_helper_stub.dart` menyebabkan compile error di web~~ `[Selesai]`
`lib/src/core/utils/network_image_web_helper_stub.dart` menggunakan `import 'dart:io'` dan class `File` (line 4, 25). Karena conditional import di `network_image_web_helper.dart` hanya memisah file berdasarkan `kIsWeb` via ekspor, file **stub** tetap dibaca kompiler. Ini menyebabkan **error kompilasi total** untuk target web.

### 2. ~~`poster_export_helper_stub.dart` juga pakai `dart:io`~~ `[Selesai]`
`lib/src/core/utils/poster_export_helper_stub.dart:4` import `dart:io` + `File`, sementara `poster_export_helper_web.dart` sudah benar pakai universal method. Pattern yang sama di `excel_export_helper_stub.dart`. Semua file stub akan **gagal compile di web**.

### 3. `currency_input_formatter.dart` tidak handle format desimal
`lib/src/core/utils/currency_input_formatter.dart:32-37` — Menggunakan `NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format()` tanpa `int.parse()` atau validasi lanjutan, bisa menghasilkan output berisi karakter non-digit yang menyebabkan `FormatException` saat parsing.

---

## 🟠 USER EXPERIENCE — FORM & INPUT

### 4. ~~Form registrasi tidak punya loading state per-field~~ `[Selesai]`
`lib/src/features/auth/register_screen.dart` — Hanya satu boolean `_isLoading` global. Saat registrasi, semua field tidak di-disabled, pengguna bisa edit field saat proses berlangsung, menyebabkan race condition data.

### 5. ~~Login tidak show error spesifik yang user-friendly~~ `[Selesai]`
`lib/src/features/auth/login_screen.dart:49-95` — Error dari Firebase Auth ditampilkan via `SnackBar` dengan `.toString()`. Pesan error teknis (seperti "User not found", "Wrong password") dari Firebase **exposed ke user** tanpa diterjemahkan ke Bahasa Indonesia.

### 6. ~~`login_form.dart` tidak handle keyboard type untuk email~~ `[Selesai]`
`lib/src/features/auth/widgets/login_form.dart:110-135` — Field email menggunakan `TextInputType.text` (default), seharusnya `TextInputType.emailAddress` dengan `autofillHints: [AutofillHints.email]` untuk UX lebih baik di mobile.

### 7. ~~Register screen tidak handle `AutofillHints`~~ `[Selesai]`
`lib/src/features/auth/register_screen.dart` — Tidak ada `autofillHints` untuk field apapun. Password manager tidak bisa auto-fill. Juga tidak ada `AutofillGroup` wrapping.

### 8. ~~`app_text_field.dart` tidak handle `autofillHints` atau `autofocus`~~ `[Selesai]`
`lib/src/core/widgets/app_text_field.dart` — Widget reusable `AppTextField` tidak menerima parameter `autofillHints`, `autofocus`, atau `textInputAction`. Setiap field harus manual menggunakan `TextField` langsung untuk fitur ini.

### 9. ~~Sales entry form: product picker bottom sheet tidak handle loading/error state~~ `[Selesai]`
`lib/src/features/sales/widgets/product_picker_field.dart:30-44` — `_CatalogModal` dibuka tanpa state loading. Jika daftar produk sedang tidak tersedia (error/null), modal menampilkan empty list tanpa feedback error.

### 10. ~~Sales entry: `_customerController` search tidak debounce~~ `[Selesai]`
`lib/src/features/sales/sales_entry_book_screen.dart:154-163` — `onChanged` langsung filter customer list tanpa debounce. Di mobile dengan 100+ customer, ini menyebabkan lag pada tiap ketikan.

### 11. ~~Withdrawal form tidak ada konfirmasi sebelum submit~~ `[Selesai]`
`lib/src/features/wallet/withdrawal_request_screen.dart:125-150` — Tombol "Ajukan Pencairan" langsung memproses tanpa dialog konfirmasi. User bisa tidak sengaja klaim jumlah besar.

### 12. ~~Tidak ada validasi jumlah minimum withdrawal yang informatif~~ `[Selesai]`
`lib/src/features/wallet/withdrawal_request_screen.dart` — Validasi hanya di `_validateAmount()` dengan return boolean. User tidak diberitahu MINIMUM payout saat form invalid, harus membaca dari GlobalSettings.

### 13. ~~`_paymentStatus` selector tidak synced dengan settings enable/disable~~ `[Selesai]`
`lib/src/features/sales/sales_entry_book_screen.dart:58` — `_paymentStatus` default 'DP'. Jika admin menonaktifkan DP (`enablePaymentDP: false`), form tetap menampilkan DP sebagai default tanpa fallback ke opsi lain. User bisa submit dengan status yang tidak diizinkan.

---

## 🔵 NAVIGASI & ROUTING

### 14. ~~Deep link `/bio/{userId}` tidak validasi userId format~~ `[Selesai]`
`lib/main.dart:111-121` — Tidak ada validasi userId/username. String apapun di `/bio/...` diterima, menghasilkan tampilan "User Not Found" yang jelek di `LinkBioLoadingScreen`.

### 15. ~~Tidak ada route error handling (404)~~ `[Selesai]`
`lib/main.dart` — Route generator menggunakan `onGenerateRoute`. Jika ada route yang tidak dikenal, tidak ada fallback ke halaman 404. App hanya white screen.

### 16. ~~Bottom nav bar tidak maintain state per tab~~ `[Selesai]`
`lib/src/features/home/main_screen.dart:50-65` — Menggunakan `IndexedStack` dengan benar, tapi tab `CatalogScreen` dan `ProfileScreen` dibuat ulang tiap kali build karena tidak menggunakan `AutomaticKeepAliveClientMixin`. State hilang saat switch tab.

### 17. ~~Transaction filter reset tanpa animasi~~ `[Selesai]`
`lib/src/features/admin/admin_transactions_screen.dart:96-110` — Saat filter status berubah, list langsung refresh tanpa transisi atau skeleton loader. User tidak melihat perubahan yang smooth.

### 18. ~~Admin withdrawals tab tidak persist scroll position~~ `[Selesai]`
`lib/src/features/admin/admin_withdrawals_screen.dart:15` — Menggunakan `DefaultTabController` tanpa `TabBarView` dengan `AutomaticKeepAliveClientMixin`. Scroll position hilang saat switch tab Status (Pending ↔ History).

---

## 🟡 FEEDBACK VISUAL & ERROR HANDLING

### 19. ~~Tidak ada empty state untuk sales history~~ `[Selesai]`
`lib/src/features/sales/history/sales_history_screen.dart` — Jika user tidak punya transaksi, list kosong ditampilkan tanpa ilustrasi atau pesan ramah.

### 20. ~~Notification list: empty state hanya teks~~ `[Selesai]`
`lib/src/features/notifications/notification_list_screen.dart:42-49` — Empty state hanya `Text('Belum ada notifikasi')` tanpa ikon/ilustrasi. Tidak engaging.

### 21. ~~Global settings: success/error feedback tidak konsisten~~ `[Selesai]`
`lib/src/features/admin/global_settings_screen.dart` — Beberapa action menggunakan `SnackBar`, beberapa menggunakan `ScaffoldMessenger.showSnackBar`, tidak ada konsistensi. Setting yang berhasil disimpan tidak selalu feedback ke user.

### 22. ~~File upload di berbagai screen tidak menunjukkan progress~~ `[Selesai]`
`lib/src/features/sales/sales_entry_book_screen.dart`, `edit_profile_sheet.dart`, `transaction_update_dialog.dart` — Semua upload file hanya pakai `CircularProgressIndicator` tanpa persentase atau estimasi waktu.

### 23. ~~Poster generator tidak show error saat download gagal~~ `[Selesai]`
`lib/src/features/home/poster_generator_screen.dart:380-400` — `_processAndDownloadPoster` hanya `catch (e)` dengan print ke console. User tidak melihat error jika download gagal.

### 24. ~~`_showEditDialog` di poster generator tidak ada validasi input~~ `[Selesai]`
`lib/src/features/home/poster_generator_screen.dart:128-181` — Form untuk edit nama/telepon tidak ada validasi. User bisa submit nama kosong atau telepon tidak valid.

---

## 🟣 LAYOUT & RESPONSIVITAS

### 25. ~~Web wrapper memaksa maxWidth 480px~~ `[Selesai]`
`lib/src/core/utils/responsive_web_layout.dart:16-22` — Web layout dipaksa maksimal 480px (mobile width). Di layar 1920px, konten hanya 480px dengan grey background luas.

### 26. ~~Admin dashboard tidak optimized untuk tampilan web~~ `[Selesai]`
`lib/src/features/admin/admin_home_screen.dart` — Admin dashboard menggunakan layout mobile (single column). Di web dengan layar lebar, semua widget ditumpuk vertikal.

### 27. ~~`WalletCard` menggunakan hardcoded dark background~~ `[Selesai]`
`lib/src/features/home/widgets/wallet_card.dart:27` — `Color(0xFF1E1E1E)` hardcoded, tidak mengikuti tema. Di dark mode, kontras berkurang.

### 28. ~~`app_text_field.dart` tidak responsive~~ `[Selesai]`
`lib/src/core/widgets/app_text_field.dart` — Padding, font size, dan border radius semuanya fixed (const). Di tablet / web, field terlihat terlalu kecil.

### 29. ~~`SalesCalculationCard` tidak handle overflow di device kecil~~ `[Selesai]`
`lib/src/features/sales/widgets/sales_entry_shared_widgets.dart:38-50` — Di HP 320px, teks panjang bisa overflow tanpa scroll atau ellipsis.

### 30. ~~`login_form.dart` tidak safe area untuk notched phone~~ `[Selesai]`
`lib/src/features/auth/widgets/login_form.dart` — Tidak ada `SafeArea` wrapper. Di iPhone dengan notch, form bisa tertutup oleh dynamic island.

### 31. ~~Headers di admin screens menggunakan `FittedBox` yang tidak perlu~~ `[Selesai]`
`lib/src/features/admin/admin_home_screen.dart:21-31` — `FittedBox` pada AppBar title dengan `BoxFit.scaleDown`. FittedBox tidak berguna dan bisa menyebabkan render issue.

### 32. ~~`home_header.dart` mungkin overflow di landscape~~ `[Selesai]`
Home header menampilkan avatar + nama + role. Di mode landscape HP, teks bisa terpotong karena layout horizontal terbatas.

---

## 🟢 INTERAKSI & FEEDBACK

### 33. ~~Tombol "Batal" navigasi di form tidak ada konfirmasi~~ `[Selesai]`
`sales_entry_book_screen.dart` — `Navigator.pop()` langsung tanpa dialog "Yakin ingin membatalkan transaksi?".

### 34. ~~`_calculateValues()` dipanggil di build/render~~ `[Selesai]`
`lib/src/features/sales/sales_entry_book_screen.dart:216-291` — Perhitungan berat ini bisa menyebabkan jank di setiap rebuild.

### 35. ~~Tombol switch dark/light theme ada di `AppTheme` tapi tidak digunakan~~ `[Selesai]`
`lib/src/core/theme/app_theme.dart` — ThemeData untuk light + dark sudah didefinisikan lengkap, tapi tidak ada toggle di UI.

### 36. ~~Tidak ada refresh indicator di sales history~~ `[Selesai]`
`lib/src/features/sales/history/sales_history_screen.dart` — Tidak ada `RefreshIndicator` untuk user yang ingin force refresh.

### 37. ~~Multiple notification mark-as-read tidak optimasi~~ `[Selesai]`
`lib/src/features/notifications/notification_list_screen.dart:31-37` — Tombol "Mark all as read" menggunakan loop `for` dengan await tiap `controller.markAsRead(n.id)`. Setiap iterasi membuat 1 Firestore write terpisah. Untuk 50 notifikasi, ini 50 write terpisah yang lambat dan mahal.

---

## ⚠️ KONSISTENSI & TYPO

### 38. ~~Inconsistent date formatting~~ `[Selesai]`
Beberapa screen menggunakan `DateFormat('dd MMM yyyy, HH:mm')`, beberapa pakai `DateFormat('d MMM yyyy')`, ada yang pakai `AppFormatters.formatFullDate()` jika tersedia.

### 39. ~~Tidak ada loading indicator di login Google~~ `[Selesai]`
`lib/src/features/auth/login_screen.dart:85-98` — `_handleGoogleSignIn()` tidak ada `setState(() => _isLoading = true)`. User bisa tap tombol Google berulang kali.

### 40. ~~`splash_screen.dart` menggunakan hardcoded 2 detik delay~~ `[Selesai]`
`lib/src/features/splash/splash_screen.dart:37` — `Future.delayed(const Duration(seconds: 2))` tanpa memperhitungkan waktu loading Firebase.

---

## 🎨 UI/UX BUG REPORT (DETAIL)

### 🔴 1. ~~Submit button disable logic secara visual misleading~~ `[Selesai]`
**File:** `sales_entry_book_screen.dart:864`
```dart
onPressed: (_isLoading || (_paymentStatus != 'COD' && _transactionProofUrl == null))
```
- Tombol submit null/disabled untuk DP/LUNAS jika belum upload bukti transaksi
- Tidak ada feedback visual ke user kenapa tombol disabled
- **Fix:** Tambahkan `Tooltip` atau helper text merah: "Upload bukti transfer terlebih dahulu"

### 🔴 2. ~~Tidak ada loading state waktu submit — layar diam saja~~ `[Selesai]`
**File:** `sales_entry_book_screen.dart:323`
- Saat submit, `_isLoading = true` mengubah tombol jadi spinner
- Form input TETAP bisa di-scroll, user bisa mengedit form saat proses submit berjalan
- **Fix:** Wrap dalam `Stack` + `ignorePointer` saat loading, atau disable semua TextFormField

### 🔴 3. ~~Keyboard tidak dismiss otomatis setelah submit~~ `[Selesai]`
**File:** `sales_entry_book_screen.dart`
- Tidak ada `FocusScope.of(context).unfocus()` sebelum submit
- Keyboard bisa menutupi SnackBar sukses/error

### 🔴 4. ~~Autocomplete customer suggestions bisa tertutup widget lain~~ `[Selesai]`
**File:** `sales_entry_book_screen.dart:591-644`
- List suggestions di-`Positioned` dengan `top: 50`
- Jika user scroll, posisi absolut tidak ikut scroll — suggestions bisa terpotong/tertutup

### 🔴 5. ~~`_paymentStatus` = 'DP' secara default, tapi field DP amount tidak muncul sampai `_settings` di-load~~ `[Selesai]`
**File:** `sales_entry_book_screen.dart:58`
- Default `_paymentStatus = 'DP'` tapi DP field hanya muncul setelah `_settings` ter-load
- Ada flash/jump layout saat setting datang

### 🟠 6. ~~Wallet Card warna hitam pekat (`#1E1E1E`) tidak konsisten dengan theme~~ `[Selesai]`
**File:** `wallet_card.dart:27`
```dart
color: const Color(0xFF1E1E1E), // Dark card for contrast
```
- Background hitam hardcoded, tidak mengikuti theme
- Di dark mode jadi hitam di atas hitam — kurang kontras
- Di light mode tidak match dengan card lain yang putih/light grey

### 🟠 7. ~~Wallet Card Split Layout — `LayoutBuilder` duplikasi kode besar~~ `[Selesai]`
**File:** `wallet_card.dart:40-198`
- Seluruh layout "Saldo Tunai" di-duplicate untuk `isNarrow` dan normal
- Banyak kode redundan (>150 baris untuk card sederhana)
- Rentan bug: satu branch di-edit, yang lain lupa di-edit

### 🟠 8. Format nominal tidak pakai separator ribuan di komisi card
**File:** `wallet_card.dart:149-151`
- `AppFormatters.currency` dipakai, tapi ada baris di card lain yang masih raw formatting
- Beberapa tempat di codebase pakai `NumberFormat.currency` langsung dengan format inconsistent

### 🟠 9. Keterangan potongan diskon mengelirukan
**File:** `sales_entry_shared_widgets.dart:93-97`
```dart
_CalcRow(label: 'Diskon ${discountPercent.toStringAsFixed(0)}%', ...)
```
- `discountPercent` ini sebenarnya adalah persentase komisi agent, bukan diskon yang diberikan ke customer
- Nama "Diskon" mengelirukan — seharusnya "Komisi Agent" atau "Potongan Marketing"

### 🟠 10. ~~Faktur/preview tidak ada — user tidak lihat hasil final sebelum submit~~ `[Selesai]`
**File:** `sales_entry_book_screen.dart`
- Tidak ada halaman konfirmasi/review sebelum submit
- User menekan submit langsung, tidak bisa review ulang pesanan

### 🟠 11. `positionInitialized` state untuk drag text di poster — inisialisasi di build()
**File:** `poster_generator_screen.dart:476-484`
```dart
if (!_positionInitialized) {
    _position = Offset(...);
    _positionInitialized = true;
}
```
- Inisialisasi posisi di `build()` method — side effect dalam build, melanggar prinsip Flutter

### 🟠 12. ~~Tidak ada tombol "Kembali" konsisten di AppBar admin~~ `[Selesai]`
**File:** `admin_home_screen.dart:21` — `automaticallyImplyLeading: false`
- Admin home tidak punya tombol back/logout di app bar
- User harus buka Profile > Logout untuk keluar — 3 tap padahal harusnya 1 tap

### 🟠 13. ~~Halaman Notifikasi tidak ada "Mark All as Read" yang real-time~~ `[Selesai]`
**File:** `notification_list_screen.dart:31-39`
- Mark all as read pakai loop `for`, tapi tidak ada optimistic UI update
- UI tidak berubah sampai stream Firestore merespon

### 🟠 14. ~~`_formatDate` di notification tidak handle yesterday~~ `[Selesai]`
**File:** `notification_list_screen.dart:240-251`
- Hanya handle: today → jam, `< 7 days` → nama hari, `>= 7 days` → tanggal
- Tidak ada "Kemarin" — notifikasi kemarin muncul sebagai "Wednesday, 14:30"

### 🟠 15. Copy-to-clipboard tooltip ambigu
**File:** `admin_claim_card.dart:357-358`
```dart
child: Tooltip(message: 'Tap to copy', child: content),
```
- Tooltip multilingual: UI pakai Bahasa Indonesia, tapi tooltip English
- SnackBar setelah copy juga English: "Copied: $text"

### 🟡 16. Version splash tidak sync dengan pubspec
**File:** `splash_screen.dart:101` — Hardcode `'v1.1.1'`  
**File:** `pubspec.yaml` — `version: 1.1.2+4`

### 🟡 17. Login screen: background putih tapi ada gap dengan widget lain
**File:** `login_screen.dart:278-280`
```dart
Container(color: Colors.white),
```

### 🟡 18. Register screen tidak ada Google Sign-In option
**File:** `register_screen.dart` — Login screen punya "Masuk dengan Google", register screen tidak ada

### 🟡 19. ~~Tombol "Tarif Pulsa" di wallet bisa diklik padahal saldo 0~~ `[Selesai]`
**File:** `wallet_card.dart:238-246` — `TextButton` untuk "Klaim Pulsa" selalu aktif

### 🟡 20. SnackBar tidak uniform — ada yang floating, ada yang default
Di seluruh codebase — tidak konsisten

### 🟡 21. `dart:io` image_picker untuk web tidak berfungsi
**File:** `poster_generator_screen.dart:116-117` — `image_picker` di web hanya support `ImageSource.gallery`

### 🟡 22. `responsive_web_layout.dart` max-width 480px sangat sempit
**File:** `responsive_web_layout.dart:21` — `BoxConstraints(maxWidth: 480)`

### 🟡 23. Tidak ada tombol retry untuk error state di main_screen
**File:** `main_screen.dart:55-71` — Error ditampilkan dengan tombol "Logout", tidak ada "Coba Lagi"

### 🟡 24. `initialValue` di DropdownButtonFormField deprecated
**File:** `sales_entry_shared_widgets.dart:255`, `transaction_update_dialog.dart:298`

### 🟡 25. Tombol "Reset Semua Data" ada di production settings
**File:** `global_settings_screen.dart:456-459` — Tanpa audit log, sangat berbahaya

### 🟡 26. Image Management preview mungkin lambat tanpa loading
**File:** `image_management_screen.dart` — `errorWidget` ada, tapi tidak ada loading placeholder

### 🟡 27. Tooltip icon info di wallet menggunakan `Icon` tanpa semantik label
**File:** `wallet_card.dart:62-68` — Screen reader tidak bisa membaca tooltip

### 🟡 28. `pushReplacementNamed('/auth_wrapper')` bisa menyebabkan infinite loop
**File:** `splash_screen.dart:51` — Setelah logout, splash tidak pernah muncul lagi

### 🟡 29. Tidak ada `unfocus()` saat tap luar field di modal edit contact poster
**File:** `poster_generator_screen.dart:128-181` — Tidak ada cara dismiss keyboard selain tap "Simpan"

### 🟡 30. Icon emoji (`📚`, `🏛️`) di catalog tidak konsisten di semua platform
**File:** `product_picker_field.dart:497,524` — Emoji render berbeda antar platform

---

## 📋 RINGKASAN PRIORITAS

| Prioritas | Jumlah | Kategori |
|-----------|--------|----------|
| 🔴 **Kritis (P1)** | 8 | Form UX, input feedback, layout jumps — dominan di `sales_entry_book_screen.dart` |
| 🟠 **User Experience (P2)** | 10 | Konsistensi visual, flow, informasi misleading |
| 🟡 **Polish (P3)** | 15 | Aksesibilitas, deprecation, minor improvements |

### Top 5 Paling Berdampak ke User
1. Submit button disabled tanpa feedback (user bingung)
2. Tidak ada review sebelum submit (salah input baru ketahuan setelah diproses)
3. Informasi komisi/keuangan membingungkan (label "Diskon")
4. Wallet color hardcoded, tidak ikut theme
5. Logout butuh 3 tap (user experience buruk)
