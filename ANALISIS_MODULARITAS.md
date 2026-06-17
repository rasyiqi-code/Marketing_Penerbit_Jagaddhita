# Analisis Modularitas Kode — Marketing Penerbit Jagaddhita

---

## 🔴 High Severity — Perlu Refaktor Segera

### 1. `sales_entry_book_screen.dart` — 997 Baris, Monolitik
**File:** `lib/src/features/sales/sales_entry_book_screen.dart`

**Masalah:**
- **997 baris** menangani: form UI, autocomplete customer, pemilihan produk, kalkulasi diskon, logika komisi, bonus pulsa, validasi (8 snackbar), data building, Firestore write, notifikasi, navigasi, dialog review — semua dalam satu StatefulWidget.
- **God method `_submitSale()`** (baris 269–503 = **234 baris**) — validasi, assembly data, Firestore write, kirim notifikasi, trigger notif lokal, navigasi pop, error handling.
- **God method `_calculateValues()`** (baris 221–267) — kalkulasi bruto, diskon, netto, komisi, AND bonus pulsa — 46 baris business logic di file UI.
- **Inline widgets:** dropdown customer suggestion (682–726), product list with steppers (761–858), unsaved-changes dialog (535–562), review order dialog (342–384) — semua inline di `build()`.
- **Mixed concerns:** Langsung panggil `Provider.of<AuthService>`, `Provider.of<SalesService>`, `Provider.of<CustomerService>`, `Provider.of<AppNotificationService>`, `Provider.of<local.NotificationService>` — **5 service berbeda** di satu screen.
- **Duplikasi pola:** 8 SnackBar hampir identik untuk validasi.

**Saran Refaktor:**
- Ekstrak `SalesEntryViewModel` / `SalesEntryController` untuk state + logic (kalkulasi, validasi, submit).
- Ekstrak inline widgets: `CustomerSuggestionsList`, `SelectedProductStepperList`, `ReviewOrderDialog`, `UnsavedChangesDialog`.
- Pindahkan logic kalkulasi ke `CommissionCalculator` service.
- Target: **<400 baris**.

---

### 2. `product_picker_field.dart` — 1.007 Baris, 6 Class dalam 1 File
**File:** `lib/src/features/sales/widgets/product_picker_field.dart`

**Masalah:**
- **1.007 baris** berisi **6 class widget**: `ProductPickerField` (public), `_CatalogModal`, `_ConfirmBar`, `_ProductCard`, `_PlaceholderImage`, `_SectionHeader`.
- `_CatalogModal` sendiri ~886 baris dengan search, filter, multi-select mode, grouped product list, confirm bar sticky.
- Ini adalah full-screen feature yang disamarkan sebagai "file widget."

**Saran Refaktor:**
- Pisah ke file terpisah: `product_picker_field.dart`, `catalog_modal.dart`, `product_card.dart`, `confirm_bar.dart`, `placeholder_image.dart`, `section_header.dart`.
- Target: **<150 baris per file**.

---

### 3. `faktur_printable_sheet.dart` (774) + `faktur_pdf_generator.dart` (824) — Duplikasi Masif
**File:**
- `lib/src/features/sales/widgets/faktur_printable_sheet.dart`
- `lib/src/features/sales/utils/faktur_pdf_generator.dart`

**Masalah:**
- **1.598 baris gabungan** mengimplementasikan layout invoice yang hampir identik di dua renderer berbeda (Flutter widget vs PDF).
- **32+ baris fallback settings duplikat** — wallet fallback untuk `publisherName`, `publisherSlogan`, `bankName`, `bankAccountNo`, dll.
- **20+ baris stamp logic duplikat** — `isLunas`/`isComplete`/`isDp`/`isPending`/`isCod` booleans dan `stampColor`/`stampText` switch blocks.
- `build()` di `faktur_printable_sheet.dart` **700+ baris**.
- `generateFakturPdf()` di `faktur_pdf_generator.dart` **770+ baris**.

