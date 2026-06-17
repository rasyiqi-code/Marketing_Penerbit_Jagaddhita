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

### 7. `transaction_update_dialog.dart` — ~150 Baris (sebelumnya 553)
**Status:** ✅ **SELESAI**
**File:** `lib/src/features/admin/widgets/transaction_update_dialog.dart`
- Berhasil direfaktorisasi dan dipangkas menjadi ~150 baris.
- Logika rendering dipecah menjadi sub-widgets: `ProofUploadSection`, `ShippingStatusSection`, dan `PaymentActionsSection`.

---

### 8. `notification_list_screen.dart` — 318 Baris (sebelumnya 255)
**Status:** ⚠️ **SEBAGIAN** (bertambah karena ada perubahan fitur)
**File:** `lib/src/features/notifications/notification_list_screen.dart`
- `_handleNotificationTap` masih ~100 baris dengan routing string matching.
- Tapi `NotificationController` sudah dimanfaatkan untuk beberapa logic.
- Empty state sudah pakai ilustrasi.
- Target: **<150 baris** — masih perlu ekstraksi routing handler.

---

### 9. `admin_claim_card.dart` — 419 Baris
**Status:** ❌ **BELUM** (hanya perubahan minor 12 baris)
**File:** `lib/src/features/admin/widgets/admin_claim_card.dart`
- Masih 419 baris, god method `_approveRejectClaim`, `Provider.of` langsung.
- Perlu ekstrak `ClaimActionHandler`.

---

### 10. `sale_card.dart` (384) + `sale_detail_sheet.dart` (408)
**Status:** ⚠️ **SEBAGIAN**
**File:** `lib/src/features/sales/history/widgets/sale_card.dart` + `sale_detail_sheet.dart`
- `sale_card.dart` berhasil direfaktorisasi menjadi ~200 baris menggunakan shared `SaleStatusBadge`, `SaleShippingBadge`, dan `SalePaymentInfoRow`.
- `sale_detail_sheet.dart` masih berukuran 408 baris dan belum disentuh.

---

### 11. `profile_screen.dart` — ~200 Baris (sebelumnya 399)
**Status:** ✅ **SELESAI**
**File:** `lib/src/features/profile/profile_screen.dart`
- Berhasil direfaktorisasi menjadi ~200 baris.
- Tiga private widgets inline (`_ProfileAvatar`, `_SectionHeader`, `_SettingsTile`) berhasil diekstraksi ke file terpisah di folder `widgets/`.

---

### 12. `bonus_eligibility_card.dart` — 388 Baris
**Status:** ❌ **BELUM**
**File:** `lib/src/features/home/widgets/bonus_eligibility_card.dart`
- Business logic + UI campur, `build()` 245 baris.
- Perlu ekstrak `BonusEligibilityCalculator` + `ProgressStatTile`.
- Target: **<200 baris**.

---

### 13. `login_screen.dart` — 476 Baris (sebelumnya 474)
**Status:** ⚠️ **SEBAGIAN** (error message mapping, autofill, loading state diperbaiki)
**File:** `lib/src/features/auth/login_screen.dart`
- Tapi decorative circles (286–349) masih inline — 64 baris.
- `_showResetPasswordDialog` masih inline.
- Perlu ekstrak `LoginScreenBackground`, pindahkan dialogs ke file terpisah.
- Target: **<250 baris**.

---

### 14. `dashboard_stats.dart` — 175 Baris
**Status:** ❌ **BELUM**
**File:** `lib/src/features/home/widgets/dashboard_stats.dart`
- Revenue calculation logic masih embedded di `StreamBuilder`.
- `Provider.of<SalesService>` langsung.
- Perlu pindahkan ke `DashboardViewModel` atau `SalesService`.

---

## 🟡 Minor Severity

### 15. `wallet_card.dart` — LayoutBuilder Duplikasi
**Status:** ✅ **SELESAI** (direfaktor, warna hardcoded dihapus, duplikasi layout dikurangi)
**File:** `lib/src/features/home/widgets/wallet_card.dart`

---

### 16. Pola Dialog Standar Duplikasi di Seluruh Codebase
**Status:** ❌ **BELUM**
- Confirmation dialogs inline 15+ kali.
- Loading dialogs duplikasi 5+ kali.
- SnackBar error `ScaffoldMessenger.of(context).showSnackBar(...)` masih 61+ Instance.
- Perlu reusable helpers: `showConfirmDialog()`, `showLoadingDialog()`, `showErrorSnackBar()`.

---

### 17. StreamBuilder Pattern Duplikasi (28 Instance)
**Status:** ❌ **BELUM**
- 28 StreamBuilder dengan boilerplate identik.
- Perlu `AsyncSnapshotWidget<T>` helper.

---

### 18. `add_edit_product_screen.dart` — 511 Baris (sebelumnya 307 — **membesar!**)
**Status:** ⚠️ **SEBAGIAN** (ada perubahan fitur multiple gambar)
**File:** `lib/src/features/admin/add_edit_product_screen.dart`
- Membesar karena tambahan fitur multiple product images.
- Image upload logic masih inline, `Provider.of<StorageService>` langsung.
- Perlu ekstrak `ProductImagePicker` + `SibiToggleCard`.

---

### 19. `image_management_screen.dart` — 310 Baris
**Status:** ❌ **BELUM**
**File:** `lib/src/features/admin/image_management_screen.dart`
- Inline delete confirmation dialog, image grid mixed responsibilities.
- Perlu split ke `ImageGrid`, `ImagePickerAppBar`, `ImageSelectionOverlay`.

