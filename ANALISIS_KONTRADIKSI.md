# Analisis Kontradiksi & Inkonsistensi Pasca Refaktor

---

## 🔴 HIGH — Duplikasi & Kontradiksi Kritis

### 1. Tiga Implementasi Sale Detail View (Duplikasi ~500 baris)

| File | Class/Fungsi | Tipe |
|------|-------------|------|
| `sales/widgets/sale_detail_dialog.dart` | `SaleDetailDialog` | Dialog (showDialog) |
| `sales/history/widgets/sale_detail_sheet.dart` | `showSaleDetailModal()` | Bottom sheet |
| `admin/widgets/transaction_detail_modal.dart` | `TransactionDetailModal` | Bottom sheet |

**Masalah:** Ketiganya menampilkan data transaksi yang hampir sama (produk, payment, timeline, bukti gambar) dengan build method masing-masing. Setiap perubahan layout harus di-update di 3 tempat.

**Fix:** Konsolidasi jadi satu `SaleDetailView` widget, lalu buat thin wrapper untuk dialog/sheet.

---

### 2. `AppDialogs` — Dibuat Tapi Hanya Dipakai 1 dari 20+ Tempat

`lib/src/core/utils/app_dialogs.dart` menyediakan:
- `showConfirmDialog()`
- `showLoadingDialog()`
- `showErrorSnackBar()`
- `showSuccessSnackBar()`

**Hanya 1 file yang pakai:** `link_bio/link_bio_screen.dart`

**Masih inline di 20+ tempat:**
| File | Inline Pattern |
|------|---------------|
| `admin_home_screen.dart:81-101` | Logout confirmation |
| `admin_product_card.dart:184-211` | Delete product |
| `admin_user_card.dart:202-251` | Delete user |
| `profile_screen.dart:122-142` | Delete account |
| `withdrawal_request_screen.dart:133+` | Confirmation withdrawal |
| `sale_detail_sheet.dart:95+` | Confirmation |
| `claim/claim_widgets.dart:113-163` | Approve/reject |
| `sales_entry_book_screen.dart:440-446` | Cancel confirmation |
| Dan banyak snackbar error/sukses inline | |

**Fix:** Migrasi semua ke `AppDialogs`, atau hapus `app_dialogs.dart`.

---

### 3. `AsyncSnapshotWidget` — Dibuat Tapi Hanya Dipakai 1 dari 30+ StreamBuilder

`lib/src/core/widgets/async_snapshot_widget.dart` — hanya `link_bio/link_bio_screen.dart` yang pakai.

**30+ StreamBuilder/FutureBuilder** masih dengan boilerplate:
```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
  return Center(child: Text('Error: ${snapshot.error}'));
}
final data = snapshot.data!;
```

Termasuk di: `admin_transactions_screen`, `admin_withdrawals_screen`, `admin_user_list_screen`, `catalog_screen`, `home_screen`, `main_screen`, `product_management_screen`, `withdrawal_request_screen`, `sales_entry_book_screen`, `history_tab_widgets`, dll.

**Fix:** Migrasi semua StreamBuilder ke `AsyncSnapshotWidget`, atau hapus.

---

## 🟠 MEDIUM — Organisasi & Naming

### 4. Enam File Orphan Tidak di Subfolder

| File | Subfolder yang Ada | Seharusnya |
|------|--------------------|------------|
| `admin/widgets/admin_claim_card.dart` | `admin/widgets/claim/` | `admin/widgets/claim/admin_claim_card.dart` |
| `admin/widgets/transaction_update_dialog.dart` | `admin/widgets/transaction_update/` | `admin/widgets/transaction_update/transaction_update_dialog.dart` |
| `home/widgets/bonus_eligibility_card.dart` | `home/widgets/bonus/` | `home/widgets/bonus/bonus_eligibility_card.dart` |
| `home/widgets/dashboard_stats.dart` | `home/widgets/dashboard/` | `home/widgets/dashboard/dashboard_stats.dart` |
| `home/widgets/poster_generator_widgets.dart` | `home/widgets/poster/` | `home/widgets/poster/poster_generator_widgets.dart` |
| `link_bio/widgets/digital_business_card.dart` | `link_bio/widgets/digital_business_card/` | `link_bio/widgets/digital_business_card/digital_business_card.dart` |