**Saran Refaktor:**
- Ekstrak shared invoice data logic ke `InvoiceData` helper class: `InvoiceData.fromSale(SaleModel, GlobalSettingsModel?)` yang compute semua display values, stamp info, totals.
- Simpan hanya rendering-specific code di masing-masing file.
- Target: **<200 baris per file** untuk shared logic + **<200 baris per renderer**.

---

### 4. `global_settings_screen.dart` — 469 Baris, 22 TextEditingController
**File:** `lib/src/features/admin/global_settings_screen.dart`

**Masalah:**
- **22 TextEditingController** diinit di `initState()` (69–93) dan didispose di `dispose()` (285–313).
- `_loadSettings()` (98–150) dan `_saveSettings()` (152–219) method masif yang copy 22+ field.
- `build()` (316–468) = 152 baris form dengan 7 `SettingsSectionHeader` + 7 settings card, semua state management pake `setState()`.
- Tight coupling: langsung `Provider.of<ProductService>` tanpa view model.

**Saran Refaktor:**
- Buat `SettingsViewModel`/`SettingsController` dengan reactive fields.
- Group controllers ke logical sub-objects (`CommissionSettings`, `PulsaBonusSettings`, `InvoiceSettings`).
- Target: **<250 baris**.

---

### 5. `poster_generator_screen.dart` — 538 Baris, Mixed Responsibilities
**File:** `lib/src/features/home/poster_generator_screen.dart`

**Masalah:**
- **Mixed concerns:** HTTP image fetching (78–112), image picking (114–126), edit dialog (128–181), style bottom sheet (183–285), image overlay rendering (287–343), poster processing + export (345–429) — semua di satu file.
- Edit dialog (128–181) inline.
- Style panel bottom sheet (183–285) inline.
- `_createOverlayImageBytes` (287–343) — rendering logic campur screen.
- `_processAndDownloadPoster` (345–429) — coordinate math, image processing, file export, error handling.

**Saran Refaktor:**
- Ekstrak `PosterEditContactDialog`, `PosterStylePanel` ke file widget terpisah.
- Pindahkan image processing logic ke `PosterGeneratorService` (udah ada tapi kurang dipake).
- Ekstrak overlay rendering ke `PosterOverlayPainter` widget.
- Target: **<250 baris**.

---

### 6. `link_bio_admin_widgets.dart` — 574 Baris, 3+ Widget dalam 1 File
**File:** `lib/src/features/link_bio/widgets/link_bio_admin_widgets.dart`

**Masalah:**
- Berisi 3 distinct public widgets: `LinkBioHeaderCard`, `LinkBioSocialForm`, `LinkBioCustomLinkCard`.
- Masing-masing 100–250 baris, dijejalkan dalam satu file.
- Social form punya 4 pola `TextFormField` hampir identik untuk WhatsApp, Instagram, TikTok, Facebook (350–417).

**Saran Refaktor:**
- Pisah ke `link_bio_header_card.dart`, `link_bio_social_form.dart`, `link_bio_custom_link_card.dart`.
- Ekstrak pola text field sosial media ke reusable `SocialMediaTextField`.
- Target: **<150 baris per file**.

---

## 🟠 Medium Severity

### 7. `transaction_update_dialog.dart` — 553 Baris, God Dialog
**File:** `lib/src/features/admin/widgets/transaction_update_dialog.dart`

**Masalah:**
- **553 baris** untuk satu dialog: image upload, shipping status, courier info, notes, payment status toggle, proof management.
- Akses `Provider.of<StorageService>`, `Provider.of<SalesService>`, `Provider.of<AppNotificationService>` — 3 services.
- `_confirmChanges()` method masif dengan multiple service calls + snackbar.

**Saran Refaktor:**
- Ekstrak `TransactionUpdateViewModel`.
- Break ke sub-widgets: `ProofUploadSection`, `ShippingInfoSection`, `PaymentStatusSection`.

