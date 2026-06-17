# Analisis Struktur Folder — Marketing Penerbit Jagaddhita

---

## Pola Konvensi yang Ada

Proyek menggunakan arsitektur feature-based:
- `lib/src/features/[feature]/` — root per fitur
- `lib/src/features/[feature]/widgets/` — widget reusable
- `lib/src/features/[feature]/utils/` — utility/helper
- `lib/src/core/` — cross-cutting concerns
- `lib/src/core/widgets/`, `utils/`, `constants/`, `models/`, `theme/`, `services/`

**Tidak ada feature yang punya folder `screens/`** — semua screen file langsung di root feature.

---

## 🔴 Semua Feature Kehilangan Folder `screens/`

**Setiap feature** menempatkan screen file di root, bukan di `screens/`:

| Feature | File | Lokasi Saat Ini | Lokasi Seharusnya |
|---------|------|-----------------|-------------------|
| `admin/` | `admin_home_screen.dart` | `features/admin/` | `features/admin/screens/` |
| `admin/` | `admin_transactions_screen.dart` | `features/admin/` | `features/admin/screens/` |
| `admin/` | `admin_user_list_screen.dart` | `features/admin/` | `features/admin/screens/` |
| `admin/` | `admin_withdrawals_screen.dart` | `features/admin/` | `features/admin/screens/` |
| `admin/` | `add_edit_product_screen.dart` | `features/admin/` | `features/admin/screens/` |
| `admin/` | `image_management_screen.dart` | `features/admin/` | `features/admin/screens/` |
| `admin/` | `global_settings_screen.dart` | `features/admin/` | `features/admin/screens/` |
| `admin/` | `product_management_screen.dart` | `features/admin/` | `features/admin/screens/` |
| `auth/` | `login_screen.dart` | `features/auth/` | `features/auth/screens/` |
| `auth/` | `register_screen.dart` | `features/auth/` | `features/auth/screens/` |
| `catalog/` | `catalog_screen.dart` | `features/catalog/` | `features/catalog/screens/` |
| `catalog/` | `product_detail_screen.dart` | `features/catalog/` | `features/catalog/screens/` |
| `home/` | `home_screen.dart` | `features/home/` | `features/home/screens/` |
| `home/` | `main_screen.dart` | `features/home/` | `features/home/screens/` |
| `home/` | `poster_generator_screen.dart` | `features/home/` | `features/home/screens/` |
| `link_bio/` | `link_bio_screen.dart` | `features/link_bio/` | `features/link_bio/screens/` |
| `link_bio/` | `link_bio_preview_screen.dart` | `features/link_bio/` | `features/link_bio/screens/` |
| `link_bio/` | `link_bio_loading_screen.dart` | `features/link_bio/` | `features/link_bio/screens/` |
| `notifications/` | `notification_list_screen.dart` | `features/notifications/` | `features/notifications/screens/` |
| `profile/` | `profile_screen.dart` | `features/profile/` | `features/profile/screens/` |
| `sales/` | `sales_entry_book_screen.dart` | `features/sales/` | `features/sales/screens/` |
| `splash/` | `splash_screen.dart` | `features/splash/` | `features/splash/screens/` |
| `wallet/` | `withdrawal_request_screen.dart` | `features/wallet/` | `features/wallet/screens/` |

**Total: 23 screen file perlu dipindahkan ke folder `screens/` masing-masing.**

---

## 🟠 File Orphan — Terpisah dari Subfolder yang Sudah Ada

Beberapa file memiliki subfolder tematik yang sudah dibuat (dari refaktor sebelumnya), tapi file utamanya masih tertinggal di luar:

| File | Lokasi Saat Ini | Subfolder yang Ada | Lokasi Seharusnya |
|------|-----------------|--------------------|--------------------|
| `bonus_eligibility_card.dart` | `home/widgets/` | `home/widgets/bonus/` (berisi 3 file) | `home/widgets/bonus/bonus_eligibility_card.dart` |
| `dashboard_stats.dart` | `home/widgets/` | `home/widgets/dashboard/` (berisi 2 file) | `home/widgets/dashboard/dashboard_stats.dart` |
| `poster_generator_widgets.dart` | `home/widgets/` | `home/widgets/poster/` (berisi 2 file) | `home/widgets/poster/poster_generator_widgets.dart` |
| `transaction_update_dialog.dart` | `admin/widgets/` | `admin/widgets/transaction_update/` (berisi 3 file) | `admin/widgets/transaction_update/transaction_update_dialog.dart` |
| `digital_business_card.dart` | `link_bio/widgets/` | `link_bio/widgets/digital_business_card/` (berisi 2 file) | `link_bio/widgets/digital_business_card/digital_business_card.dart` |

---

## 🟡 Struktur Folder `widgets/` yang Masih Datar

Beberapa folder `widgets/` masih terlalu banyak file langsung tanpa subfolder:

### `admin/widgets/` — 18 file langsung
```
widgets/
├── admin_claim_card.dart
├── admin_pending_claims_card.dart
├── admin_product_card.dart
├── admin_total_agents_card.dart
├── admin_user_card.dart
├── admin_user_card_components.dart
├── transaction_card.dart
├── admin_recent_transactions_list.dart
├── admin_top_agents_list.dart
├── transaction_detail_modal.dart
├── transaction_update_dialog.dart          ← orphan (punya subfolder sendiri)
├── transaction_update/                     ← sudah ada
├── settings/
│   ├── bonus_settings_card.dart
│   ├── commission_settings_card.dart
│   ├── contact_settings_card.dart
│   ├── invoice_settings_card.dart
│   ├── payment_method_settings_card.dart
│   ├── pulsa_bonus_settings_card.dart
│   └── site_settings_card.dart
```

**Saran grouping:**
- `cards/`: 6 `*_card.dart` files
- `lists/`: `admin_recent_transactions_list.dart`, `admin_top_agents_list.dart`
- `modals/`: `transaction_detail_modal.dart`

### `sales/widgets/` — 10 file langsung + subfolder
```
widgets/
├── faktur_printable_sheet.dart
├── faktur_view.dart
├── sale_detail_dialog.dart
├── sales_entry_shared_widgets.dart
├── sales_text_field.dart
├── markup_input_field.dart
├── transaction_proof_input.dart
├── slanted_clipper.dart                    ← ini utility, bukan widget
├── product_picker_field.dart
├── transaction_timeline.dart
├── product_picker/                         ← sudah ada
├── sales_entry/                            ← sudah ada
```

**Saran grouping:**
- `form_fields/` atau `inputs/`: `sales_text_field.dart`, `markup_input_field.dart`, `transaction_proof_input.dart`
- `dialogs/`: `sale_detail_dialog.dart`
- `faktur/`: `faktur_printable_sheet.dart`, `faktur_view.dart`
- Pindahkan `slanted_clipper.dart` ke `sales/utils/`

### `home/widgets/` — 12 file langsung + subfolder

**Saran grouping selain yang sudah disebutkan (orphan files):**
- `admin_fab_menu.dart` + `marketing_fab_menu.dart` → `fab_menus/` atau `navigation/`

### `profile/widgets/` — 5 file
``` `widgets/` langsung

**Saran grouping (opsional):**
- `sheets/`: `bank_settings_sheet.dart`, `edit_profile_sheet.dart`

### `link_bio/widgets/` — 9 file langsung

**Saran grouping:**
- `cards/`: `link_bio_custom_link_card.dart`, `link_bio_header_card.dart`
- `forms/`: `link_bio_social_form.dart`, `social_media_text_field.dart`

---

## 🟡 File di Lokasi Salah Kategori

| File | Lokasi Saat Ini | Seharusnya | Alasan |
|------|-----------------|------------|--------|
| `slanted_clipper.dart` | `sales/widgets/` | `sales/utils/` | Ini `CustomClipper<Path>`, utility rendering, bukan widget |
| `notification_controller.dart` | `notifications/` | `notifications/controllers/` | Controller/state management, bukan screen |
| `add_edit_link_dialog.dart` | `link_bio/` | `link_bio/widgets/dialogs/` | Dialog file di root feature, bukan widget |

---

## 🟡 `core/utils/` — Platform Helper Files Tidak Terkelompok

`utils/` punya 16 file langsung. Platform-specific helpers (stub/mobile/web) tidak dikelompokkan:

| Group | File |
|-------|------|
| **poster/** | `poster_export_helper.dart`, `poster_export_helper_mobile.dart`, `poster_export_helper_stub.dart`, `poster_export_helper_web.dart` |
| **excel/** | `excel_export_helper.dart`, `excel_export_helper_mobile.dart`, `excel_export_helper_stub.dart`, `excel_export_helper_web.dart` |
| **network/** | `network_image_web_helper.dart`, `network_image_web_helper_stub.dart`, `network_image_web_helper_mobile.dart` |

**Saran:** Buat subfolder `poster/`, `excel/`, `network/` di dalam `utils/`.

---

## ⚠️ Naming Inconsistencies

| Masalah | Contoh |
|---------|--------|
| Singular vs plural | `dashboard_stats.dart` vs `dashboard_stat_card.dart` |
| Verb vs noun | `add_edit_product_screen.dart` vs `product_management_screen.dart` |
| Inconsistent pluralization | `admin_claim_card.dart` vs `admin_pending_claims_card.dart` (claim vs claims) |

---

## 📋 Ringkasan Prioritas Perbaikan Struktur

| Prioritas | Jumlah File | Tindakan |
|-----------|-------------|----------|
| 🔴 **High** | 23 | Pindahkan screen files ke `screens/` folder di setiap feature |
| 🟠 **Medium** | 5 | Pindahkan orphan files ke subfolder yang sudah ada (bonus, dashboard, poster, transaction_update, digital_business_card) |
| 🟡 **Low** | ~30 | Grouping widget files di admin, sales, home, link_bio ke subfolder |
| 🟡 **Low** | 11 | Group platform helper files di `core/utils/` ke subfolder |
| ⚠️ **Minor** | 3 | Pindahkan file ke kategori yang benar (`slanted_clipper`, `notification_controller`, `add_edit_link_dialog`) |