Semua file ini sudah import dari subfolder masing-masing tapi belum pindah.

---

### 5. Naming Conflict: `NotificationService` vs `AppNotificationService`

| File | Class | Fungsi |
|------|-------|--------|
| `core/services/notification_service.dart` | `NotificationService` | Local push notifications |
| `core/services/firestore/notification_service.dart` | `AppNotificationService` | Firestore remote notifications |

**Masalah:** Namanya terbalik secara mental model. `AppNotificationService` (yang bukan "app-level") ada di folder `firestore/`, sementara `NotificationService` (yang lokal) ada di folder `services/`. Developer harus pakai alias `as local` untuk membedakan.

**Fix:** Rename `AppNotificationService` → `FirestoreNotificationService`.

---

### 6. Duplicate Empty State Widgets

| File | Class | Lokasi |
|------|-------|--------|
| `notification_list_screen.dart` | `_EmptyState` (private) | Inline di screen |
| `history_tab_widgets.dart` | `HistoryEmptyState` (public) | `sales/history/widgets/` |

Keduanya hampir identik (icon gradient + title + description). `_EmptyState` tidak bisa di-reuse.

**Fix:** Ekstrak shared `EmptyStateWidget` ke `core/widgets/`.

---

## 🟡 LOW — Minor

### 7. `placeholder_screen.dart` Tidak Dipakai Sama Sekali
`lib/src/core/widgets/placeholder_screen.dart` — 14 baris, tidak di-import oleh file manapun. Dead code.

### 8. `SalesTextField` — Layer Abstraksi Tidak Perlu
`sales/widgets/sales_text_field.dart` hanyalah wrapper tipis dari `AppTextField`. Bisa diganti langsung dengan `AppTextField`.

### 9. `notification_controller.dart` Import Tanpa Alias
Import `NotificationService` dan `AppNotificationService` tanpa alias. Rentan collision jika suatu saat ada rename class.

---

## ✅ Yang SUDAH BENAR (Tidak Ada Kontradiksi)

| Pattern | Status |
|---------|--------|
| `sales_calculator_helper.dart` | ✅ Full extracted, no inline duplication |
| `notification_tap_handler.dart` | ✅ Full extracted, no inline duplication |
| `product_picker_field` → 6 files | ✅ Cleanly split |
| `faktur_printable_sheet` + `faktur_pdf_generator` + `InvoiceDataHelper` | ✅ Clean extraction |
| `link_bio_admin_widgets` → 4 files | ✅ Clean split |
| `bonus_eligibility_card` → 3 sub-widgets | ✅ Clean extraction |
| `dashboard_stats` → data + card widget | ✅ Clean extraction |
| `transaction_update_dialog` → 3 section widgets | ✅ Clean extraction |
| `profile_screen` → 3 widget files | ✅ Clean extraction |
| Semua import paths | ✅ **Tidak ada broken imports** |

---

## 📋 Ringkasan Prioritas Perbaikan

| Prioritas | Issue | Tindakan |
|-----------|-------|----------|
| 🔴 **P1** | 3 sale detail views duplikasi | Konsolidasi ke 1 widget |
| 🔴 **P1** | `AppDialogs` tidak diadopsi | Migrasi 20+ tempat atau hapus |
| 🔴 **P1** | `AsyncSnapshotWidget` tidak diadopsi | Migrasi 30+ StreamBuilder atau hapus |
| 🟠 **P2** | 6 orphan files | Pindah ke subfolder |
| 🟠 **P2** | `NotificationService` naming | Rename ke `FirestoreNotificationService` |
| 🟠 **P2** | Duplicate empty state | Ekstrak ke shared widget |
| 🟡 **P3** | `placeholder_screen.dart` | Hapus atau wiring ke router |
| 🟡 **P3** | `SalesTextField` tidak perlu | Ganti dengan `AppTextField` langsung |