---

### 8. `notification_list_screen.dart` — 255 Baris, Mixed Concerns
**File:** `lib/src/features/notifications/notification_list_screen.dart`

**Masalah:**
- `_handleNotificationTap` (140–237, ~100 baris) — fetch sales data, fetch wallet claims, loading dialog, `SaleDetailDialog`, claim dialog, error handling.
- Tapping notifikasi trigger: `Provider.of<SalesService>`, `Provider.of<WalletService>`, dialog management, navigation — semua di method StatelessWidget.
- Routing notifikasi pakai `title.contains(...)` string matching (165–189) — fragile.

**Saran Refaktor:**
- Pindahkan handling ke `NotificationController.handleTap(NotificationModel)` yang return route/destination.
- Ekstrak `_EmptyState` (duplikat di `sales_history_screen.dart`) ke shared `EmptyStateWidget`.
- Target: **<150 baris**.

---

### 9. `admin_claim_card.dart` — 419 Baris
**File:** `lib/src/features/admin/widgets/admin_claim_card.dart`

**Masalah:**
- 419 baris untuk "card" widget — handle claim display, status update logic, rejection dialog, confirmation dialog.
- God method `_approveRejectClaim` dengan sequential service calls.
- `Provider.of<AppNotificationService>` langsung di widget.

**Saran Refaktor:**
- Ekstrak dialogs + business logic ke `ClaimActionHandler`.
- Card presentational-only.

---

### 10. `sale_card.dart` (384) + `sale_detail_sheet.dart` (408)
**File:**
- `lib/src/features/sales/history/widgets/sale_card.dart`
- `lib/src/features/sales/history/widgets/sale_detail_sheet.dart`

**Masalah:**
- `sale_card.dart` — 384 baris untuk list item card: status badges, shipping info, payment status, action buttons, snackbar.
- `sale_detail_sheet.dart` — 408 baris bottom sheet: product list, total calculation, "Lunaskan" button + dialog, image uploading, service calls.
- Duplikasi formatting pattern currency, status display, product rows.

**Saran Refaktor:**
- Buat shared `SaleStatusBadge`, `SaleProductSummary`, `SaleActionButtons` widgets.
- Pindahkan logic "Lunaskan" ke shared helper/controller.

---

### 11. `profile_screen.dart` — 399 Baris, Private Widgets Tidak Diekstrak
**File:** `lib/src/features/profile/profile_screen.dart`

**Masalah:**
- 3 private widgets inline: `_ProfileAvatar`, `_SectionHeader`, `_SettingsTile` (286–399).
- 10 `TextEditingController` diinit + dispose inline.
- `_deleteAccount()` (145–169) — dialog, service calls, navigation, snackbar campur aduk.

**Saran Refaktor:**
- Ekstrak `_ProfileAvatar`, `_SectionHeader`, `_SettingsTile` ke file terpisah (pattern reusable).
- Pindahkan `_deleteAccount` ke `ProfileViewModel`.
- Target: **<200 baris**.

---

### 12. `bonus_eligibility_card.dart` — 388 Baris
**File:** `lib/src/features/home/widgets/bonus_eligibility_card.dart`

**Masalah:**
- StatefulWidget dengan business logic: fetch data dari `SalesService` (2 methods) + `ProductService` (via `StreamBuilder`).
- `build()` (53–298) = kalkulasi eligibility, conditional rendering, progress bars, layout — ~245 baris.
- `_buildProgressItem` (300–387) = 87 baris widget code.

**Saran Refaktor:**
- Ekstrak eligibility calculation ke `BonusEligibilityCalculator` utility.
- Ekstrak `_buildProgressItem` ke reusable `ProgressStatTile`.
- Target: **<200 baris**.

---

### 13. `login_screen.dart` — 474 Baris
**File:** `lib/src/features/auth/login_screen.dart`