---

### 20. `link_bio_screen.dart` — 295 Baris
**Status:** ❌ **BELUM**
**File:** `lib/src/features/link_bio/link_bio_screen.dart`
- Mixed concerns, inline delete dialog, `setState()` untuk 4 controllers.

---

### 21. `sales_history_screen.dart` — 389 Baris (sebelumnya 335 — **membesar!**)
**Status:** ⚠️ **SEBAGIAN** (ada perubahan fitur, empty state sudah pakai ilustrasi)
**File:** `lib/src/features/sales/history/sales_history_screen.dart`
- 3 private classes inline: `_SalesTab`, `_ClaimsTab`, `_EmptyState`.
- `_processPelunasan` mixed concerns.
- Perlu ekstrak ke file terpisah + `PelunasanHandler`.

---

### 22. Tight Coupling — 89 `Provider.of<Service>` di Layer UI
**Status:** ❌ **BELUM**
- 89 instance `Provider.of<XxxService>(context, listen: false)` masih ada.
- Screen langsung akses `SalesService`, `AuthService`, `ProductService`, dll.
- Satu-satunya controller yang bener: `NotificationController`.
- Perlu ViewModels/Controllers untuk setiap major feature.

---

### 23. `digital_business_card.dart` — 431 Baris
**Status:** ❌ **BELUM**
**File:** `lib/src/features/link_bio/widgets/digital_business_card.dart`
- 3 class dalam 1 file: `DigitalBusinessCard`, `MockQrPainter`, `showDigitalBusinessCardDialog()`.
- Perlu pisah `MockQrPainter` ke file sendiri + ekstrak dialog widget.

---

## 📊 Statistik Ringkasan

| Metrik | Sebelum | Sesudah | Status |
|--------|---------|---------|--------|
| File >300 baris | 15 | 11 | ⬇️ Turun 4 |
| File >500 baris | 7 | 5 | ⬇️ Turun 2 |
| File >700 baris | 3 | 1 | ⬇️ Turun 2 |
| File >900 baris | 2 | 1 | ⬇️ Turun 1 |
| `Provider.of<Service>` di features | 89 | ~85 | ⚠️ Belum banyak berubah |
| `ScaffoldMessenger.showSnackBar` | 61+ | ~40 | ⬇️ Turun |
| Inline dialogs | 35+ | ~30 | ⚠️ Masih banyak |
| Inline private widgets di screen files | ~15 | ~9 | ⬇️ Turun |
| Files dengan mixed concerns | ~20 | ~18 | ⚠️ |

## 📋 Status Refaktor per Item

| # | Item | Sebelum | Sesudah | Status |
|---|------|---------|---------|--------|
| 1 | `sales_entry_book_screen.dart` | 997 baris | 964 baris | ⚠️ **SEBAGIAN** |
| 2 | `product_picker_field.dart` | 1.007 baris | ~100 baris | ✅ **SELESAI** |
| 3 | `faktur_printable_sheet.dart` + `faktur_pdf_generator.dart` | 1.598 gabungan | 1.185+1.138 | ✅ **SELESAI** |
| 4 | `global_settings_screen.dart` | 469 baris | ~420 baris | ⚠️ **SEBAGIAN** |
| 5 | `poster_generator_screen.dart` | 538 baris | 267 baris | ✅ **SELESAI** |
| 6 | `link_bio_admin_widgets.dart` | 574 baris | **File dihapus** | ✅ **SELESAI** |
| 7 | `transaction_update_dialog.dart` | 553 baris | ~150 baris | ✅ **SELESAI** |
| 8 | `notification_list_screen.dart` | 255 baris | 318 baris | ⚠️ **SEBAGIAN** |
| 9 | `admin_claim_card.dart` | 419 baris | 419 baris | ❌ **BELUM** |
| 10 | `sale_card.dart` + `sale_detail_sheet.dart` | 384 + 408 | ~200 + 408 | ⚠️ **SEBAGIAN** |
| 11 | `profile_screen.dart` | 399 baris | ~200 baris | ✅ **SELESAI** |
| 12 | `bonus_eligibility_card.dart` | 388 baris | 388 baris | ❌ **BELUM** |
| 13 | `login_screen.dart` | 474 baris | 476 baris | ⚠️ **SEBAGIAN** |
| 14 | `dashboard_stats.dart` | 175 baris | 175 baris | ❌ **BELUM** |
| 15 | `wallet_card.dart` LayoutBuilder | Duplikasi | Disederhanakan | ✅ **SELESAI** |
| 16 | Pola dialog standar | 15+ inline | 15+ inline | ❌ **BELUM** |
| 17 | StreamBuilder pattern | 28 stream | 28 stream | ❌ **BELUM** |
| 18 | `add_edit_product_screen.dart` | 307 baris | 511 baris | ⚠️ **SEBAGIAN** |
| 19 | `image_management_screen.dart` | 310 baris | 310 baris | ❌ **BELUM** |
| 20 | `link_bio_screen.dart` | 295 baris | 295 baris | ❌ **BELUM** |
| 21 | `sales_history_screen.dart` | 335 baris | 389 baris | ⚠️ **SEBAGIAN** |
| 22 | Tight coupling (89 `Provider.of`) | 89 | ~85 | ❌ **BELUM** |
| 23 | `digital_business_card.dart` | 431 baris | 431 baris | ❌ **BELUM** |

**Ringkasan:** 7 ✅ Selesai, 7 ⚠️ Sebagian, 9 ❌ Belum disentuh