**Masalah:**
- Inline decorative circles (286–349) — 64 baris `Positioned`/`Container` berulang.
- Inline `_showWebConfigErrorDialog` (180–218) + `_showResetPasswordDialog` (220–270).
- `_handleLogin()` (49–138) — ~50 baris error message mapping cascade.
- `_handleGoogleLogin()` (141–178) — error string matching.

**Saran Refaktor:**
- Ekstrak decorative circles ke `LoginScreenBackground` widget.
- Ekstrak dialogs ke file terpisah.
- Pindahkan error message mapping ke `AuthService` atau `AuthExceptionMapper`.
- Target: **<250 baris**.

---

### 14. `dashboard_stats.dart` — 175 Baris, Business Logic di Widget
**File:** `lib/src/features/home/widgets/dashboard_stats.dart`

**Masalah:**
- Revenue calculation logic (27–46) embedded di `StreamBuilder` dalam `StatelessWidget` — hitung totalRevenue, pendingRevenue, potentialRevenue berdasarkan payment status.
- `Provider.of<SalesService>` langsung.

**Saran Refaktor:**
- Pindahkan revenue aggregation ke `DashboardViewModel` atau `SalesService`.
- Widget presentational-only.

---

## 🟡 Minor Severity

### 15. `wallet_card.dart` — LayoutBuilder Duplikasi
**File:** `lib/src/features/home/widgets/wallet_card.dart`

**Masalah:**
- 193 baris — reasonable size, tapi `LayoutBuilder` dengan `isNarrow` responsive switching untuk dua layout (column vs row) lebih verbose dari perlu.
- Bisa disederhanakan dengan `Wrap`, `Flexible`, atau `CompactLayoutBuilder` helper.

---

### 16. Pola Dialog Standar Duplikasi di Seluruh Codebase
- **Confirmation dialogs** (Hapus/Delete confirm) — ditulis inline 15+ kali dengan `AlertDialog` + `Batal`/`Confirm` hampir identik.
- **Loading dialogs** (`showDialog` + `CircularProgressIndicator`) — duplikasi 5+ kali.
- **SnackBar error** — `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')))` muncul **61+ kali**.

**Saran Refaktor:**
- Buat reusable helpers: `showConfirmDialog(context, title, message)`, `showLoadingDialog(context)`, `showErrorSnackBar(context, error)`.
- Bisa kurangi ~300–400 baris dari codebase.

---

### 17. StreamBuilder Pattern Duplikasi
- **28 StreamBuilder** dengan boilerplate identik:
  ```dart
  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
  ```

**Saran Refaktor:**
- Buat `AsyncSnapshotWidget<T>` helper yang handle loading/error/data state secara uniform.

---

### 18. `add_edit_product_screen.dart` — 307 Baris
**File:** `lib/src/features/admin/add_edit_product_screen.dart`

**Masalah:**
- Inline image upload logic (218–285) — 67 baris.
- `Provider.of<StorageService>` langsung.
- SIBI toggle switch inline (132–164).

**Saran Refaktor:**
- Ekstrak image upload ke `ProductImagePicker` widget.
- Ekstrak SIBI toggle ke `SibiToggleCard`.

---

### 19. `image_management_screen.dart` — 310 Baris
**File:** `lib/src/features/admin/image_management_screen.dart`

**Masalah:**
- Inline delete confirmation dialog (69–88).
- Inline image grid dengan selection mode, date overlay, error handling di `build()`.
- Mixed responsibilities: image listing, selection, deletion, upload, picker mode.

**Saran Refaktor:**
- Split ke `ImageGrid`, `ImagePickerAppBar`, `ImageSelectionOverlay` widgets.
- Pindahkan deletion logic ke controller.

---

### 20. `link_bio_screen.dart` — 295 Baris
**File:** `lib/src/features/link_bio/link_bio_screen.dart`

**Masalah:**
- Mixed concerns: link management, social settings, stream building.
- Inline delete confirmation dialog (67–91).
- State management pake `setState()` untuk 4 controller fields.

---

### 21. `sales_history_screen.dart` — 335 Baris, Inline Tab Widgets
**File:** `lib/src/features/sales/history/sales_history_screen.dart`

**Masalah:**
- 3 private classes inline: `_SalesTab`, `_ClaimsTab`, `_EmptyState` (209–335) — 126 baris.
- `_EmptyState` duplikat, reusable di banyak tempat.
- `_processPelunasan` (82–131) — file reading, upload, sale update, notification, snackbar campur aduk.

**Saran Refaktor:**
- Ekstrak `SalesTab`, `ClaimsTab`, `EmptyStateWidget` ke file terpisah.
- Pindahkan `_processPelunasan` ke `PelunasanHandler` / controller.

---

### 22. Tight Coupling — 89 `Provider.of<Service>` di Layer UI
Di seluruh codebase: **89 instance** `Provider.of<XxxService>(context, listen: false)` dipanggil langsung di file feature/UI.

Service yang diakses langsung:
| Service | Frekuensi |
|---------|-----------|
| `SalesService` | 15+ |
| `AuthService` | 10+ |
| `ProductService` | 8+ |
| `StorageService` | 7+ |
| `AppNotificationService` | 6+ |
| `WalletService` | 4+ |
| `CustomerService`, `UserService`, `LinkBioService` | Masing-masing beberapa kali |

**Masalah:** Perubahan API service harus update semua call site. Testing butuh mock 3–5 service berbeda. Tidak ada ViewModel/Controller layer untuk isolasi business logic dari UI.

**Satu-satunya controller yang bener:** `NotificationController` — pisah state management notifikasi dari UI.

**Saran Refaktor:**
- Introduksi ViewModels/Controllers untuk setiap major feature (Sales, Home, Auth, Admin, Profile, Wallet, LinkBio).
- Screen hanya depend ke ViewModel-nya, bukan ke raw services.
- Pakai `MultiProvider` atau `Provider` dengan ViewModels di level feature.

---

### 23. `digital_business_card.dart` — 431 Baris
**File:** `lib/src/features/link_bio/widgets/digital_business_card.dart`

**Masalah:**
- 3 distinct classes: `DigitalBusinessCard`, `MockQrPainter`, fungsi `showDigitalBusinessCardDialog()`.
- Dialog function (348–431) — coupling presentation logic dengan navigation.

**Saran Refaktor:**
- Pisah `MockQrPainter` ke file sendiri (reusable painter).
- Ekstrak dialog ke `DigitalBusinessCardDialog` widget terpisah.

---

## 📊 Statistik Ringkasan

| Metrik | Jumlah |
|--------|--------|
| File >300 baris | 15 |
| File >500 baris | 7 |
| File >700 baris | 3 |
| File >900 baris | 2 |
| `Provider.of<Service>` di features | 89 |
| `ScaffoldMessenger.showSnackBar` | 61+ |
| Inline dialogs | 35+ |
| Inline private widgets di screen files | ~15 instance |
| Files dengan mixed concerns (UI + data + navigation) | ~20 |

## 🎯 5 File Paling Prioritas untuk Refaktor

| # | File | Baris | Masalah |
|---|------|-------|---------|
| 1 | `sales_entry_book_screen.dart` | 997 | Monolitik, god methods, 5 services langsung |
| 2 | `product_picker_field.dart` | 1.007 | 6 class dalam 1 file, 886 baris cuma 1 widget |
| 3 | `faktur_printable_sheet.dart` + `faktur_pdf_generator.dart` | 1.598 | Duplikasi layout invoice 50+ baris |
| 4 | `global_settings_screen.dart` | 469 | 22 controller, god save/load, setState semua |
| 5 | `link_bio_admin_widgets.dart` | 574 | 3 widget besar dalam 1 file |
